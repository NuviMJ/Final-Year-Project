import 'package:flutter/material.dart';

import '../../../medications/domain/medication.dart';
import '../../domain/duration_band.dart';
import '../../domain/field_spec.dart';


class SchemaFieldInput extends StatelessWidget {
  const SchemaFieldInput({
    super.key,
    required this.spec,
    required this.value,
    required this.onChanged,
    this.medication,
    this.errorText,
  });

  final FieldSpec spec;
  final Object value;
  final ValueChanged<Object> onChanged;

  final Medication? medication;

  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            _label,
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (spec.description != null && spec.description!.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              spec.description!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
         
          if (spec.name == 'Age')
            _WholeNumberDropdown(
              value: (value as num).toDouble(),
              min: spec.min!,
              max: spec.max!,
              suffix: 'years',
              onChanged: onChanged,
            )
          else if (spec.name == DurationBand.fieldName)
            _DurationBandInput(
              value: (value as num).toDouble(),
              onChanged: onChanged,
            )
          else if (spec.isNumeric)
            _NumericInput(
              spec: spec,
              value: (value as num).toDouble(),
              min: _min,
              max: _max,
              unit: _unit,
              onChanged: onChanged,
            )
          else if (spec.allowedValues!.length <= 3)
            _SegmentedInput(
              options: spec.allowedValues!,
              value: value as String,
              onChanged: onChanged,
            )
          else
            _DropdownInput(
              options: spec.allowedValues!,
              value: value as String,
              onChanged: onChanged,
            ),
          if (errorText != null) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              errorText!,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.error),
            ),
          ],
        ],
      ),
    );
  }

  String get _label => spec.name == 'Dosage_mg' ? 'Daily dose' : spec.label;

  String? get _unit => spec.name == 'Dosage_mg' ? medication?.doseUnit : null;

  double get _min =>
      spec.name == 'Dosage_mg' && medication != null
          ? medication!.doseMin
          : spec.min!;

  double get _max =>
      spec.name == 'Dosage_mg' && medication != null
          ? medication!.doseMax
          : spec.max!;
}

class _WholeNumberDropdown extends StatelessWidget {
  const _WholeNumberDropdown({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.suffix,
  });

  final double value;
  final double min;
  final double max;
  final String? suffix;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final int low = min.round();
    final int high = max.round();
    final int current = value.round().clamp(low, high);

    return DropdownButtonFormField<int>(
      value: current,
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: <DropdownMenuItem<int>>[
        for (int option = low; option <= high; option++)
          DropdownMenuItem<int>(
            value: option,
            child: Text(suffix == null ? '$option' : '$option $suffix'),
          ),
      ],
      onChanged: (int? selected) {
        if (selected != null) onChanged(selected.toDouble());
      },
    );
  }
}

class _DurationBandInput extends StatelessWidget {
  const _DurationBandInput({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final DurationBand current = DurationBand.forDays(value);

    return DropdownButtonFormField<String>(
      value: current.label,
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: DurationBand.all
          .map((DurationBand band) => DropdownMenuItem<String>(
                value: band.label,
                child: Text(band.label),
              ))
          .toList(),
      onChanged: (String? selected) {
        if (selected == null) return;
        final DurationBand band = DurationBand.all
            .firstWhere((DurationBand candidate) => candidate.label == selected);
        onChanged(band.representativeDays.toDouble());
      },
    );
  }
}

class _NumericInput extends StatelessWidget {
  const _NumericInput({
    required this.spec,
    required this.value,
    required this.min,
    required this.max,
    required this.unit,
    required this.onChanged,
  });

  final FieldSpec spec;
  final double value;
  final double min;
  final double max;
  final String? unit;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final double clamped = value.clamp(min, max);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(_format(min), style: theme.textTheme.bodySmall),
            Text(
              unit == null ? _format(clamped) : '${_format(clamped)} $unit',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(_format(max), style: theme.textTheme.bodySmall),
          ],
        ),
        Slider(
          value: clamped,
          min: min,
          max: max,
          divisions: _divisions,
          label: _format(clamped),
          onChanged: (double updated) =>
              onChanged(_divisions == null ? updated : updated.roundToDouble()),
        ),
      ],
    );
  }

  /// Snap to whole units where fractions are meaningless — you cannot take 2.5
  /// other medications. Left continuous where the span is too wide for one
  /// division per unit to be usable.
  int? get _divisions {
    final double span = max - min;
    if (span <= 0) return null;
    if (span <= 60) return span.round();
    if (span <= 2000) return (span / 10).round();
    return (span / 100).round();
  }

  static String _format(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toStringAsFixed(1);
}

class _SegmentedInput extends StatelessWidget {
  const _SegmentedInput({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<String> options;
  final String value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        segments: options
            .map((String option) => ButtonSegment<String>(
                  value: option,
                  label: Text(_humanise(option), textAlign: TextAlign.center),
                ))
            .toList(),
        selected: <String>{value},
        showSelectedIcon: false,
        onSelectionChanged: (Set<String> selection) =>
            onChanged(selection.first),
      ),
    );
  }
}

class _DropdownInput extends StatelessWidget {
  const _DropdownInput({
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<String> options;
  final String value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: const InputDecoration(border: OutlineInputBorder()),
      items: options
          .map((String option) => DropdownMenuItem<String>(
                value: option,
                child: Text(_humanise(option)),
              ))
          .toList(),
      onChanged: (String? selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}

/// The model's category values are machine labels — `No_Alcohol`, `unhealthy`,
/// `mild`. They are sent to the API verbatim, but shown to the patient tidied
/// up.
String _humanise(String value) {
  final String spaced = value.replaceAll('_', ' ');
  return spaced[0].toUpperCase() + spaced.substring(1);
}
