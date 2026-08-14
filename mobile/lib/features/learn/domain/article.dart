import 'package:flutter/material.dart';

/// A short informational piece.
///
/// Content is bundled with the app rather than fetched: it is static, it is
/// small, and it must be readable without a connection — a patient checking why
/// they feel tired should not need the backend to be running.
class Article {
  const Article({
    required this.id,
    required this.title,
    required this.summary,
    required this.icon,
    required this.body,
    this.footnote,
  });

  final String id;
  final String title;
  final String summary;
  final IconData icon;

  /// Paragraphs, rendered in order.
  final List<String> body;

  /// Where a claim comes from, shown in smaller text at the end.
  final String? footnote;
}

/// The library.
///
/// Topics are not chosen at random. They are the factors the trained model
/// found most predictive — side-effect severity, diet, sleep, activity — which
/// are also the changes respondents reported most often in the requirements
/// survey. Three of the model's five strongest predictors are modifiable
/// lifestyle factors, and those are the ones worth writing about, because they
/// are the ones a patient can act on.
abstract final class Library {
  static const List<Article> articles = <Article>[
    Article(
      id: 'understanding-your-result',
      title: 'What your result means',
      summary: 'How to read Low, Medium and High — and what they do not mean',
      icon: Icons.help_outline,
      body: <String>[
        'QoLGuard sorts your answers into one of three bands: Low, Medium or '
            'High risk of quality-of-life decline. The band describes a '
            'likelihood, not a diagnosis. A High result does not mean something '
            'is wrong with you, and a Low result is not a clean bill of health.',
        'Alongside the band you are shown a percentage for each of the three. '
            'These matter. A High result at 55 per cent is a very different '
            'situation from a High result at 97 per cent, and the app shows both '
            'so you are not left with a single word.',
        'The most useful thing to do with any result is to mention it at your '
            'next appointment, along with the symptoms you reported. Nothing '
            'here is a reason to change or stop a medication on your own.',
      ],
      footnote: 'QoLGuard provides decision support only.',
    ),
    Article(
      id: 'why-severity-matters',
      title: 'Why severity matters most',
      summary: 'The single strongest signal in the model',
      icon: Icons.priority_high,
      body: <String>[
        'Of everything the model looks at, how severe you rate your side effect '
            'carries the most weight — considerably more than the drug itself, '
            'the dose, or how long you have been taking it.',
        'That is worth knowing when you complete an assessment. It is tempting '
            'to play down a symptom you have grown used to, but the honest '
            'answer is what makes the result meaningful. Rating a persistent '
            'ache as mild because you have lived with it for a year tells the '
            'model something untrue.',
        'It also explains why two people on the same medication at the same '
            'dose can receive very different results. The model is responding to '
            'your experience, not to the prescription.',
      ],
      footnote:
          'Side-effect severity accounted for roughly a quarter of the model\'s '
          'predictive weight.',
    ),
    Article(
      id: 'fatigue',
      title: 'Tiredness that does not lift',
      summary: 'The most commonly reported change',
      icon: Icons.battery_2_bar,
      body: <String>[
        'Tiredness was the change reported most often by people taking '
            'long-term medication — half of everyone surveyed. It is also the '
            'symptom most likely to be dismissed, precisely because it comes on '
            'gradually and has so many ordinary explanations.',
        'The difficulty is that fatigue rarely arrives as an event. It settles '
            'in over weeks, and by the time it is obvious it feels like simply '
            'how things are. That is exactly the pattern this app exists to '
            'catch: not a sudden change, but a slow one you have adjusted to '
            'without noticing.',
        'If you are tired in a way that rest does not fix, it is worth raising '
            'even if it seems minor. Your prescriber may be able to adjust '
            'timing, dose or the medication itself.',
      ],
      footnote: 'Reported by 50% of survey respondents (n = 50).',
    ),
    Article(
      id: 'sleep',
      title: 'Sleep and your medication',
      summary: 'Why disturbed sleep shows up so strongly',
      icon: Icons.bedtime_outlined,
      body: <String>[
        'Sleep problems were the second most reported change, and a diagnosed '
            'sleep disorder is among the strongest predictors the model uses. '
            'Both directions matter: some medications disturb sleep, and poor '
            'sleep makes almost every other symptom harder to bear.',
        'Small things are worth mentioning to your prescriber — whether a dose '
            'is taken in the morning or evening can make a real difference for '
            'some medications, and that is a simple change to make.',
        'Keeping a rough note of how you slept before an assessment helps you '
            'answer accurately rather than from memory of a bad night.',
      ],
      footnote: 'Reported by 32.5% of survey respondents.',
    ),
    Article(
      id: 'diet',
      title: 'Diet — a bigger factor than expected',
      summary: 'The second strongest predictor in the model',
      icon: Icons.restaurant_outlined,
      body: <String>[
        'One of the more surprising findings when the model was trained is how '
            'much weight dietary habits carry. Among everything considered, diet '
            'ranked second — behind only how severe the reported side effect '
            'was, and ahead of the medication itself.',
        'This is genuinely good news, because unlike your prescription it is '
            'something you have some control over. It does not require anything '
            'dramatic; the model distinguishes broadly between unhealthy, '
            'moderate and healthy eating patterns.',
        'If you are making changes, tell your prescriber. Some medications '
            'interact with particular foods, and a few need to be taken with or '
            'without meals to work properly.',
      ],
      footnote:
          'Dietary habits accounted for roughly 19% of the model\'s predictive '
          'weight.',
    ),
    Article(
      id: 'activity',
      title: 'Moving, in whatever way you can',
      summary: 'Activity and daily steps both carry weight',
      icon: Icons.directions_walk,
      body: <String>[
        'Physical activity level and daily step count are both among the '
            'factors the model weighs, and roughly a third of survey '
            'respondents reported reduced energy or activity since starting '
            'long-term medication.',
        'The relationship runs both ways, which makes it easy to get stuck: '
            'medication side effects make movement harder, and less movement '
            'tends to make the side effects feel worse. Breaking that loop '
            'usually starts small.',
        'There is no target here, and the app is not trying to set you one. '
            'The point is that activity is one of the few things in the model '
            'you can influence directly.',
      ],
    ),
    Article(
      id: 'talking-to-your-doctor',
      title: 'Raising side effects with your doctor',
      summary: 'What to bring, and why most go unreported',
      icon: Icons.medical_information_outlined,
      body: <String>[
        'Most side effects are never formally reported. Reviews of adverse drug '
            'reaction reporting consistently find that the large majority go '
            'unrecorded — so if you have not mentioned something, you are the '
            'norm rather than the exception.',
        'A specific account helps more than a general one. When it started, how '
            'often it happens, how much it interferes with ordinary activities, '
            'and whether it has been getting worse are all more useful than '
            '"I have not been feeling great".',
        'Your assessment history is designed for exactly this. Opening it at an '
            'appointment gives you dates and details rather than trying to '
            'reconstruct several weeks from memory.',
      ],
    ),
    Article(
      id: 'how-it-works',
      title: 'How the prediction works',
      summary: 'What the app does with your answers',
      icon: Icons.psychology_outlined,
      body: <String>[
        'Your answers are sent to a model trained on a large dataset combining '
            'medication information, documented side effects, and lifestyle '
            'factors. It compares your pattern of answers with patterns it has '
            'seen before and returns a likelihood for each of the three bands.',
        'The model was chosen from four candidates and is deliberately tuned to '
            'be sensitive rather than precise. It would rather flag someone who '
            'turns out to be fine than miss someone who is not — which is why a '
            'High result should prompt a conversation, not alarm.',
        'It has real limits. It knows about ten medications, assumes you take '
            'no more than three others alongside, and was trained on data '
            'rather than on you. It has never met you, it does not know your '
            'medical history, and it cannot examine you.',
        'Your answers and results are stored only on this phone. Nothing is '
            'uploaded, and no account is required.',
      ],
      footnote:
          'The model is a research prototype and has not been clinically '
          'validated.',
    ),
  ];

  static Article? byId(String id) {
    for (final Article article in articles) {
      if (article.id == id) return article;
    }
    return null;
  }
}
