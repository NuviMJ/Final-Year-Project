/// A medication the model can assess, with the dose limits that apply to it.
///
/// Written by hand rather than generated. The API surface is small enough that
/// code generation would add a build step without saving meaningful work, and
/// the field names have to mirror the backend's exported schema exactly, which
/// is easier to see when it is written out.
class Medication {
  const Medication({
    required this.name,
    required this.drugClass,
    required this.doseUnit,
    required this.doseMin,
    required this.doseMax,
    required this.typicalDoses,
  });

  final String name;
  final String drugClass;

  /// "mg/day" for most drugs, "IU/day" for insulin. Shown next to the dose
  /// field so the patient is never guessing which unit is meant.
  final String doseUnit;

  /// Limits for this specific drug. The model's global dose range spans every
  /// medication at once, so it would accept 500 mg of atorvastatin; these are
  /// the values worth enforcing in the form.
  final double doseMin;
  final double doseMax;

  final List<double> typicalDoses;

  factory Medication.fromJson(Map<String, dynamic> json) {
    return Medication(
      name: json['name'] as String,
      drugClass: json['drug_class'] as String,
      doseUnit: json['dose_unit'] as String,
      doseMin: (json['dose_min'] as num).toDouble(),
      doseMax: (json['dose_max'] as num).toDouble(),
      typicalDoses: (json['typical_doses'] as List<dynamic>? ?? <dynamic>[])
          .map((dynamic value) => (value as num).toDouble())
          .toList(),
    );
  }

  /// e.g. "10–80 mg/day"
  String get doseRangeLabel =>
      '${_trim(doseMin)}–${_trim(doseMax)} $doseUnit';

  /// The dose offered before the patient changes it: the middle of the doses
  /// this drug is actually prescribed at, not the arithmetic midpoint of the
  /// permitted range. "40 mg" is a dose a patient recognises; "45 mg" is not.
  double get defaultDose => typicalDoses.isEmpty
      ? (doseMin + doseMax) / 2
      : typicalDoses[typicalDoses.length ~/ 2];

  /// e.g. "40 mg/day"
  String doseLabel(double dose) => '${_trim(dose)} $doseUnit';

  static String _trim(double value) =>
      value == value.roundToDouble() ? value.toInt().toString() : value.toString();
}
