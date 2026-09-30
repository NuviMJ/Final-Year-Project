import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:screenshot/screenshot.dart';

import 'package:qolguard/core/theme/app_theme.dart';
import 'package:qolguard/features/assessment/domain/symptom_report.dart';
import 'package:qolguard/features/history/domain/assessment_record.dart';
import 'package:qolguard/features/prediction/domain/prediction.dart';
import 'package:qolguard/features/share/report_share.dart';
import 'package:qolguard/features/share/report_view.dart';
import 'package:qolguard/l10n/app_localizations.dart';

AssessmentRecord _record({bool scored = true}) => AssessmentRecord.create(
      takenAt: DateTime(2026, 9, 30, 8, 15),
      medicines: <RecordedMedicine>[
        RecordedMedicine(
          name: 'Metformin',
          doseUnit: 'mg/day',
          dose: 1000,
          sideEffect: scored ? 'Nausea' : null,
          prediction: scored
              ? const Prediction(
                  riskCategory: 'Medium',
                  confidence: 0.7,
                  probabilities: <String, double>{
                    'Low': 0.2,
                    'Medium': 0.7,
                    'High': 0.1,
                  },
                  modelVersion: 'test',
                )
              : null,
        ),
      ],
      symptoms: scored
          ? const <SymptomReport>[
              SymptomReport(sideEffect: 'Nausea', severity: 'Moderate'),
            ]
          : const <SymptomReport>[],
      answers: <String, Object>{
        'Age': 54.0,
        'Gender': 'Female',
        'Treatment_Duration_Days': 274.0,
        'Sleep_Quality': 7.0,
        'Alcohol_Use': 'No_Alcohol',
        'Dietary_Habits': 'healthy',
      },
      noSideEffectsReported: !scored,
    );

Future<void> _pump(WidgetTester tester, String language, AssessmentRecord record) {
  final AppLocalizations l10n = lookupAppLocalizations(Locale(language));
  return tester.pumpWidget(MaterialApp(
    home: Material(
      child: SingleChildScrollView(
        child: ReportView(record: record, l10n: l10n),
      ),
    ),
  ));
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    await initializeDateFormatting('si');
  });

  group('ReportView', () {
    for (final String language in <String>['en', 'si']) {
      testWidgets('lays out a scored assessment in $language',
          (WidgetTester tester) async {
        await _pump(tester, language, _record());
        expect(tester.takeException(), isNull);
        expect(find.textContaining('Metformin'), findsOneWidget);
      });

      testWidgets('lays out a no-side-effects day in $language',
          (WidgetTester tester) async {
        await _pump(tester, language, _record(scored: false));
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('includes the result, answers and disclaimer',
        (WidgetTester tester) async {
      await _pump(tester, 'en', _record());
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.textContaining('Medium 70.0%'), findsOneWidget);
      expect(find.text('No alcohol'), findsOneWidget);
      expect(find.text('6 to 12 months'), findsOneWidget);
      expect(find.textContaining('does not diagnose'), findsOneWidget);
    });
  });

  for (final String language in <String>['en', 'si']) {
    testWidgets('draws the report off-screen in $language, as sharing does',
        (WidgetTester tester) async {
      final AppLocalizations l10n = lookupAppLocalizations(Locale(language));
      late BuildContext host;
      await tester.pumpWidget(MaterialApp(
        home: Builder(builder: (BuildContext context) {
          host = context;
          return const SizedBox();
        }),
      ));

      Uint8List? png;
      await tester.runAsync(() async {
        png = await ScreenshotController().captureFromLongWidget(
          Theme(
            data: AppTheme.light,
            child: Material(child: ReportView(record: _record(), l10n: l10n)),
          ),
          context: host,
          pixelRatio: 2,
          delay: Duration.zero,
          constraints: const BoxConstraints.tightFor(width: ReportView.width),
        );
      });

      expect(tester.takeException(), isNull);
      expect(png, isNotNull);
      // PNG signature.
      expect(png!.sublist(1, 4), ascii.encode('PNG'));
    });
  }

  test('wraps the report image in a PDF', () async {
    // A 1x1 PNG stands in for the rendered report.
    final Uint8List png = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNkYAAAAAYAAjCB0C8AAAAASUVORK5CYII=');
    final Uint8List pdf = await reportPdf(png);
    expect(ascii.decode(pdf.sublist(0, 5)), '%PDF-');
  });
}
