import 'package:flutter/material.dart';

import 'library_en.dart';
import 'library_si.dart';

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

/// A short piece of practical advice, read in place.
class Tip {
  const Tip({required this.title, required this.body});

  final String title;
  final String body;
}

class TipGroup {
  const TipGroup({
    required this.id,
    required this.emoji,
    required this.title,
    required this.tips,
  });

  final String id;
  final String emoji;
  final String title;
  final List<Tip> tips;
}

/// Everything in the Learn section, in one language.
class LibraryContent {
  const LibraryContent({required this.articles, required this.tipGroups});

  final List<Article> articles;
  final List<TipGroup> tipGroups;

  Article? byId(String id) {
    for (final Article article in articles) {
      if (article.id == id) return article;
    }
    return null;
  }
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
  static const LibraryContent en = libraryEn;
  static const LibraryContent si = librarySi;

  static LibraryContent of(String languageCode) =>
      languageCode == 'si' ? si : en;
}
