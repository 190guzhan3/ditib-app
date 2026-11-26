import 'dart:async';

import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/models/mosque.dart';
import 'package:moschee_app/core/services/prayer_times.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/shared/format.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';

/// Gebetszeiten des Tages für eine Moschee: nächste Zeit mit Countdown,
/// darunter alle sechs Zeiten; die laufende ist hervorgehoben.
class PrayerTimesCard extends StatefulWidget {
  const PrayerTimesCard({super.key, required this.mosque, this.title});

  final Mosque mosque;

  /// Überschrift; ohne nur Ort und Methode.
  final String? title;

  @override
  State<PrayerTimesCard> createState() => _PrayerTimesCardState();
}

class _PrayerTimesCardState extends State<PrayerTimesCard> {
  Timer? _tick;

  @override
  void initState() {
    super.initState();
    // Countdown aktuell halten.
    _tick = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  DayPrayerTimes _day(DateTime date, PrayerMethod method) =>
      PrayerTimesCalculator.forDay(
        lat: widget.mosque.lat,
        lng: widget.mosque.lng,
        date: date,
        method: method,
      );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final method = SettingsService.instance.prayerMethod;
    final now = DateTime.now();
    final today = _day(now, method);
    // Nach dem Nachtgebet zählt der Countdown bis zum Morgengebet morgen.
    final next =
        today.nextAfter(now) ??
        _day(now.add(const Duration(days: 1)), method).times.entries.first;
    final current = today.currentAt(now);
    final accent = theme.colorScheme.primary;

    return WidgetContainer(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kopf in einer Zeile: nächste Zeit links, Ort und Methode rechts.
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    t.prayer_next_in(
                      t.prayer(next.key),
                      Format.duration(context, next.value.difference(now)),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  t.prayer_for(widget.mosque.city, t.prayerMethod(method)),
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Alle sechs Zeiten kompakt in einer Zeile.
          Row(
            children: [
              for (final (i, e) in today.times.entries.indexed) ...[
                if (i > 0) const SizedBox(width: 4),
                Expanded(
                  child: _PrayerTile(
                    label: t.prayer(e.key),
                    time: Format.time(context, e.value),
                    active: e.key == current,
                  ),
                ),
              ],
            ],
          ),
          if (widget.mosque.fridayPrayer != null) ...[
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Row(
                children: [
                  Icon(AppIcons.mosque, size: 16, color: accent),
                  const SizedBox(width: 6),
                  Text(
                    t.prayer_friday(widget.mosque.fridayPrayer!),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  const _PrayerTile({
    required this.label,
    required this.time,
    required this.active,
  });

  final String label;
  final String time;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final onAccent = theme.colorScheme.onPrimary;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.symmetric(vertical: 7, horizontal: 2),
      decoration: BoxDecoration(
        color: active
            ? accent
            : theme.colorScheme.onSurface.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // Lange Namen verkleinern statt abschneiden.
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: AppTypography.caption.copyWith(
                color: active ? onAccent : theme.textTheme.bodySmall?.color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              time,
              style: AppTypography.titleSmall.copyWith(
                color: active ? onAccent : theme.textTheme.titleMedium?.color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
