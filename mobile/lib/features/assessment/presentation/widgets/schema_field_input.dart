import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../medications/domain/medication.dart';
import '../../domain/duration_band.dart';
import '../../domain/onset_band.dart';
import '../../domain/sleep_quality_scale.dart';
import '../../domain/field_spec.dart';
import '../../../../l10n/app_localizations.dart';
import '../option_labels.dart';
import '../../../../core/localization/model_values.dart';


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
            _label(AppLocalizations.of(context)),
            style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
          ),
          if (_description(context) case final String description
              when description.isNotEmpty) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              description,
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
          const SizedBox(height: 8),
         
          if (spec.name == 'Age')
            _WholeNumberField(
              value: (value as num).toDouble(),
              min: spec.min!,
              max: spec.max!,
              onChanged: onChanged,
            )
          else if (spec.name == SleepQualityScale.fieldName &&
              SleepQualityScale.covers(spec.min!, spec.max!))
            _LabelledScaleInput(
              value: (value as num).toDouble(),
              onChanged: onChanged,
            )
          else if (spec.name == DurationBand.fieldName)
            _DurationBandInput(
              value: (value as num).toDouble(),
              onChanged: onChanged,
            )
          else if (spec.name == OnsetBand.fieldName)
            _OnsetBandInput(
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
              field: spec.name,
              options: spec.allowedValues!,
              value: value as String,
              onChanged: onChanged,
            )
          else
            _DropdownInput(
              field: spec.name,
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

  String _label(AppLocalizations l10n) =>
      fieldLabel(l10n, spec.name, spec.label);

  String? _description(BuildContext context) => fieldDescription(
      AppLocalizations.of(context), spec.name, spec.description);

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

class _WholeNumberField extends StatefulWidget {
  const _WholeNumberField({
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final double value;
  final double min;
  final double max;
  final ValueChanged<Object> onChanged;

  @override
  State<_WholeNumberField> createState() => _WholeNumberFieldState();
}

class _WholeNumberFieldState extends State<_WholeNumberField> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.value.round().toString());
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handle(String raw) {
    final int low = widget.min.round();
    final int high = widget.max.round();
    final int? parsed = int.tryParse(raw.trim());

    // An empty or out-of-range entry keeps the last valid value, so the form
    // can never submit something the model has not seen.
    if (parsed == null) {
      setState(() => _error = raw.trim().isEmpty
          ? null
          : AppLocalizations.of(context).assessmentEnterNumber);
      return;
    }
    if (parsed < low || parsed > high) {
      setState(() => _error =
          AppLocalizations.of(context).assessmentMustBeBetween(low, high));
      return;
    }
    setState(() => _error = null);
    widget.onChanged(parsed.toDouble());
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int low = widget.min.round();
    final int high = widget.max.round();

    return TextField(
      controller: _controller,
      keyboardType: TextInputType.number,
      inputFormatters: <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        helperText: l10n.assessmentBetween(low, high),
        errorText: _error,
        suffixText: l10n.assessmentYears,
      ),
      onChanged: _handle,
    );
  }
}

class _LabelledScaleInput extends StatelessWidget {
  const _LabelledScaleInput({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final int current = value.round();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final int option in SleepQualityScale.values)
          ChoiceChip(
            label: Text(sleepQualityWithFace(l10n, option.toDouble())),
            selected: option == current,
            onSelected: (_) => onChanged(option.toDouble()),
          ),
      ],
    );
  }
}

class _DurationBandInput extends StatelessWidget {
  const _DurationBandInput({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _BandChips<DurationBand>(
      options: DurationBand.values,
      labelOf: (DurationBand band) => band.label(l10n),
      selected: DurationBand.forDays(value),
      onSelected: (DurationBand band) =>
          onChanged(band.representativeDays.toDouble()),
    );
  }
}

class _OnsetBandInput extends StatelessWidget {
  const _OnsetBandInput({required this.value, required this.onChanged});

  final double value;
  final ValueChanged<Object> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return _BandChips<OnsetBand>(
      options: OnsetBand.values,
      labelOf: (OnsetBand band) => band.label(l10n),
      selected: OnsetBand.forDays(value),
      onSelected: (OnsetBand band) =>
          onChanged(band.representativeDays.toDouble()),
    );
  }
}

/// Chips rather than a dropdown: a dropdown opens an overlay that the bottom
/// bar and the action row can squeeze, hiding options.
class _BandChips<T> extends StatelessWidget {
  const _BandChips({
    required this.options,
    required this.labelOf,
    required this.selected,
    required this.onSelected,
  });

  final List<T> options;
  final String Function(T option) labelOf;
  final T selected;
  final ValueChanged<T> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: <Widget>[
        for (final T option in options)
          ChoiceChip(
            label: Text(labelOf(option)),
            selected: option == selected,
            onSelected: (_) => onSelected(option),
          ),
      ],
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
    required this.field,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String field;
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
                  label: Text(valueLabel(AppLocalizations.of(context), field, option),
                      textAlign: TextAlign.center),
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
    required this.field,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final String field;
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
                child: Text(valueLabel(AppLocalizations.of(context), field, option)),
              ))
          .toList(),
      onChanged: (String? selected) {
        if (selected != null) onChanged(selected);
      },
    );
  }
}
