import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/symptom_report.dart';

/// The side effects step: whether there are any, and if so which.
class SymptomSelector extends StatefulWidget {
  const SymptomSelector({
    super.key,
    required this.options,
    required this.severityOptions,
    required this.selected,
    required this.hasSideEffects,
    required this.onHasSideEffectsChanged,
    required this.onToggle,
    required this.onSeverityChanged,
    this.errorText,
  });

  final List<String> options;
  final List<String> severityOptions;
  final List<SymptomReport> selected;
  final bool? hasSideEffects;
  final ValueChanged<bool> onHasSideEffectsChanged;
  final ValueChanged<String> onToggle;
  final void Function(String sideEffect, String severity) onSeverityChanged;
  final String? errorText;

  @override
  State<SymptomSelector> createState() => _SymptomSelectorState();
}

class _SymptomSelectorState extends State<SymptomSelector> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Have you experienced any side effects from your medication?',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: <Widget>[
            Expanded(
              child: _ChoiceCard(
                label: 'Yes',
                icon: Icons.sentiment_dissatisfied_outlined,
                selected: widget.hasSideEffects == true,
                onTap: () => widget.onHasSideEffectsChanged(true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _ChoiceCard(
                label: 'No',
                icon: Icons.sentiment_satisfied_outlined,
                selected: widget.hasSideEffects == false,
                onTap: () => widget.onHasSideEffectsChanged(false),
              ),
            ),
          ],
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: switch (widget.hasSideEffects) {
            true => _SymptomList(
                options: widget.options,
                severityOptions: widget.severityOptions,
                selected: widget.selected,
                showAll: _showAll,
                onShowAll: () => setState(() => _showAll = true),
                onToggle: widget.onToggle,
                onSeverityChanged: widget.onSeverityChanged,
                errorText: widget.errorText,
              ),
            false => const _GoodNews(),
            _ => const SizedBox(width: double.infinity),
          },
        ),
      ],
    );
  }
}

class _GoodNews extends StatelessWidget {
  const _GoodNews();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.riskLow.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.riskLow.withValues(alpha: 0.45)),
      ),
      child: Column(
        children: <Widget>[
          const Text('🎉', style: TextStyle(fontSize: 40)),
          const SizedBox(height: 10),
          Text(
            'Oh, that’s good news!',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'You haven’t experienced any side effects. '
            'Tell us about your daily life next.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SymptomList extends StatelessWidget {
  const _SymptomList({
    required this.options,
    required this.severityOptions,
    required this.selected,
    required this.showAll,
    required this.onShowAll,
    required this.onToggle,
    required this.onSeverityChanged,
    this.errorText,
  });

  final List<String> options;
  final List<String> severityOptions;
  final List<SymptomReport> selected;
  final bool showAll;
  final VoidCallback onShowAll;
  final ValueChanged<String> onToggle;
  final void Function(String sideEffect, String severity) onSeverityChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Map<String, SymptomReport> chosen = <String, SymptomReport>{
      for (final SymptomReport s in selected) s.sideEffect: s,
    };
    final bool atLimit = selected.length >= SymptomReport.maxPerAssessment;

    // Anything already ticked stays visible even if it is not a common one.
    final List<String> visible = showAll
        ? options
        : options
            .where((String o) =>
                SymptomReport.common.contains(o) || chosen.containsKey(o))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const SizedBox(height: 20),
        Text(
          'Select the side effects you experienced',
          style:
              theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 2),
        Text(
          'Choose up to ${SymptomReport.maxPerAssessment}, and say how bad '
          'each one is.',
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 8),
        for (final String option in visible)
          _SymptomTile(
            name: option,
            report: chosen[option],
            severityOptions: severityOptions,
            enabled: chosen.containsKey(option) || !atLimit,
            onToggle: () => onToggle(option),
            onSeverityChanged: (String value) =>
                onSeverityChanged(option, value),
          ),
        if (!showAll && visible.length < options.length)
          TextButton.icon(
            onPressed: onShowAll,
            icon: const Icon(Icons.expand_more),
            label: Text(
              'Show all effects (${options.length - visible.length} more)',
            ),
          ),
        if (atLimit)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'That’s the most you can report at once.',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              errorText!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ),
      ],
    );
  }
}

class _SymptomTile extends StatelessWidget {
  const _SymptomTile({
    required this.name,
    required this.report,
    required this.severityOptions,
    required this.enabled,
    required this.onToggle,
    required this.onSeverityChanged,
  });

  final String name;
  final SymptomReport? report;
  final List<String> severityOptions;
  final bool enabled;
  final VoidCallback onToggle;
  final ValueChanged<String> onSeverityChanged;

  bool get _selected => report != null;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: _selected ? 1 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _selected ? AppColors.primary : theme.dividerColor,
          width: _selected ? 2 : 1,
        ),
      ),
      child: Column(
        children: <Widget>[
          CheckboxListTile(
            value: _selected,
            onChanged: enabled ? (_) => onToggle() : null,
            controlAffinity: ListTileControlAffinity.leading,
            title: Text(
              SymptomReport.labelFor(name),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: _selected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: _selected
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                    child: SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        segments: severityOptions
                            .map((String option) => ButtonSegment<String>(
                                  value: option,
                                  label:
                                      Text(option, textAlign: TextAlign.center),
                                ))
                            .toList(),
                        selected: <String>{report!.severity},
                        showSelectedIcon: false,
                        onSelectionChanged: (Set<String> selection) =>
                            onSeverityChanged(selection.first),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

class _ChoiceCard extends StatelessWidget {
  const _ChoiceCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.10)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? AppColors.primary : theme.dividerColor,
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: <Widget>[
              Icon(
                icon,
                size: 28,
                color: selected
                    ? AppColors.primary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
