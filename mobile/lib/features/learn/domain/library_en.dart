import 'package:flutter/material.dart';

import 'article.dart';

// Tips: tool/health_tips.md.
const LibraryContent libraryEn = LibraryContent(
  articles: _articles,
  tipGroups: _tipGroups,
);

const List<Article> _articles = <Article>[
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

const List<TipGroup> _tipGroups = <TipGroup>[
  TipGroup(
    id: 'medicine-safety',
    emoji: '💊',
    title: 'Medicine Safety Tips',
    tips: <Tip>[
      Tip(
        title: 'Keep Calcium and Iron Separate',
        body: 'If you take iron and calcium supplements, do not take them at the same '
            'time unless your healthcare professional tells you to. Calcium can '
            'reduce iron absorption.',
      ),
      Tip(
        title: 'Thyroxine and Calcium Need a Time Gap',
        body: 'If you take levothyroxine (thyroxine), keep calcium supplements at '
            'least 4 hours apart. Calcium can reduce the absorption of '
            'levothyroxine.',
      ),
      Tip(
        title: 'Take Medicines at the Recommended Time',
        body: 'Some medicines should be taken with food, while others work best on an '
            'empty stomach. Follow the instructions on your medicine label or from '
            'your healthcare professional.',
      ),
      Tip(
        title: 'Do Not Stop Long-Term Medicine on Your Own',
        body: 'Do not suddenly stop a long-term medicine or change the dose because '
            'you feel better. Talk to your doctor or pharmacist first.',
      ),
      Tip(
        title: 'Tell Your Pharmacist About All Your Medicines',
        body: 'Tell your doctor or pharmacist about all prescription medicines, '
            'over-the-counter medicines, vitamins, supplements and herbal products '
            'you use. Some can interact with each other.',
      ),
      Tip(
        title: 'Never Double a Missed Dose Without Checking',
        body: 'If you forget a dose, do not automatically take two doses together. '
            'Check the medicine instructions or ask a pharmacist what to do.',
      ),
    ],
  ),
  TipGroup(
    id: 'diabetes',
    emoji: '🩸',
    title: 'Diabetes-Related Tips',
    tips: <Tip>[
      Tip(
        title: 'Some Diabetes Medicines Should Be Taken With Food',
        body: 'For example, metformin is usually taken with food. Follow the '
            'instructions for your specific diabetes medicine.',
      ),
      Tip(
        title: 'Do Not Skip Meals Without Considering Your Medicine',
        body: 'Skipping meals can be risky with some diabetes medicines because they '
            'may cause blood sugar to become too low. Ask your healthcare '
            'professional how to manage meals with your medicine.',
      ),
      Tip(
        title: 'Keep an Eye on Your Blood Sugar',
        body: 'If you have diabetes and have been advised to monitor your blood '
            'glucose, keep track of your readings and discuss unusual changes with '
            'your healthcare professional.',
      ),
    ],
  ),
  TipGroup(
    id: 'heart',
    emoji: '❤️',
    title: 'Cholesterol & Heart Health Tips',
    tips: <Tip>[
      Tip(
        title: 'Taking a Cholesterol Medicine Does Not Replace a Healthy Diet',
        body: 'If you take a cholesterol-lowering medicine, continue following a '
            'healthy eating pattern. Medicine and lifestyle changes can work '
            'together.',
      ),
      Tip(
        title: 'Limit Foods High in Unhealthy Fats',
        body: 'Limit foods high in saturated and trans fats, such as many fried and '
            'highly processed foods. Choose more vegetables, fruits, whole grains, '
            'beans and other nutritious foods.',
      ),
      Tip(
        title: 'Check Before Taking Grapefruit With Some Statins',
        body: 'Grapefruit or grapefruit juice can interact with some statins, '
            'including certain cholesterol medicines. Check your medicine '
            'instructions or ask your pharmacist.',
      ),
    ],
  ),
  TipGroup(
    id: 'blood-pressure',
    emoji: '🩺',
    title: 'Blood Pressure Tips',
    tips: <Tip>[
      Tip(
        title: 'Watch Your Salt Intake',
        body: 'Eating too much salt can contribute to high blood pressure. Limit '
            'salty foods and highly processed foods.',
      ),
      Tip(
        title: 'Do Not Stop Blood Pressure Medicine Because You Feel Well',
        body: 'High blood pressure may have no obvious symptoms. Feeling well does '
            'not always mean your blood pressure is controlled. Take your medicine '
            'as prescribed.',
      ),
    ],
  ),
  TipGroup(
    id: 'daily-habits',
    emoji: '💧',
    title: 'Daily Healthy Habits',
    tips: <Tip>[
      Tip(
        title: 'Drink Enough Water',
        body: 'Drink fluids regularly throughout the day. Your fluid needs vary '
            'depending on your activity, weather and health condition. If you have '
            'been told to restrict fluids, follow your healthcare professional\'s '
            'advice.',
      ),
      Tip(
        title: 'Stay Physically Active',
        body: 'For most adults, aim for at least 150 minutes of moderate physical '
            'activity each week. Walking, cycling and other activities can count.',
      ),
      Tip(
        title: 'Eat More Variety',
        body: 'Include vegetables, fruits, whole grains, pulses, nuts and healthy '
            'sources of protein in your diet. A varied diet helps provide essential '
            'nutrients.',
      ),
      Tip(
        title: 'Reduce Sugary Drinks',
        body: 'Limit soft drinks, sweetened beverages and other drinks high in free '
            'sugars. Choose water or unsweetened drinks more often.',
      ),
      Tip(
        title: 'Get Enough Rest',
        body: 'Good sleep and regular rest are important for overall well-being. Try '
            'to keep a regular sleep schedule and create a comfortable sleep '
            'environment.',
      ),
      Tip(
        title: 'Do Not Ignore Persistent Symptoms',
        body: 'If fatigue, dizziness, swelling, sleep problems, pain or other '
            'symptoms continue or become worse, talk to a healthcare professional.',
      ),
      Tip(
        title: 'Keep a List of Your Medicines',
        body: 'Keep an up-to-date list of your medicines, doses and supplements. Take '
            'the list with you when visiting a doctor or pharmacist.',
      ),
      Tip(
        title: 'Check Before Adding a New Supplement',
        body: '“Natural” does not always mean “safe.” Ask a doctor or pharmacist '
            'before starting a new vitamin, supplement or herbal product, '
            'especially if you take long-term medicines.',
      ),
    ],
  ),
  TipGroup(
    id: 'safety',
    emoji: '🚨',
    title: 'Important Safety Reminder',
    tips: <Tip>[
      Tip(
        title: 'Know When to Seek Medical Help',
        body: 'Do not rely only on an app when you have severe or rapidly worsening '
            'symptoms. Seek appropriate medical care when needed.',
      ),
      Tip(
        title: 'QoLGuard Is Not a Replacement for Medical Advice',
        body: 'QoLGuard provides health information and risk-related guidance. It '
            'does not replace a doctor\'s diagnosis, treatment or professional '
            'medical advice.',
      ),
    ],
  ),
];
