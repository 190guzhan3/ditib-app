import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/announcement_widgets.dart';
import 'package:moschee_app/sections/mosques/mosque_avatar.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/sections/prayer/prayer_times_card.dart';
import 'package:moschee_app/shared/format.dart';
import 'package:moschee_app/sections/mosques/mosque_list_tile.dart';
import 'package:moschee_app/shared/widgets/section_title.dart';
import 'package:moschee_app/shared/widgets/settings_tiles.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';

void openMosque(BuildContext context, Mosque mosque) => Navigator.of(
  context,
  rootNavigator: true,
).push(MaterialPageRoute<void>(builder: (_) => MosqueDetailScreen(mosque)));

/// Seite einer Moschee: Kopf mit Bild, Verband und Region, eigene Auswahl,
/// Gebetszeiten, Termine und Ankündigungen.
class MosqueDetailScreen extends StatelessWidget {
  const MosqueDetailScreen(this.mosque, {super.key});

  final Mosque mosque;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: ListenableBuilder(
        listenable: Listenable.merge([data, SettingsService.instance]),
        builder: (context, _) {
          // Aktuelle Fassung (Änderungen aus der Verwaltung sofort sichtbar).
          final mosque = data.mosque(this.mosque.id) ?? this.mosque;
          final mine = data.isMine(mosque.id);
          final primary = data.primaryMosque?.id == mosque.id;
          final distance = data.distanceOf(mosque);
          final events = data.upcomingEvents([mosque.id]);
          final notices = data.notices([mosque.id]);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            children: [
              Center(child: MosqueAvatar(mosque: mosque, radius: 44)),
              const SizedBox(height: 12),
              Text(
                mosque.name,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall,
              ),
              const SizedBox(height: 4),
              Text(
                [
                  '${mosque.postalCode} ${mosque.city}',
                  if (distance != null && !primary)
                    Format.km(context, distance),
                ].join(' · '),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 10),
              _Badges(mosque: mosque),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: mine
                        ? OutlinedButton.icon(
                            icon: const Icon(AppIcons.star),
                            label: Text(t.mosque_remove_mine),
                            onPressed: () => data.toggleMine(mosque.id),
                          )
                        : FilledButton.icon(
                            icon: const Icon(AppIcons.starOutline),
                            label: Text(t.mosque_add_mine),
                            onPressed: () => data.toggleMine(mosque.id),
                          ),
                  ),
                  if (mine && !primary) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => data.makePrimary(mosque.id),
                        child: Text(
                          t.mosque_make_primary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              if (mosque.about != null) ...[
                SectionTitle(t.mosque_about),
                WidgetContainer(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    mosque.about!,
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
                  ),
                ),
              ],
              if (mosque.phone != null || mosque.website != null) ...[
                SectionTitle(t.mosque_contact),
                WidgetContainer(
                  padding: WidgetContainer.settingsPadding,
                  child: SettingsGroup(
                    children: [
                      if (mosque.phone != null)
                        SettingsTile(
                          leading: const Icon(AppIcons.phone),
                          title: mosque.phone!,
                        ),
                      if (mosque.website != null)
                        SettingsTile(
                          leading: const Icon(AppIcons.web),
                          title: mosque.website!,
                        ),
                    ],
                  ),
                ),
              ],
              SectionTitle(t.mosque_prayer_today),
              PrayerTimesCard(mosque: mosque),
              SectionTitle(t.home_events),
              WidgetContainer(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: events.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          t.mosque_no_events,
                          style: theme.textTheme.bodySmall,
                        ),
                      )
                    : Column(
                        children: [
                          for (final a in events)
                            AnnouncementTile(
                              announcement: a,
                              showMosque: false,
                            ),
                        ],
                      ),
              ),
              if (notices.isNotEmpty) ...[
                SectionTitle(t.home_notices),
                WidgetContainer(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Column(
                    children: [
                      for (final a in notices)
                        AnnouncementTile(announcement: a, showMosque: false),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

/// Siegel unter dem Namen: Verband, Region und die Siegel der App-Leitung.
/// Antippen zeigt, was dahintersteckt.
class _Badges extends StatelessWidget {
  const _Badges({required this.mosque});

  final Mosque mosque;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    final region = data.region(mosque.region);
    final lang = Localizations.localeOf(context).languageCode;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 6,
      runSpacing: 6,
      children: [
        _Pill(
          text: t.association(mosque),
          color: theme.colorScheme.primary,
          onTap: () => _info(
            context,
            icon: AppIcons.mosque,
            color: theme.colorScheme.primary,
            title: t.association(mosque),
            text: t.associationInfo(mosque),
          ),
        ),
        if (region != null)
          _Pill(
            text: t.region_label(region.number),
            color: regionColor(region, theme),
            onTap: () => _info(
              context,
              icon: Icons.place_outlined,
              color: regionColor(region, theme),
              title: t.region_label(region.number),
              text: t.region_info(region.number),
              mosques: data.mosquesInRegion(region.number),
            ),
          ),
        for (final b in data.badgesOf(mosque))
          _Pill(
            text: b.name(lang),
            color: Color(b.colorValue),
            icon: badgeIcon(b.icon),
            onTap: () => _info(
              context,
              icon: badgeIcon(b.icon),
              color: Color(b.colorValue),
              title: b.name(lang),
              text: b.description(lang),
            ),
          ),
      ],
    );
  }

  Future<void> _info(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String text,
    List<Mosque> mosques = const [],
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.75,
            ),
            child: ListView(
              primary: false,
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: color.withValues(alpha: 0.15),
                      child: Icon(icon, color: color),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(title, style: theme.textTheme.titleLarge),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  text,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
                if (mosques.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    AppLocalizations.of(
                      sheetContext,
                    )!.mosques_count(mosques.length),
                    style: theme.textTheme.bodySmall,
                  ),
                  for (final m in mosques)
                    MosqueListTile(
                      mosque: m,
                      onTap: () {
                        Navigator.pop(sheetContext);
                        if (m.id != mosque.id) openMosque(context, m);
                      },
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String text;
  final Color color;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: color.withValues(alpha: 0.14),
    shape: const StadiumBorder(),
    child: InkWell(
      customBorder: const StadiumBorder(),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 4),
            ],
            Text(text, style: AppTypography.labelSmall.copyWith(color: color)),
          ],
        ),
      ),
    ),
  );
}
