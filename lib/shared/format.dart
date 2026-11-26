import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';

/// Einheitliche Darstellung von Zeiten, Daten und Entfernungen.
class Format {
  const Format._();

  static String _locale(BuildContext context) =>
      Localizations.localeOf(context).toLanguageTag();

  /// "13:45"
  static String time(BuildContext context, DateTime d) =>
      DateFormat.Hm(_locale(context)).format(d);

  /// "Heute", "Morgen" oder "Fr., 4. Dez."
  static String day(BuildContext context, DateTime d) {
    final t = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final days = DateTime(
      d.year,
      d.month,
      d.day,
    ).difference(DateTime(now.year, now.month, now.day)).inDays;
    if (days == 0) return t.date_today;
    if (days == 1) return t.date_tomorrow;
    return DateFormat.MMMEd(_locale(context)).format(d);
  }

  /// "Heute · 13:45"
  static String dayTime(BuildContext context, DateTime d) =>
      '${day(context, d)} · ${time(context, d)}';

  /// Kurzer Wochentag für Datumskacheln ("Fr.").
  static String weekdayShort(BuildContext context, DateTime d) =>
      DateFormat.E(_locale(context)).format(d);

  /// Kurzer Monat für Datumskacheln ("Dez.").
  static String monthShort(BuildContext context, DateTime d) =>
      DateFormat.MMM(_locale(context)).format(d);

  /// "vor 3 Std."
  static String ago(BuildContext context, DateTime d) {
    final t = AppLocalizations.of(context)!;
    final diff = DateTime.now().difference(d);
    if (diff.inMinutes < 1) return t.ago_now;
    if (diff.inHours < 1) return t.ago_minutes(diff.inMinutes);
    if (diff.inDays < 1) return t.ago_hours(diff.inHours);
    return t.ago_days(diff.inDays);
  }

  /// "1 Std. 12 Min."
  static String duration(BuildContext context, Duration d) {
    final t = AppLocalizations.of(context)!;
    final minutes = d.inMinutes + (d.inSeconds % 60 > 0 ? 1 : 0);
    if (minutes < 60) return t.duration_m(minutes);
    return t.duration_hm(minutes ~/ 60, minutes % 60);
  }

  /// "4,2 km" (unter 10 km mit einer Nachkommastelle).
  static String km(BuildContext context, double km) {
    final t = AppLocalizations.of(context)!;
    final f = NumberFormat(km < 10 ? '0.0' : '0', _locale(context));
    return t.distance_km(f.format(km));
  }
}
