#!/usr/bin/env python3
"""Pull user-facing English literals out of lib/ into app_en.arb.

Dry-run by default; pass --apply to rewrite files. Only rewrites literals it
can prove are safe: plain text passed to Text() or a label-like argument,
inside a function that has a BuildContext. Everything else is reported for you
to handle by hand.

    python tool/extract_strings.py                                  # report only
    python tool/extract_strings.py --only lib/features/assessment   # one area
    python tool/extract_strings.py --apply    # rewrite, then:
    python tool/sync_arb.py && flutter gen-l10n && flutter analyze

Medicine names never become keys. They are read from the backend's
drug_reference.json, plus anything in tool/keep_english.txt; a literal naming
one is reported instead. Put `// l10n-ignore` on a line to skip it.
"""
from __future__ import annotations

import argparse
import collections
import json
import pathlib
import re
import sys
from dataclasses import dataclass, field

LIB = pathlib.Path("lib")
ARB_EN = LIB / "l10n" / "app_en.arb"
DRUG_REFERENCE = pathlib.Path("../backend/deploy/drug_reference.json")
KEEP_ENGLISH = pathlib.Path("tool/keep_english.txt")
IGNORE_MARKER = "l10n-ignore"

# Generated output and the ARB folder itself.
SKIP_DIRS = {"l10n"}
# Learn content is translated as whole files, not through the ARB.
SKIP_FILES = {"library_en.dart", "library_si.dart"}

# Named arguments whose value is shown to the user.
ARG_NAMES = {
    "title", "subtitle", "label", "labelText", "hintText", "helperText",
    "errorText", "tooltip", "semanticLabel", "semanticsLabel", "message",
    "confirmText", "cancelText", "text", "error", "prefixText", "suffixText",
    "counterText", "barrierLabel",
}

# Not worth a translation key.
IGNORE = re.compile(
    r"^\s*$"                                        # blank
    r"|^[\W\d_]+$"                                  # punctuation, digits, emoji
    r"|^[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)+$"    # snake_case: Side_Effect
    r"|^[a-z]+(?:[A-Z][a-z0-9]*)+$"                 # camelCase identifiers
    r"|^(?i:px|dp|mg|kg|ml)$"                       # bare units
)

HAS_DECL = re.compile(r"\bAppLocalizations\s+l10n\s*=")
IMPORT_L10N = re.compile(r"""import\s+['"][^'"]*l10n/app_localizations\.dart['"];""")
CONTEXT_PARAM = re.compile(r"\bBuildContext\s+(\w+)")
CONTROL = {"if", "for", "while", "switch", "catch", "on"}
CLASS_HEADER = re.compile(r"\b(?:class|mixin|extension|enum)\b[^{};]*$")
FUNC_TAIL = re.compile(r"\)\s*(?:async\*?|sync\*)?\s*$")
NAME_TAIL = re.compile(r"(\w+)\s*(?:<[^()]*>)?\s*$")
CONST_CALL = re.compile(r"\bconst\s+(?=[A-Za-z_$][\w$.]*\s*(?:<[^()]*>)?\s*$)")
CONST_LITERAL = re.compile(r"\bconst\b\s*(?=(?:<[^()\[\]{}]*>)?\s*$)")
TEXT_CALL = re.compile(r"\b(?:Selectable)?Text\s*$")
INTERPOLATION = re.compile(r"(?<!\\)\$[{A-Za-z_]")


# --- Dart source scanning -------------------------------------------------

def _is_raw_prefix(src: str, i: int) -> bool:
    return (src[i] in "rR" and src[i + 1:i + 2] in ("'", '"')
            and not (i and (src[i - 1].isalnum() or src[i - 1] in "_$")))


def _skip_comment(src: str, i: int) -> int:
    if src.startswith("//", i):
        j = src.find("\n", i)
        return len(src) if j < 0 else j
    if src.startswith("/*", i):
        j = src.find("*/", i + 2)
        return len(src) if j < 0 else j + 2
    return i


def _string_end(src: str, i: int) -> int:
    raw = src[i] in "rR"
    i += raw
    q = src[i]
    delim = q * 3 if src.startswith(q * 3, i) else q
    i += len(delim)
    while i < len(src):
        if src.startswith(delim, i):
            return i + len(delim)
        if not raw and src[i] == "\\":
            i += 2
            continue
        if not raw and src.startswith("${", i):
            i = _interpolation_end(src, i + 2)
            continue
        if src[i] == "\n" and len(delim) == 1:
            return i
        i += 1
    return i


def _interpolation_end(src: str, i: int) -> int:
    depth = 0
    while i < len(src):
        j = _skip_comment(src, i)
        if j != i:
            i = j
            continue
        c = src[i]
        if c in "'\"" or _is_raw_prefix(src, i):
            i = _string_end(src, i)
            continue
        if c == "{":
            depth += 1
        elif c == "}":
            if depth == 0:
                return i + 1
            depth -= 1
        i += 1
    return i


def scan(src: str) -> tuple[bytearray, list[tuple[int, int]]]:
    """Code mask (1 outside strings and comments) and top-level string spans."""
    code = bytearray(b"\x01") * len(src)
    strings: list[tuple[int, int]] = []
    i = 0
    while i < len(src):
        j = _skip_comment(src, i)
        if j == i and (src[i] in "'\"" or _is_raw_prefix(src, i)):
            j = _string_end(src, i)
            strings.append((i, j))
        if j != i:
            code[i:j] = bytes(j - i)
            i = j
        else:
            i += 1
    return code, strings


ESCAPES = {"n": "\n", "t": "\t", "r": "\r", "b": "\b", "f": "\f", "v": "\v"}


def unescape(body: str) -> str:
    def sub(m: re.Match) -> str:
        s = m.group(1)
        if s.startswith("u{"):
            return chr(int(s[2:-1], 16))
        if s[0] in "ux" and len(s) > 1:
            return chr(int(s[1:], 16))
        return ESCAPES.get(s, s)
    return re.sub(r"\\(u\{[0-9A-Fa-f]+\}|u[0-9A-Fa-f]{4}|x[0-9A-Fa-f]{2}|.)",
                  sub, body, flags=re.S)


def literal_text(src: str, start: int, end: int) -> tuple[str, bool]:
    """Unescaped text of one literal, and whether it interpolates."""
    raw = src[start] in "rR"
    s = start + raw
    q = src[s]
    d = 3 if src.startswith(q * 3, s) else 1
    body = src[s + d:end - d]
    if raw:
        return body, False
    return unescape(body), bool(INTERPOLATION.search(body))


def prev_code(src: str, code: bytearray, i: int) -> int:
    i -= 1
    while i >= 0 and (not code[i] or src[i].isspace()):
        i -= 1
    return i


def next_code(src: str, code: bytearray, i: int) -> int:
    while i < len(src) and (not code[i] or src[i].isspace()):
        i += 1
    return i


def matching_open(src: str, code: bytearray, close: int) -> int:
    depth = 0
    for i in range(close, -1, -1):
        if not code[i]:
            continue
        if src[i] in ")]}":
            depth += 1
        elif src[i] in "([{":
            depth -= 1
            if depth == 0:
                return i
    return -1


def enclosers(src: str, code: bytearray, pos: int) -> list[int]:
    """Unclosed brackets around pos, innermost first."""
    out, depth = [], 0
    for i in range(pos - 1, -1, -1):
        if not code[i]:
            continue
        c = src[i]
        if c in ")]}":
            depth += 1
        elif c in "([{":
            if depth:
                depth -= 1
            else:
                out.append(i)
    return out


def function_params(src: str, code: bytearray, brace: int) -> str | None:
    """Parameter list if the brace opens a function body, else None."""
    start = max(0, brace - 40)
    m = FUNC_TAIL.search(src, start, brace)
    if not m:
        return None
    close = m.start()
    open_ = matching_open(src, code, close)
    if open_ < 0:
        return None
    name = NAME_TAIL.search(src, max(0, open_ - 80), open_)
    if name and name.group(1) in CONTROL:
        return None
    return src[open_ + 1:close]


# --- Resolving where a literal lives --------------------------------------

@dataclass
class Scope:
    decl_brace: int | None          # function body to declare l10n in, if needed
    ctx_name: str
    consts: list[tuple[int, int]] = field(default_factory=list)


def resolve(src: str, code: bytearray, pos: int) -> Scope | None:
    funcs: list[tuple[int, str]] = []
    consts: list[tuple[int, int]] = []
    in_state = False
    for o in enclosers(src, code, pos):
        window = max(0, o - 300)
        if src[o] == "{":
            header = CLASS_HEADER.search(src, window, o)
            if header:
                in_state = bool(re.search(r"\bextends\s+(?:\w+\.)?State<",
                                          header.group(0)))
                break
            params = function_params(src, code, o)
            if params is not None:
                funcs.append((o, params))
                continue
        pattern = CONST_CALL if src[o] == "(" else CONST_LITERAL
        m = pattern.search(src, max(0, o - 160), o)
        if m:
            consts.append((m.start(), m.end()))

    if any(HAS_DECL.search(src, brace, pos) for brace, _ in funcs):
        return Scope(None, "context", consts)
    with_ctx = [(b, m.group(1)) for b, p in funcs
                if (m := CONTEXT_PARAM.search(p))]
    if with_ctx:
        brace, name = with_ctx[-1]          # outermost, so closures share it
        return Scope(brace, name, consts)
    if in_state and funcs:
        return Scope(funcs[-1][0], "context", consts)
    return None


# --- Finding literals -----------------------------------------------------

@dataclass
class Found:
    path: pathlib.Path
    start: int
    end: int
    line: int
    text: str
    verdict: str
    key: str | None = None
    scope: Scope | None = None


def is_named_arg(src: str, code: bytearray, colon: int) -> bool:
    """`label:` directly inside an argument list, not a ternary's `: `."""
    m = NAME_TAIL.search(src, max(0, colon - 80), colon)
    if not m or m.group(1) not in ARG_NAMES:
        return False
    before_name = prev_code(src, code, m.start())
    return before_name >= 0 and src[before_name] in "(,"


def looks_like_prose(text: str) -> bool:
    return bool(re.search(r"[A-Za-z]", text)) and (
        " " in text.strip() or text[:1].isupper())


def group_literals(src: str, code: bytearray,
                   strings: list[tuple[int, int]]) -> list[tuple[int, int, list]]:
    """Merge adjacent literals ('a' 'b') into one span."""
    groups: list[tuple[int, int, list]] = []
    for s, e in strings:
        if groups and all(not code[k] or src[k].isspace()
                          for k in range(groups[-1][1], s)):
            gs, _, parts = groups[-1]
            groups[-1] = (gs, e, parts + [(s, e)])
        else:
            groups.append((s, e, [(s, e)]))
    return groups


def find_in_file(path: pathlib.Path, src: str, keep_english: re.Pattern | None,
                 counts: collections.Counter) -> list[Found]:
    code, strings = scan(src)
    out: list[Found] = []
    for start, end, parts in group_literals(src, code, strings):
        texts = [literal_text(src, s, e) for s, e in parts]
        text = "".join(t for t, _ in texts)
        interpolated = any(i for _, i in texts)
        if IGNORE.match(text):
            continue
        line_start = src.rfind("\n", 0, start) + 1
        line_end = src.find("\n", end)
        if IGNORE_MARKER in src[line_start:line_end if line_end >= 0 else None]:
            counts["ignored"] += 1
            continue

        p = prev_code(src, code, start)
        n = next_code(src, code, end)
        before = src[max(0, p - 80):p] if p >= 0 else ""
        prev_char = src[p] if p >= 0 else ""
        after = src[n:n + 2]
        closes_arg = after[:1] in (",", ")")

        handled = closes_arg and (
            (prev_char == "(" and TEXT_CALL.search(before))
            or (prev_char == ":" and is_named_arg(src, code, p)))
        if not handled:
            # Report prose we cannot rewrite; skip comparisons, keys, imports.
            prev2 = src[max(0, p - 1):p + 1]
            word = re.search(r"(\w+)\s*$", before)
            map_key = after[:1] == ":" and prev_char != "?"
            if (not looks_like_prose(text) or prev2 in ("==", "!=")
                    or prev_char in "[@" or after in ("==", "=>")
                    or after[:1] == "]" or map_key
                    or (word and word.group(1) in ("import", "export", "part", "case"))):
                continue
            verdict = "unhandled"
        elif keep_english and keep_english.search(text):
            verdict = "keep_english"
        elif interpolated:
            verdict = "interpolated"
        elif "{" in text or "}" in text:
            verdict = "braces"
        else:
            verdict = "safe"

        found = Found(path, start, end, src.count("\n", 0, start) + 1, text, verdict)
        if verdict == "safe":
            found.scope = resolve(src, code, start)
            if found.scope is None:
                found.verdict = "no_context"
        counts[found.verdict] += 1
        out.append(found)
    return out


# --- Keys and the ARB -----------------------------------------------------

def feature_of(path: pathlib.Path) -> str:
    parts = path.parts
    if "features" in parts:
        return parts[parts.index("features") + 1]
    return parts[1] if len(parts) > 1 else "app"


def make_key(feature: str, text: str, taken: set[str]) -> str:
    words = re.findall(r"[A-Za-z]+", re.sub(r"['’]", "", text))[:4] or ["label"]
    slug = words[0].lower() + "".join(w.capitalize() for w in words[1:])
    base = re.sub(r"\W", "", feature) + slug[0].upper() + slug[1:]
    key, n = base, 2
    while key in taken:
        key, n = f"{base}{n}", n + 1
    taken.add(key)
    return key


def append_to_arb(new: dict[str, str]) -> None:
    """Add keys before the closing brace, keeping the file's hand formatting."""
    raw = read(ARB_EN)
    nl = "\r\n" if "\r\n" in raw else "\n"
    body = raw[:raw.rstrip().rfind("}")].rstrip()
    lines = [f"  {json.dumps(k)}: {json.dumps(v, ensure_ascii=False)}"
             for k, v in new.items()]
    raw = body + f",{nl}{nl}" + f",{nl}".join(lines) + f"{nl}}}{nl}"
    json.loads(raw)
    write(ARB_EN, raw)


def read(path: pathlib.Path) -> str:
    with open(path, encoding="utf-8", newline="") as f:
        return f.read()


def write(path: pathlib.Path, text: str) -> None:
    with open(path, "w", encoding="utf-8", newline="") as f:
        f.write(text)


def keep_english_pattern() -> re.Pattern | None:
    terms: set[str] = set()
    if DRUG_REFERENCE.exists():
        terms |= set(json.loads(read(DRUG_REFERENCE)))
    if KEEP_ENGLISH.exists():
        terms |= {line.strip() for line in read(KEEP_ENGLISH).splitlines()
                  if line.strip() and not line.startswith("#")}
    if not terms:
        return None
    alternatives = "|".join(map(re.escape, sorted(terms, key=len, reverse=True)))
    return re.compile(rf"\b(?:{alternatives})\b", re.IGNORECASE)


# --- Rewriting ------------------------------------------------------------

def rewrite(path: pathlib.Path, src: str, items: list[Found]) -> str:
    nl = "\r\n" if "\r\n" in src else "\n"
    edits: dict[int, tuple[int, str]] = {}     # start -> (end, replacement)
    for f in items:
        edits[f.start] = (f.end, f"l10n.{f.key}")
        for s, e in f.scope.consts:
            edits[s] = (e, "")
        b = f.scope.decl_brace
        if b is not None and b + 1 not in edits:
            line_start = src.rfind("\n", 0, b) + 1
            indent = re.match(r"[ \t]*", src[line_start:]).group(0)
            decl = (f"final AppLocalizations l10n = "
                    f"AppLocalizations.of({f.scope.ctx_name});")
            edits[b + 1] = (b + 1, f"{nl}{indent}  {decl}")

    if not IMPORT_L10N.search(src):
        depth = len(path.relative_to(LIB).parts) - 1
        rel = "../" * depth + "l10n/app_localizations.dart"
        imports = list(re.finditer(r"^import [^\r\n]*", src, re.M))
        at = imports[-1].end() if imports else 0
        edits[at] = (at, f"{nl}import '{rel}';" if imports else f"import '{rel}';{nl}")

    for start in sorted(edits, reverse=True):
        end, replacement = edits[start]
        src = src[:start] + replacement + src[end:]
    return src


def main() -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    ap = argparse.ArgumentParser()
    ap.add_argument("--apply", action="store_true")
    ap.add_argument("--only", nargs="+", metavar="PATH",
                    help="limit to files under these paths")
    args = ap.parse_args()
    only = [pathlib.Path(p).as_posix().rstrip("/") for p in args.only or []]

    arb = json.loads(read(ARB_EN))
    taken = {k for k in arb if not k.startswith("@")}
    # A literal already in the ARB reuses that key instead of adding a duplicate.
    by_text = {v: k for k, v in arb.items()
               if not k.startswith("@") and isinstance(v, str)}
    keep_english = keep_english_pattern()

    counts: collections.Counter[str] = collections.Counter()
    found: list[Found] = []
    sources: dict[pathlib.Path, str] = {}
    for path in sorted(LIB.rglob("*.dart")):
        if (SKIP_DIRS & set(path.parts) or path.name in SKIP_FILES
                or path.name.endswith((".g.dart", ".freezed.dart"))):
            continue
        if only and not any(path.as_posix() == o or path.as_posix().startswith(o + "/")
                            for o in only):
            continue
        sources[path] = read(path)
        found += find_in_file(path, sources[path], keep_english, counts)

    new_keys: dict[str, str] = {}
    for f in found:
        if f.verdict != "safe":
            continue
        f.key = by_text.get(f.text)
        if f.key is None:
            f.key = make_key(feature_of(f.path), f.text, taken)
            by_text[f.text] = f.key
            new_keys[f.key] = f.text

    print(f"{len(found)} literals: {counts['safe']} safe, "
          f"{counts['interpolated']} interpolated, {counts['no_context']} without "
          f"a BuildContext, {counts['keep_english']} kept English, "
          f"{counts['braces']} with braces, {counts['unhandled']} unhandled "
          f"({counts['ignored']} marked {IGNORE_MARKER})\n")

    reasons = {
        "interpolated": "needs a placeholder, e.g. l10n.foo(count)",
        "no_context": "no BuildContext here; pass l10n in or move the text",
        "keep_english": "names a medicine; use a placeholder for the name",
        "braces": "ICU treats { } as syntax; rewrite by hand",
        "unhandled": "ternary, concatenation, variable or other argument",
    }
    for verdict, why in reasons.items():
        rows = [f for f in found if f.verdict == verdict]
        if rows:
            print(f"--- {verdict} ({len(rows)}) — {why}")
            for f in rows:
                print(f"    {f.path.as_posix()}:{f.line}  {ascii(f.text[:60])}")
            print()

    safe = [f for f in found if f.verdict == "safe"]
    if not args.apply:
        print(f"--- would rewrite ({len(safe)}, {len(new_keys)} new keys)")
        for f in safe:
            extra = f", un-const {len(f.scope.consts)}" if f.scope.consts else ""
            print(f"    {f.path.as_posix()}:{f.line}  {f.key}{extra}  {ascii(f.text[:50])}")
        print("\nDry run. Re-run with --apply to write the changes.")
        return 0

    per_file: dict[pathlib.Path, list[Found]] = collections.defaultdict(list)
    for f in safe:
        per_file[f.path].append(f)
    for path, items in per_file.items():
        write(path, rewrite(path, sources[path], items))
        print(f"rewrote {path.as_posix()} ({len(items)})")

    if new_keys:
        append_to_arb(new_keys)
    print(f"\nadded {len(new_keys)} key(s) to {ARB_EN.as_posix()}")
    print("Next: python tool/sync_arb.py && flutter gen-l10n && flutter analyze")
    return 0


if __name__ == "__main__":
    sys.exit(main())
