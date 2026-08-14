import 'package:flutter_test/flutter_test.dart';

import 'package:qolguard/features/learn/domain/article.dart';

void main() {
  group('Library', () {
    test('every article has an id, a summary and a body', () {
      for (final Article article in Library.articles) {
        expect(article.id, isNotEmpty, reason: '${article.title} has no id');
        expect(article.title, isNotEmpty);
        expect(article.summary, isNotEmpty);
        expect(article.body, isNotEmpty,
            reason: '${article.title} has no content');
      }
    });

    test('ids are unique, so routing cannot resolve two articles', () {
      final Set<String> ids =
          Library.articles.map((Article article) => article.id).toSet();

      expect(ids.length, Library.articles.length);
    });

    test('looks an article up by id and returns null for an unknown one', () {
      expect(Library.byId('fatigue')?.title, 'Tiredness that does not lift');
      expect(Library.byId('not-a-real-article'), isNull);
    });

    test('covers the model\'s strongest predictors', () {
      // The library exists to explain the factors that actually drive the
      // prediction, not generic health advice. Severity, diet, sleep and
      // activity are four of the model's five leading features.
      final Set<String> ids =
          Library.articles.map((Article article) => article.id).toSet();

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
      final Article? howItWorks = Library.byId('how-it-works');
      expect(howItWorks, isNotNull);

      final String text = howItWorks!.body.join(' ').toLowerCase();
      expect(text, contains('limit'));
      expect(text, contains('ten medications'));
      expect(text, contains('stored only on this phone'));
    });

    test('never instructs a patient to change their medication', () {
      for (final Article article in Library.articles) {
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
      final Article? result = Library.byId('understanding-your-result');
      final String text = result!.body.join(' ').toLowerCase();

      expect(text, contains('appointment'));
      expect(text, contains('not a diagnosis'));
    });
  });
}
