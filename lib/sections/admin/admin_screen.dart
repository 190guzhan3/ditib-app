import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/announcement.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/models/team_member.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/admin/categories_screen.dart';
import 'package:moschee_app/sections/admin/entry_edit_screen.dart';
import 'package:moschee_app/sections/admin/mosque_edit_screen.dart';
import 'package:moschee_app/sections/admin/team_screen.dart';
import 'package:moschee_app/sections/mosques/announcement_widgets.dart';
import 'package:moschee_app/sections/mosques/mosque_avatar.dart';
import 'package:moschee_app/sections/mosques/mosque_detail_screen.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/sections/shell/tab_top_bar.dart';
import 'package:moschee_app/shared/widgets/app_empty_state.dart';
import 'package:moschee_app/shared/widgets/section_title.dart';
import 'package:moschee_app/shared/widgets/settings_tiles.dart';
import 'package:moschee_app/shared/widgets/swipe_action_tile.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';

/// Verwaltung einer Moschee, wie Inhaber, Admins und Redakteure sie sehen:
/// Termine und Ankündigungen, Seite, Kategorien, Team.
///
/// Vorschau: verwaltet wird die Hauptmoschee mit der Rolle Inhaber. Später
/// kommen Moschee und Rolle aus der Cloud (MosqueMember).
class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  /// Rolle in der Vorschau.
  static const previewRole = MosqueRole.owner;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final data = DataRepository.instance;
    return ListenableBuilder(
      listenable: Listenable.merge([data, SettingsService.instance]),
      builder: (context, _) {
        final mosque = data.primaryMosque;
        return Scaffold(
          appBar: const TabTopBar(),
          floatingActionButton: mosque == null
              ? null
              : FloatingActionButton.extended(
                  heroTag: 'admin-new',
                  icon: const Icon(AppIcons.add),
                  label: Text(t.admin_new_entry),
                  onPressed: () => openEntryEditor(context, mosque),
                ),
          body: mosque == null
              ? AppEmptyState(
                  icon: AppIcons.admin,
                  title: t.nav_admin,
                  message: t.admin_no_mosque,
                )
              : _AdminContent(mosque: mosque),
        );
      },
    );
  }
}

class _AdminContent extends StatelessWidget {
  const _AdminContent({required this.mosque});

  final Mosque mosque;

  Future<void> _delete(BuildContext context, Announcement a) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showAppConfirmDialog(
      context,
      title: t.entry_delete_confirm,
      message: '${a.title}\n\n${t.common_irreversible}',
      confirmLabel: t.common_delete,
      cancelLabel: t.common_cancel,
      destructive: true,
    );
    if (ok) await DataRepository.instance.deleteAnnouncement(a.id);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    final entries = data.allEntries(mosque.id);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final custom = data
        .categoriesFor(mosque.id)
        .where((c) => !c.builtIn)
        .length;
    final guide = AppColors.guideOf(theme.brightness);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      children: [
        // Kopf: welche Moschee, welche Rolle.
        WidgetContainer(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              MosqueAvatar(mosque: mosque, radius: 26),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(mosque.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      children: [
                        _Tag(
                          text: t.role(AdminScreen.previewRole),
                          color: theme.colorScheme.primary,
                        ),
                        _Tag(text: t.admin_preview, color: guide),
                      ],
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () => openMosque(context, mosque),
                child: Text(t.admin_view_page),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(Icons.science_outlined, size: 14, color: guide),
            const SizedBox(width: 6),
            Expanded(
              child: Text(t.admin_test_note, style: theme.textTheme.bodySmall),
            ),
          ],
        ),
        SectionTitle(t.admin_page),
        WidgetContainer(
          padding: WidgetContainer.settingsPadding,
          child: SettingsGroup(
            children: [
              SettingsTile(
                leading: const Icon(AppIcons.edit),
                title: t.admin_edit_info,
                trailing: const Icon(AppIcons.chevron),
                onTap: () => openMosqueEditor(context, mosque),
              ),
              SettingsTile(
                leading: const Icon(Icons.palette_outlined),
                title: t.admin_categories,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${data.categoriesFor(mosque.id).length - custom} + $custom',
                      style: SettingsTextStyles.value(context),
                    ),
                    const Icon(AppIcons.chevron),
                  ],
                ),
                onTap: () => openCategories(context, mosque),
              ),
              SettingsTile(
                leading: const Icon(Icons.group_outlined),
                title: t.admin_team,
                trailing: const Icon(AppIcons.chevron),
                onTap: () => openTeam(context, mosque),
              ),
            ],
          ),
        ),
        SectionTitle(t.admin_entries),
        WidgetContainer(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: entries.isEmpty
              ? Padding(
                  padding: const EdgeInsets.all(14),
                  child: Text(
                    t.admin_entries_empty,
                    style: theme.textTheme.bodySmall,
                  ),
                )
              // Wischen: links Bearbeiten, rechts Löschen.
              : SlidableAutoCloseBehavior(
                  child: Column(
                    children: [
                      for (final a in entries)
                        SwipeActionTile(
                          key: ValueKey(a.id),
                          startActions: [
                            SwipeAction(
                              icon: AppIcons.edit,
                              label: t.entry_edit,
                              color: theme.colorScheme.primary,
                              onPressed: () =>
                                  openEntryEditor(context, mosque, entry: a),
                            ),
                          ],
                          endActions: [
                            SwipeAction(
                              icon: AppIcons.delete,
                              label: t.common_delete,
                              color: theme.colorScheme.error,
                              onPressed: () => _delete(context, a),
                            ),
                          ],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Opacity(
                              // Vergangene Termine blass.
                              opacity:
                                  a.start != null && a.start!.isBefore(today)
                                  ? 0.5
                                  : 1,
                              child: AnnouncementTile(
                                announcement: a,
                                showMosque: false,
                                onTap: () =>
                                    openEntryEditor(context, mosque, entry: a),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(99),
    ),
    child: Text(text, style: AppTypography.caption.copyWith(color: color)),
  );
}
