import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/article.dart';
import '../../../l10n/app_localizations.dart';

/// Short pieces on living with long-term medication.
///
/// Included because 36.7% of survey respondents named the risk of wrong or
/// misleading predictions as a concern, and 22.4% a general distrust of AI in
/// health decisions. A risk band with no explanation behind it invites exactly
/// that scepticism.
class LearnScreen extends StatelessWidget {
  const LearnScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.actionLearnTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
              child: Text(
                l10n.learnShortReadsOnThe,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ),
            for (final Article article in Library.articles) ...<Widget>[
              _ArticleTile(article: article),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _ArticleTile extends StatelessWidget {
  const _ArticleTile({required this.article});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        onTap: () => context.go('${AppRoutes.learn}/${article.id}'),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary.withValues(alpha: 0.10),
          ),
          child: Icon(article.icon, color: AppColors.primary, size: 22),
        ),
        title: Text(
          article.title,
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(
            article.summary,
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}

/// One article, read at a comfortable measure.
class ArticleScreen extends StatelessWidget {
  const ArticleScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final ThemeData theme = Theme.of(context);
    final Article? article = Library.byId(articleId);

    if (article == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.go(AppRoutes.learn),
          ),
        ),
        body: Center(child: Text(l10n.learnThatArticleIsNo)),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.actionLearnTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.learn),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
          children: <Widget>[
            Icon(article.icon, size: 34, color: AppColors.primary),
            const SizedBox(height: 14),
            Text(
              article.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.25,
              ),
            ),
            const SizedBox(height: 20),
            for (final String paragraph in article.body) ...<Widget>[
              Text(
                paragraph,
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
              ),
              const SizedBox(height: 16),
            ],
            if (article.footnote != null) ...<Widget>[
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  article.footnote!,
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
