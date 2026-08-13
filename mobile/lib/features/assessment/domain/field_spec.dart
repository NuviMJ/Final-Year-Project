/// One input field, exactly as the backend's `/schema` endpoint describes it.
///
/// The form is built from these rather than from hard-coded widgets, so the
/// ranges the app enforces are always the ranges the model was trained on. If
/// the model is retrained with wider limits, the app picks them up without a
/// release — and, just as importantly, cannot drift into accepting values the
/// model has never seen.
class FieldSpec {
  const FieldSpec({
    required this.name,
    required this.type,
    required this.required,
    this.description,
    this.min,
    this.max,
    this.allowedValues,
  });

  final String name;

  /// `number`, `categorical`, or `categorical_ordered`. Ordered categories are
  /// rendered as a segmented control so the ranking is visible; unordered ones
  /// become a dropdown.
  final String type;

  final bool required;
  final String? description;
  final double? min;
  final double? max;
  final List<String>? allowedValues;

  bool get isNumeric => type == 'number';
  bool get isOrdered => type == 'categorical_ordered';

  /// A readable label from the field name: `Treatment_Duration_Days` becomes
  /// "Treatment duration days". The backend's names mirror the model's columns,
  /// which are not written for patients to read.
  String get label {
    final String words = name.replaceAll('_', ' ').toLowerCase();
    return words[0].toUpperCase() + words.substring(1);
  }

  /// A sensible starting value, so every field is valid before the patient
  /// touches it. An assessment can then never be submitted incomplete, and the
  /// 422 path becomes a genuine safety net rather than routine friction.
  Object initialValue() {
    if (isNumeric) {
      final double midpoint = ((min ?? 0) + (max ?? 0)) / 2;
      return _isWholeNumberField ? midpoint.roundToDouble() : midpoint;
    }
    return allowedValues!.first;
  }

  /// Fields the model treats as counts or whole units. Presenting 3.5 days of
  /// treatment or 2.5 concomitant drugs would be meaningless to a patient.
  bool get _isWholeNumberField => const <String>{
        'Age',
        'Treatment_Duration_Days',
        'Concomitant_Drug_Count',
        'Sleep_Quality',
        'Daily_Steps',
        'Onset_Days',
      }.contains(name);

  factory FieldSpec.fromJson(Map<String, dynamic> json) {
    return FieldSpec(
      name: json['name'] as String,
      type: json['type'] as String,
      required: json['required'] as bool? ?? true,
      description: json['description'] as String?,
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      allowedValues: (json['allowed_values'] as List<dynamic>?)
          ?.map((dynamic value) => value as String)
          .toList(),
    );
  }
}

/// The full input contract returned by `/schema`.
class AssessmentSchema {
  const AssessmentSchema({required this.fields, required this.classOrder});

  final List<FieldSpec> fields;
  final List<String> classOrder;

  FieldSpec? byName(String name) {
    for (final FieldSpec field in fields) {
      if (field.name == name) return field;
    }
    return null;
  }

  factory AssessmentSchema.fromJson(Map<String, dynamic> json) {
    return AssessmentSchema(
      fields: (json['fields'] as List<dynamic>)
          .map((dynamic entry) =>
              FieldSpec.fromJson(entry as Map<String, dynamic>))
          .toList(),
      classOrder: (json['class_order'] as List<dynamic>)
          .map((dynamic value) => value as String)
          .toList(),
    );
  }
}
