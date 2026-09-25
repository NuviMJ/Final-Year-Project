import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/history/data/assessment_store.dart';

/// The languages the interface is offered in.
///
/// Medication names are never translated: a drug carries the same name
/// worldwide, and the values sent to the prediction service must stay exactly
/// as the model was trained on.
enum AppLanguage {
  english('en', 'English', 'EN'),
  sinhala('si', 'සිංහල', 'සිං');

  const AppLanguage(this.code, this.label, this.shortLabel);

  final String code;

  /// Written in its own language, so it reads the same whichever is active.
  final String label;

  /// Two or three characters, for the compact switcher in the header.
  final String shortLabel;

  Locale get locale => Locale(code);

  static AppLanguage fromCode(String? code) => values.firstWhere(
        (AppLanguage l) => l.code == code,
        orElse: () => AppLanguage.english,
      );

  static const List<Locale> supportedLocales =
      <Locale>[Locale('en'), Locale('si')];
}

class LocaleController extends Notifier<AppLanguage> {
  static const String _key = 'app_language';

  @override
  AppLanguage build() {
    final SharedPreferences? prefs = ref.watch(sharedPreferencesProvider).value;
    return AppLanguage.fromCode(prefs?.getString(_key));
  }

  Future<void> select(AppLanguage language) async {
    state = language;
    final SharedPreferences? prefs = ref.read(sharedPreferencesProvider).value;
    await prefs?.setString(_key, language.code);
  }
}

final NotifierProvider<LocaleController, AppLanguage> localeProvider =
    NotifierProvider<LocaleController, AppLanguage>(LocaleController.new);
