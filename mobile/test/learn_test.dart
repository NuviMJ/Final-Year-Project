import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/features/learn/domain/article.dart';

void main() {
  group('Library', () {
    test('every article has an id, a summary and a body', () {
      for (final Article article in Library.en.articles) {
        expect(article.id, isNotEmpty, reason: '${article.title} has no id');
        expect(article.title, isNotEmpty);
        expect(article.summary, isNotEmpty);
        expect(article.body, isNotEmpty,
            reason: '${article.title} has no content');
      }
    });

    test('ids are unique, so routing cannot resolve two articles', () {
      final Set<String> ids =
          Library.en.articles.map((Article article) => article.id).toSet();

      expect(ids.length, Library.en.articles.length);
    });

    test('looks an article up by id and returns null for an unknown one', () {
      expect(Library.en.byId('fatigue')?.title, 'Tiredness that does not lift');
      expect(Library.en.byId('not-a-real-article'), isNull);
    });

    test('covers the model\'s strongest predictors', () {
      // The library exists to explain the factors that actually drive the
      // prediction, not generic health advice. Severity, diet, sleep and
      // activity are four of the model's five leading features.
      final Set<String> ids =
          Library.en.articles.map((Article article) => article.id).toSet();

      expect(ids, containsAll(<String>[
        'why-severity-matters',
        'diet',
        'sleep',
        'activity',
      ]));
    });

    test('explains how the prediction works and states its limits', () {
      // 36.7% of survey respondents worried about misleading predictions and
      // 22.4% distrusted AI in health decisions; an unexplained risk band
      // invites exactly that.
      final Article? howItWorks = Library.en.byId('how-it-works');
      expect(howItWorks, isNotNull);

      final String text = howItWorks!.body.join(' ').toLowerCase();
      expect(text, contains('limit'));
      expect(text, contains('ten medications'));
      expect(text, contains('stored only on this phone'));
    });

    test('never instructs a patient to change their medication', () {
      for (final Article article in Library.en.articles) {
        final String text =
            '${article.body.join(' ')} ${article.footnote ?? ''}'.toLowerCase();

        expect(text, isNot(contains('stop taking')),
            reason: '${article.title} tells the reader to stop a medication');
        expect(text, isNot(contains('you should take')),
            reason: '${article.title} prescribes');
        expect(text, isNot(contains('increase your dose')),
            reason: '${article.title} prescribes a dose change');
      }
    });

    test('directs the reader to a professional where it matters', () {
      final Article? result = Library.en.byId('understanding-your-result');
      final String text = result!.body.join(' ').toLowerCase();

      expect(text, contains('appointment'));
      expect(text, contains('not a diagnosis'));
    });
  });

  group('Sinhala library', () {
    test('has the same articles, in the same order, as the English one', () {
      expect(Library.si.articles.map((Article a) => a.id).toList(),
          Library.en.articles.map((Article a) => a.id).toList());
    });

    test('keeps every paragraph and footnote of its English counterpart', () {
      for (final Article english in Library.en.articles) {
        final Article sinhala = Library.si.byId(english.id)!;
        expect(sinhala.body.length, english.body.length, reason: english.id);
        expect(sinhala.footnote == null, english.footnote == null,
            reason: english.id);
        expect(sinhala.icon, english.icon);
        expect(sinhala.title, isNot(english.title));
      }
    });

    test('has the same tip groups and tips as the English one', () {
      expect(Library.si.tipGroups.map((TipGroup g) => g.id).toList(),
          Library.en.tipGroups.map((TipGroup g) => g.id).toList());
      for (int i = 0; i < Library.en.tipGroups.length; i++) {
        expect(Library.si.tipGroups[i].tips.length,
            Library.en.tipGroups[i].tips.length);
      }
    });

    test('Library.of picks the library for the language', () {
      expect(Library.of('si'), same(Library.si));
      expect(Library.of('en'), same(Library.en));
    });
  });

  group('Tips', () {
    test('every tip has a title and a body', () {
      for (final LibraryContent library in <LibraryContent>[Library.en, Library.si]) {
        for (final TipGroup group in library.tipGroups) {
          expect(group.title, isNotEmpty);
          for (final Tip tip in group.tips) {
            expect(tip.title, isNotEmpty);
            expect(tip.body, isNotEmpty);
          }
        }
      }
    });

    test('never instructs a patient to change their medication', () {
      for (final TipGroup group in Library.en.tipGroups) {
        for (final Tip tip in group.tips) {
          final String text = tip.body.toLowerCase();
          expect(text, isNot(contains('stop taking')), reason: tip.title);
          expect(text, isNot(contains('increase your dose')), reason: tip.title);
        }
      }
    });
  });
}
