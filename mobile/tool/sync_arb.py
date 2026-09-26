#!/usr/bin/env python3
"""Keep app_si.arb in step with app_en.arb.

Every English key gets a Sinhala entry. Keys you have not translated yet hold
the English text, so the app never shows a blank or a crash; they are listed in
tool/l10n_status.json and printed here so you know what is left.

A key counts as translated once its Sinhala value differs from the English.
Keys that are meant to read the same in both go in IDENTICAL below.

    python tool/sync_arb.py
"""
from __future__ import annotations

import json
import pathlib
import re
import sys

L10N = pathlib.Path("lib/l10n")
ARB_EN, ARB_SI = L10N / "app_en.arb", L10N / "app_si.arb"
STATUS = pathlib.Path("tool/l10n_status.json")

# Legitimately the same in both locales.
IDENTICAL = {"languageEnglish", "languageSinhala"}

# Reviewed by a Sinhala speaker before release, per the thesis safety note.
CLINICAL = re.compile(
    r"sideEffect|symptom|severity|risk|dose|dosage|medication|seriousness",
    re.IGNORECASE,
)

# Health wording a native speaker must check even once it is translated. Keys
# go on tool/l10n_reviewed.txt once checked, one per line.
REVIEW = re.compile(
    r"sideEffect|symptom|severity|risk|dose|dosage|seriousness"
    r"|^medicalDisclaimer$|^predictionSummary|^trendsMessage|Help$"
    r"|NotAHealthCheck|ChooseEvery",
    re.IGNORECASE,
)
REVIEWED = pathlib.Path("tool/l10n_reviewed.txt")
# Translated as whole files rather than through the ARB.
CONTENT = ["lib/features/learn/domain/library_si.dart"]

# A real placeholder is an identifier closed by "}" or opened into ",plural".
PLACEHOLDER = re.compile(r"\{\s*([A-Za-z_]\w*)\s*[,}]")


def entries(arb: dict) -> dict:
    return {k: v for k, v in arb.items()
            if not k.startswith("@") and isinstance(v, str)}


def main() -> int:
    sys.stdout.reconfigure(encoding="utf-8")
    en_raw = json.loads(ARB_EN.read_text(encoding="utf-8"))
    si_raw = json.loads(ARB_SI.read_text(encoding="utf-8")) if ARB_SI.exists() \
        else {"@@locale": "si"}
    en, si = entries(en_raw), entries(si_raw)

    added, stale, mismatched, untranslated, clinical = [], [], [], [], []

    for key, text in en.items():
        if key not in si:
            si_raw[key] = text          # English placeholder
            added.append(key)
        else:
            want = set(PLACEHOLDER.findall(text))
            got = set(PLACEHOLDER.findall(si[key]))
            if want != got:
                mismatched.append((key, sorted(want), sorted(got)))

    for key in list(si):
        if key not in en:
            stale.append(key)
            si_raw.pop(key, None)
            si_raw.pop(f"@{key}", None)

    # Metadata belongs only in the template file.
    for key in [k for k in si_raw if k.startswith("@") and not k.startswith("@@")]:
        si_raw.pop(key)

    ordered = {"@@locale": "si"}
    for key in en_raw:
        if key in si_raw and not key.startswith("@"):
            ordered[key] = si_raw[key]
    ARB_SI.write_text(json.dumps(ordered, ensure_ascii=False, indent=2) + "\n",
                      encoding="utf-8")

    for key, text in entries(ordered).items():
        if key in IDENTICAL:
            continue
        if text == en.get(key):
            untranslated.append(key)
            if CLINICAL.search(key):
                clinical.append(key)

    reviewed = set()
    if REVIEWED.exists():
        reviewed = {line.strip() for line in REVIEWED.read_text(encoding="utf-8").splitlines()
                    if line.strip() and not line.startswith("#")}
    to_review = sorted(k for k in en if REVIEW.search(k) and k not in reviewed
                       and k not in untranslated)
    content = [c for c in CONTENT if c not in reviewed]

    STATUS.write_text(json.dumps({
        "total": len(en),
        "untranslated": sorted(untranslated),
        "clinical_needing_review": sorted(clinical),
        "translated_needing_native_review": to_review,
        "content_needing_native_review": content,
    }, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

    done = len(en) - len(untranslated)
    pct = (done / len(en) * 100) if en else 0
    print(f"{done}/{len(en)} translated ({pct:.0f}%)")
    if added:
        print(f"  added {len(added)} key(s) with English placeholder")
    if stale:
        print(f"  removed {len(stale)} stale key(s): {', '.join(stale)}")
    if mismatched:
        print("\n  PLACEHOLDER MISMATCH — gen-l10n will fail on these:")
        for key, want, got in mismatched:
            print(f"    {key}: en has {want}, si has {got}")
    if clinical:
        print(f"\n  {len(clinical)} clinical term(s) still English — "
              "these need a native speaker, not machine translation:")
        for key in clinical:
            print(f"    {key}")
    if to_review or content:
        print(f"\n  {len(to_review)} translated health string(s) and "
              f"{len(content)} content file(s) await native-speaker review; "
              f"list them in {REVIEWED} once checked.")
    print(f"\nFull list: {STATUS}")
    return 1 if mismatched else 0


if __name__ == "__main__":
    sys.exit(main())
