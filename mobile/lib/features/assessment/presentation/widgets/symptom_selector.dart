import 'package:flutter/material.dart';

import '../../domain/symptom_report.dart';

/// Collects several side effects, each with its own severity.
class SymptomSelector extends StatelessWidget {
  const SymptomSelector({
    super.key,
    required this.options,
    required this.severityOptions,
    required this.selected,
    required this.onToggle,
    required this.onSeverityChanged,
    this.errorText,
  });

  final List<String> options;
  final List<String> severityOptions;
  final List<SymptomReport> selected;
  final ValueChanged<String> onToggle;
  final void Function(String sideEffect, String severity) onSeverityChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Set<String> chosen =
        selected.map((SymptomReport s) => s.sideEffect).toSet();
    final List<String> remaining =
        options.where((String o) => !chosen.contains(o)).toList();
    final bool atLimit = selected.length >= SymptomReport.maxPerAssessment;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Which effects have you noticed?',
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
        const SizedBox(height: 12),
        for (final SymptomReport symptom in selected)
          _SelectedSymptom(
            symptom: symptom,
            severityOptions: severityOptions,
            canRemove: selected.length > 1,
            onRemove: () => onToggle(symptom.sideEffect),
            onSeverityChanged: (String value) =>
                onSeverityChanged(symptom.sideEffect, value),
          ),
        if (remaining.isNotEmpty && !atLimit) ...<Widget>[
          const SizedBox(height: 4),
          DropdownButtonFormField<String>(
            value: null,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.add),
              hintText: 'Add another effect',
            ),
            items: remaining
                .map((String option) => DropdownMenuItem<String>(
                      value: option,
                      child: Text(option),
                    ))
                .toList(),
            onChanged: (String? selection) {
              if (selection != null) onToggle(selection);
            },
          ),
        ],
        if (atLimit) ...<Widget>[
          const SizedBox(height: 4),
          Text(
            'That is the most you can report at once.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
        if (errorText != null) ...<Widget>[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.error),
          ),
        ],
      ],
    );
  }
}

class _SelectedSymptom extends StatelessWidget {
  const _SelectedSymptom({
    required this.symptom,
    required this.severityOptions,
    required this.canRemove,
    required this.onRemove,
    required this.onSeverityChanged,
  });

  final SymptomReport symptom;
  final List<String> severityOptions;
  final bool canRemove;
  final VoidCallback onRemove;
  final ValueChanged<String> onSeverityChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 8, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    symptom.sideEffect,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (canRemove)
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Remove ${symptom.sideEffect}',
                    onPressed: onRemove,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<String>(
                segments: severityOptions
                    .map((String option) => ButtonSegment<String>(
                          value: option,
                          label: Text(option, textAlign: TextAlign.center),
                        ))
                    .toList(),
                selected: <String>{symptom.severity},
                showSelectedIcon: false,
                onSelectionChanged: (Set<String> selection) =>
                    onSeverityChanged(selection.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
