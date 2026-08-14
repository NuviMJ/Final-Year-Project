import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/assessment_record.dart';

class AssessmentStore {
  const AssessmentStore(this._preferences);

  static const String _key = 'qolguard.assessments.v1';

  static const int _maxRecords = 200;

  final SharedPreferences _preferences;

  List<AssessmentRecord> readAll() {
    final String? raw = _preferences.getString(_key);
    if (raw == null || raw.isEmpty) return const <AssessmentRecord>[];

    try {
      final List<dynamic> decoded = jsonDecode(raw) as List<dynamic>;
      final List<AssessmentRecord> records = decoded
          .map((dynamic entry) =>
              AssessmentRecord.fromJson(entry as Map<String, dynamic>))
          .toList();
      records.sort((AssessmentRecord a, AssessmentRecord b) =>
          b.takenAt.compareTo(a.takenAt));
      return records;
    } on FormatException {
      
      return const <AssessmentRecord>[];
    }
  }

  AssessmentRecord? readLatest() {
    final List<AssessmentRecord> all = readAll();
    return all.isEmpty ? null : all.first;
  }

  AssessmentRecord? readById(String id) {
    for (final AssessmentRecord record in readAll()) {
      if (record.id == id) return record;
    }
    return null;
  }

  Future<void> save(AssessmentRecord record) async {
    final List<AssessmentRecord> all = <AssessmentRecord>[record, ...readAll()];
    await _write(all.take(_maxRecords).toList());
  }

  Future<void> delete(String id) async {
    final List<AssessmentRecord> remaining = readAll()
        .where((AssessmentRecord record) => record.id != id)
        .toList();
    await _write(remaining);
  }

  Future<void> clear() => _preferences.remove(_key);

  Future<void> _write(List<AssessmentRecord> records) async {
    final String encoded = jsonEncode(
      records.map((AssessmentRecord record) => record.toJson()).toList(),
    );
    await _preferences.setString(_key, encoded);
  }
}

final FutureProvider<SharedPreferences> sharedPreferencesProvider =
    FutureProvider<SharedPreferences>((Ref ref) => SharedPreferences.getInstance());

final Provider<AssessmentStore> assessmentStoreProvider =
    Provider<AssessmentStore>((Ref ref) {
  final SharedPreferences preferences =
      ref.watch(sharedPreferencesProvider).requireValue;
  return AssessmentStore(preferences);
});

class AssessmentHistory extends Notifier<List<AssessmentRecord>> {
  @override
  List<AssessmentRecord> build() => ref.watch(assessmentStoreProvider).readAll();

  Future<void> add(AssessmentRecord record) async {
    await ref.read(assessmentStoreProvider).save(record);
    state = ref.read(assessmentStoreProvider).readAll();
  }

  Future<void> remove(String id) async {
    await ref.read(assessmentStoreProvider).delete(id);
    state = ref.read(assessmentStoreProvider).readAll();
  }

  Future<void> clear() async {
    await ref.read(assessmentStoreProvider).clear();
    state = const <AssessmentRecord>[];
  }

  AssessmentRecord? get latest => state.isEmpty ? null : state.first;
}

final NotifierProvider<AssessmentHistory, List<AssessmentRecord>>
    assessmentHistoryProvider =
    NotifierProvider<AssessmentHistory, List<AssessmentRecord>>(
  AssessmentHistory.new,
);
