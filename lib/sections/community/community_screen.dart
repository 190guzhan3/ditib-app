import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/community_post.dart';
import 'package:moschee_app/core/services/account_service.dart';
import 'package:moschee_app/core/services/geo.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/auth/auth_screen.dart';
import 'package:moschee_app/sections/community/community_labels.dart';
import 'package:moschee_app/sections/community/post_card.dart';
import 'package:moschee_app/sections/community/post_form_sheet.dart';
import 'package:moschee_app/sections/shell/tab_top_bar.dart';
import 'package:moschee_app/shared/widgets/app_empty_state.dart';
import 'package:moschee_app/shared/widgets/app_motion.dart';
import 'package:moschee_app/shared/widgets/sliding_segments.dart';

enum _Sort { newest, nearby }

/// Hilfebörse: Biete/Suche, Kategorien, Sortierung. Lesen ohne Konto,
/// Posten und „Interesse melden“ mit Konto.
class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  PostKind? _kind;
  PostCategory? _category;
  _Sort _sort = _Sort.newest;

  List<CommunityPost> _visible(DataRepository data) {
    final list = data.posts
        .where((p) => _kind == null || p.kind == _kind)
        .where((p) => _category == null || p.category == _category)
        .toList();
    final primary = data.primaryMosque;
    double dist(CommunityPost p) {
      final m = data.mosque(p.mosqueId);
      if (primary == null || m == null) return double.infinity;
      return distanceKm(primary.lat, primary.lng, m.lat, m.lng);
    }

    list.sort(
      (a, b) => _sort == _Sort.nearby && primary != null
          ? dist(a).compareTo(dist(b))
          : b.postedAt.compareTo(a.postedAt),
    );
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    return Scaffold(
      appBar: const TabTopBar(),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: 'community-new',
        icon: const Icon(AppIcons.add),
        label: Text(t.post_new),
        onPressed: () async {
          if (await requireAccount(context) && context.mounted) {
            await showPostForm(context);
          }
        },
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([data, AccountService.instance]),
        builder: (context, _) {
          if (data.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          final posts = _visible(data);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: SlidingSegments<PostKind?>(
                        options: [
                          (value: null, label: t.community_all, icon: null),
                          (
                            value: PostKind.offer,
                            label: t.community_offers,
                            icon: null,
                          ),
                          (
                            value: PostKind.request,
                            label: t.community_requests,
                            icon: null,
                          ),
                        ],
                        value: _kind,
                        onChanged: (v) => setState(() => _kind = v),
                      ),
                    ),
                    PopupMenuButton<_Sort>(
                      icon: Icon(
                        AppIcons.sort,
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.62,
                        ),
                      ),
                      initialValue: _sort,
                      onSelected: (v) => setState(() => _sort = v),
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          value: _Sort.newest,
                          child: Text(t.community_sort_newest),
                        ),
                        PopupMenuItem(
                          value: _Sort.nearby,
                          child: Text(t.community_sort_nearby),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    ChoiceChip(
                      label: Text(t.community_all_categories),
                      selected: _category == null,
                      onSelected: (_) => setState(() => _category = null),
                    ),
                    for (final c in PostCategory.values) ...[
                      const SizedBox(width: 8),
                      ChoiceChip(
                        avatar: Icon(categoryIcon(c), size: 16),
                        label: Text(t.category(c)),
                        selected: _category == c,
                        onSelected: (_) => setState(
                          () => _category = _category == c ? null : c,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: posts.isEmpty
                    ? AppEmptyState(
                        icon: AppIcons.community,
                        title: t.community_empty,
                        message: t.community_hint,
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                        itemCount: posts.length + 1,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) {
                          if (i == 0) return const _Hint();
                          return FadeSlideIn(
                            index: i,
                            child: PostCard(post: posts[i - 1]),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Hint extends StatelessWidget {
  const _Hint();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(Icons.shield_outlined, size: 16, color: theme.disabledColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(t.community_hint, style: theme.textTheme.bodySmall),
        ),
      ],
    );
  }
}

/// Prüft, ob ein Konto da ist; sonst Erklärung mit „Anmelden“.
/// Liefert `true`, wenn (danach) angemeldet.
Future<bool> requireAccount(BuildContext context) async {
  final account = AccountService.instance;
  if (account.signedIn) return true;
  final t = AppLocalizations.of(context)!;
  final go = await showAppConfirmDialog(
    context,
    title: t.account_needed_title,
    message: t.account_needed_message,
    confirmLabel: t.account_sign_in,
    cancelLabel: t.common_cancel,
  );
  if (!go || !context.mounted) return false;
  await openAuth(context);
  return account.signedIn;
}
