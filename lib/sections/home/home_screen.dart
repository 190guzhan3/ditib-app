import 'package:flutter/material.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/event_category.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/announcement_widgets.dart';
import 'package:moschee_app/sections/mosques/mosque_avatar.dart';
import 'package:moschee_app/sections/mosques/mosque_detail_screen.dart';
import 'package:moschee_app/sections/mosques/mosque_picker_sheet.dart';
import 'package:moschee_app/sections/prayer/prayer_times_card.dart';
import 'package:moschee_app/sections/shell/tab_top_bar.dart';
import 'package:moschee_app/shared/format.dart';
import 'package:moschee_app/sections/mosques/radius_sheet.dart';
import 'package:moschee_app/shared/widgets/app_empty_state.dart';
import 'package:moschee_app/shared/widgets/app_motion.dart';
import 'package:moschee_app/shared/widgets/section_title.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';

/// Startseite: nur Informationen. Eigene Moscheen, Cenaze-Gebete,
/// Gebetszeiten, Termine und Ankündigungen, dazu die Umgebung.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataRepository.instance;
    return Scaffold(
      appBar: const TabTopBar(),
      body: ListenableBuilder(
        listenable: Listenable.merge([data, SettingsService.instance]),
        builder: (context, _) {
          if (data.loading) {
            return const Center(child: CircularProgressIndicator());
          }
          return RefreshIndicator(
            onRefresh: data.reload,
            child: data.myMosques.isEmpty
                ? const _NoMosque()
                : const _HomeContent(),
          );
        },
      ),
    );
  }
}

class _NoMosque extends StatelessWidget {
  const _NoMosque();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return ListView(
      children: [
        SizedBox(height: MediaQuery.sizeOf(context).height * 0.15),
        AppEmptyState(
          icon: AppIcons.mosque,
          title: t.home_no_mosque_title,
          message: t.home_no_mosque_message,
          action: FilledButton.icon(
            icon: const Icon(AppIcons.search),
            label: Text(t.home_choose_mosque),
            onPressed: () => showMosquePicker(context),
          ),
        ),
      ],
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent();

  /// Zeigt höchstens so viele Termine je Abschnitt.
  static const _maxEvents = 6;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final data = DataRepository.instance;
    final mine = data.myMosques;
    final myIds = mine.map((m) => m.id);
    final events = data.upcomingEvents(myIds);
    // Cenaze-Gebete der nächsten zwei Tage stehen ganz oben.
    final soon = DateTime.now().add(const Duration(days: 2));
    final cenaze = events
        .where(
          (a) =>
              a.categoryId == EventCategory.cenaze && a.start!.isBefore(soon),
        )
        .toList();
    final otherEvents = events.where((a) => !cenaze.contains(a)).toList();
    final notices = data.notices(myIds);
    final nearby = data.nearbyMosques;
    final nearbyEvents = data.upcomingEvents(nearby.map((m) => m.id));

    var i = 0;
    Widget fade(Widget child) => FadeSlideIn(index: i++, child: child);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      children: [
        fade(_MyMosquesStrip(mosques: mine)),
        for (final a in cenaze) ...[
          const SizedBox(height: 12),
          fade(CenazeBanner(announcement: a)),
        ],
        const SizedBox(height: 16),
        fade(PrayerTimesCard(mosque: mine.first)),
        SectionTitle(t.home_events),
        fade(
          _Card(
            empty: t.home_events_empty,
            children: [
              for (final a in otherEvents.take(_maxEvents))
                AnnouncementTile(announcement: a, showMosque: mine.length > 1),
            ],
          ),
        ),
        if (notices.isNotEmpty) ...[
          SectionTitle(t.home_notices),
          fade(
            _Card(
              children: [
                for (final a in notices.take(3))
                  AnnouncementTile(
                    announcement: a,
                    showMosque: mine.length > 1,
                  ),
              ],
            ),
          ),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: SectionTitle(t.home_nearby)),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: ActionChip(
                side: BorderSide.none,
                backgroundColor: theme.colorScheme.primary.withValues(
                  alpha: 0.12,
                ),
                avatar: Icon(
                  AppIcons.radius,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                label: Text(
                  t.distance_km('${SettingsService.instance.radiusKm}'),
                ),
                onPressed: () => showRadiusSheet(context),
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            t.home_nearby_count(
              nearby.length,
              SettingsService.instance.radiusKm,
            ),
            style: theme.textTheme.bodySmall,
          ),
        ),
        fade(
          _Card(
            empty: t.home_nearby_empty,
            children: [
              for (final a in nearbyEvents.take(_maxEvents))
                AnnouncementTile(
                  announcement: a,
                  distance: Format.km(
                    context,
                    data.distanceOf(data.mosque(a.mosqueId)!)!,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Karte mit Einträgen, mit Leertext wenn keine da sind.
class _Card extends StatelessWidget {
  const _Card({required this.children, this.empty});

  final List<Widget> children;
  final String? empty;

  @override
  Widget build(BuildContext context) {
    return WidgetContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: children.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Text(
                empty ?? '',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            )
          : Column(children: children),
    );
  }
}

/// Eigene Moscheen als Karten nebeneinander, dazu „Hinzufügen“. Nur Bild
/// und Name (der Ort steckt meist im Namen); mehr auf der Moschee-Seite.
class _MyMosquesStrip extends StatelessWidget {
  const _MyMosquesStrip({required this.mosques});

  final List<Mosque> mosques;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final single = mosques.length == 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          t.home_my_mosques,
          padding: const EdgeInsets.only(left: 4, bottom: 8),
        ),
        if (single)
          // Eine Moschee: so hoch wie Bild und Name, „Hinzufügen“ gleich hoch.
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(child: _MosqueCard(mosque: mosques.first, wide: true)),
                const SizedBox(width: 10),
                const _AddCard(wide: true),
              ],
            ),
          )
        else
          // Mehrere: so hoch wie der längste Name es braucht (max. 3 Zeilen).
          SizedBox(
            height: _MosqueCard.heightFor(context, mosques),
            child: ListView(
              scrollDirection: Axis.horizontal,
              clipBehavior: Clip.none,
              children: [
                for (final (i, m) in mosques.indexed) ...[
                  _MosqueCard(mosque: m, primary: i == 0),
                  const SizedBox(width: 10),
                ],
                const _AddCard(),
              ],
            ),
          ),
      ],
    );
  }
}

class _MosqueCard extends StatelessWidget {
  const _MosqueCard({
    required this.mosque,
    this.primary = false,
    this.wide = false,
  });

  final Mosque mosque;

  /// Hauptmoschee: kleiner Stern am Bild.
  final bool primary;

  /// Nur eine Moschee: breite Karte mit Bild links.
  final bool wide;

  static const _minWidth = 120.0;
  static const _maxWidth = 176.0;
  static const _padding = 12.0;
  static const _avatarRadius = 28.0;
  static final _nameStyle = AppTypography.label.copyWith(height: 1.25);

  static TextPainter _measure(
    BuildContext context,
    String text, {
    double maxWidth = double.infinity,
  }) {
    // Gleicher Stil wie beim Zeichnen (inkl. Schrift des Themes).
    final style = DefaultTextStyle.of(context).style.merge(_nameStyle);
    return TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 2,
      textAlign: TextAlign.center,
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
    )..layout(maxWidth: maxWidth);
  }

  /// Breite einer schmalen Karte: so breit, dass der Name in eine Zeile
  /// passt, höchstens [_maxWidth] (dann zwei Zeilen).
  static double widthFor(BuildContext context, Mosque m) =>
      (_measure(context, m.name).width + 2 * _padding).ceilToDouble().clamp(
        _minWidth,
        _maxWidth,
      );

  /// Gemeinsame Höhe aller schmalen Karten: Bild plus der Name, der die
  /// meisten Zeilen braucht. So sind alle Karten gleich hoch.
  static double heightFor(BuildContext context, List<Mosque> mosques) {
    var text = 0.0;
    for (final m in mosques) {
      final painter = _measure(
        context,
        m.name,
        maxWidth: widthFor(context, m) - 2 * _padding,
      );
      if (painter.height > text) text = painter.height;
    }
    return (2 * _padding + 2 * _avatarRadius + 10 + text).ceilToDouble() + 2;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final name = Text(
      mosque.name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: wide ? TextAlign.start : TextAlign.center,
      style: _nameStyle.copyWith(color: theme.colorScheme.onSurface),
    );
    final avatar = Stack(
      clipBehavior: Clip.none,
      children: [
        MosqueAvatar(mosque: mosque, radius: _avatarRadius),
        if (primary)
          Positioned(
            right: -3,
            bottom: -1,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(AppIcons.star, size: 16, color: accent),
            ),
          ),
      ],
    );
    return SizedBox(
      width: wide ? null : widthFor(context, mosque),
      child: Material(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => openMosque(context, mosque),
          child: Padding(
            padding: const EdgeInsets.all(_padding),
            child: wide
                ? Row(
                    children: [
                      avatar,
                      const SizedBox(width: 12),
                      Expanded(child: name),
                    ],
                  )
                // Bild oben, Name unten bündig (alle Karten gleich hoch).
                : Column(
                    children: [
                      avatar,
                      const SizedBox(height: 10),
                      const Spacer(),
                      name,
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _AddCard extends StatelessWidget {
  const _AddCard({this.wide = false});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return SizedBox(
      width: wide ? 84 : 96,
      child: Material(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showMosquePicker(context),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.add, color: accent),
              const SizedBox(height: 4),
              Text(
                t.home_add_mosque,
                style: AppTypography.labelSmall.copyWith(color: accent),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
