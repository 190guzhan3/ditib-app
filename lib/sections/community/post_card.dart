import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/community_post.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/community/community_labels.dart';
import 'package:moschee_app/sections/community/community_screen.dart';
import 'package:moschee_app/shared/format.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';

/// Beitrag der Hilfebörse: Art, Kategorie, Text, Ort und „Interesse
/// melden“. Kontakt läuft nie über einen freien Chat.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post});

  final CommunityPost post;

  Future<void> _interest(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    if (!await requireAccount(context) || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final interested = !post.myInterest;
    await DataRepository.instance.setInterest(post, interested);
    if (interested) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(content: Text(t.post_interest_sent(post.authorName))),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mosque = DataRepository.instance.mosque(post.mosqueId);
    final kindColor = postKindColor(post.kind);
    return WidgetContainer(
      padding: const EdgeInsets.fromLTRB(16, 12, 4, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: kindColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  t.postKind(post.kind),
                  style: AppTypography.caption.copyWith(
                    color: kindColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                categoryIcon(post.category),
                size: 15,
                color: theme.textTheme.bodySmall?.color,
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  t.category(post.category),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
              PopupMenuButton<void>(
                icon: Icon(AppIcons.more, size: 20, color: theme.disabledColor),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    onTap: () => ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(t.post_reported))),
                    child: Row(
                      children: [
                        const Icon(AppIcons.report, size: 20),
                        const SizedBox(width: 12),
                        Text(t.post_report),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(
                  post.body,
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 10),
                Text(
                  [
                    post.mine ? t.post_mine : post.authorName,
                    ?mosque?.city,
                    Format.ago(context, post.postedAt),
                  ].join(' · '),
                  style: theme.textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t.post_interest_count(post.interestCount),
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                    if (!post.mine)
                      post.myInterest
                          ? FilledButton.tonalIcon(
                              style: AppButtonStyles.compact(context),
                              icon: const Icon(AppIcons.interestDone, size: 16),
                              label: Text(t.post_interest_done),
                              onPressed: () => _interest(context),
                            )
                          : OutlinedButton.icon(
                              style: AppButtonStyles.compact(context),
                              icon: const Icon(AppIcons.interest, size: 16),
                              label: Text(t.post_interest),
                              onPressed: () => _interest(context),
                            ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
