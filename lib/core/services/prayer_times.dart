import 'package:adhan/adhan.dart' as adhan;

/// Berechnungsmethoden, die die App anbietet. Diyanet ist Standard.
enum PrayerMethod { diyanet, muslimWorldLeague, northAmerica }

/// Die sechs Zeiten eines Tages (Sonnenaufgang ist kein Gebet, gehört aber
/// in jede Übersicht).
enum PrayerSlot { fajr, sunrise, dhuhr, asr, maghrib, isha }

class DayPrayerTimes {
  const DayPrayerTimes(this.times);

  final Map<PrayerSlot, DateTime> times;

  /// Nächste Zeit nach [now]; `null` nach dem Nachtgebet.
  MapEntry<PrayerSlot, DateTime>? nextAfter(DateTime now) {
    for (final e in times.entries) {
      if (e.value.isAfter(now)) return e;
    }
    return null;
  }

  /// Zeit, die gerade läuft (zuletzt begonnen).
  PrayerSlot? currentAt(DateTime now) {
    PrayerSlot? current;
    for (final e in times.entries) {
      if (!e.value.isAfter(now)) current = e.key;
    }
    return current;
  }
}

/// Lokale Berechnung mit dem Paket `adhan`. Eigene Zeiten einer Moschee
/// sollen später Vorrang haben (siehe CLAUDE.md).
class PrayerTimesCalculator {
  const PrayerTimesCalculator._();

  static adhan.CalculationParameters _params(PrayerMethod method) {
    final params = switch (method) {
      PrayerMethod.diyanet => adhan.CalculationMethod.turkey,
      PrayerMethod.muslimWorldLeague =>
        adhan.CalculationMethod.muslim_world_league,
      PrayerMethod.northAmerica => adhan.CalculationMethod.north_america,
    }.getParameters();
    // Im deutschen Sommer erreicht die Sonne 18° unter dem Horizont nicht;
    // die Regel verhindert dann unsinnige Fadschr/Ischa-Zeiten.
    params.highLatitudeRule = adhan.HighLatitudeRule.seventh_of_the_night;
    return params;
  }

  static DayPrayerTimes forDay({
    required double lat,
    required double lng,
    required DateTime date,
    required PrayerMethod method,
  }) {
    final t = adhan.PrayerTimes(
      adhan.Coordinates(lat, lng),
      adhan.DateComponents(date.year, date.month, date.day),
      _params(method),
    );
    return DayPrayerTimes({
      PrayerSlot.fajr: t.fajr,
      PrayerSlot.sunrise: t.sunrise,
      PrayerSlot.dhuhr: t.dhuhr,
      PrayerSlot.asr: t.asr,
      PrayerSlot.maghrib: t.maghrib,
      PrayerSlot.isha: t.isha,
    });
  }

  /// Richtung nach Mekka in Grad (von Norden im Uhrzeigersinn).
  static double qiblaDirection(double lat, double lng) =>
      adhan.Qibla(adhan.Coordinates(lat, lng)).direction;
}
