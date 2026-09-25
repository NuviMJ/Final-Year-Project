import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'locale_store.dart';

/// Compact EN / සිං pill for screen headers.
///
/// Settings keeps the full selector; this is the one-tap shortcut so a patient
/// can switch without hunting through menus.
class LanguageSwitch extends ConsumerWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ThemeData theme = Theme.of(context);
    final AppLanguage current = ref.watch(localeProvider);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: AppLanguage.values.map((AppLanguage language) {
          final bool selected = language == current;
          return Semantics(
            selected: selected,
            button: true,
            label: language.label,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: selected
                  ? null
                  : () => ref.read(localeProvider.notifier).select(language),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: selected
                      ? theme.colorScheme.primary
                      : Colors.transparent,
                ),
                child: Text(
                  language.shortLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: selected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
