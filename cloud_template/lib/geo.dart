// Nach lib/cloud/ kopieren. Reines Dart, ohne Firebase.
import 'dart:math' as math;

/// Ein Punkt auf der Karte. Für Orte, die öffentlich sein dürfen (z. B. ein
/// Vereinsheim), genau; für Nutzer nur vergröbert ([Geo.coarse]).
class GeoPoint2 {
  const GeoPoint2(this.lat, this.lng);

  final double lat;
  final double lng;

  /// Liest `{lat, lng}` (oder null bei fehlenden/ungültigen Werten).
  static GeoPoint2? fromJson(Object? json) {
    if (json is! Map) return null;
    final lat = json['lat'];
    final lng = json['lng'];
    if (lat is! num || lng is! num) return null;
    if (lat.abs() > 90 || lng.abs() > 180) return null;
    return GeoPoint2(lat.toDouble(), lng.toDouble());
  }

  Map<String, dynamic> toJson() => {'lat': lat, 'lng': lng};

  @override
  bool operator ==(Object other) =>
      other is GeoPoint2 && other.lat == lat && other.lng == lng;

  @override
  int get hashCode => Object.hash(lat, lng);
}

/// Geohash-Hilfen für die Umkreissuche.
///
/// In Firestore je Dokument `geohash` (Text) und `location` ({lat, lng})
/// speichern. Abfrage: für jedes Präfix aus [coveringPrefixes] eine
/// Bereichsabfrage `geohash >= p` und `geohash < p + '~'`, dann mit
/// [withinRadius] genau filtern.
abstract final class Geo {
  static const _base32 = '0123456789bcdefghjkmnpqrstuvwxyz';

  /// Genauigkeit für vergröberte Orte (Zelle etwa 5 × 5 km). Genaue Orte
  /// mit [encode] und Standardgenauigkeit 9 speichern.
  static const storedPrecision = 5;

  static String encode(double lat, double lng, [int precision = 9]) {
    var latMin = -90.0, latMax = 90.0, lngMin = -180.0, lngMax = 180.0;
    final buffer = StringBuffer();
    var bit = 0, value = 0;
    var evenBit = true;
    while (buffer.length < precision) {
      if (evenBit) {
        final mid = (lngMin + lngMax) / 2;
        if (lng >= mid) {
          value = value * 2 + 1;
          lngMin = mid;
        } else {
          value *= 2;
          lngMax = mid;
        }
      } else {
        final mid = (latMin + latMax) / 2;
        if (lat >= mid) {
          value = value * 2 + 1;
          latMin = mid;
        } else {
          value *= 2;
          latMax = mid;
        }
      }
      evenBit = !evenBit;
      if (++bit == 5) {
        buffer.write(_base32[value]);
        bit = 0;
        value = 0;
      }
    }
    return buffer.toString();
  }

  /// Mitte der Zelle [hash].
  static GeoPoint2 decode(String hash) {
    var latMin = -90.0, latMax = 90.0, lngMin = -180.0, lngMax = 180.0;
    var evenBit = true;
    for (final char in hash.split('')) {
      final index = _base32.indexOf(char);
      if (index < 0) break;
      for (var shift = 4; shift >= 0; shift--) {
        final bitSet = (index >> shift) & 1 == 1;
        if (evenBit) {
          final mid = (lngMin + lngMax) / 2;
          bitSet ? lngMin = mid : lngMax = mid;
        } else {
          final mid = (latMin + latMax) / 2;
          bitSet ? latMin = mid : latMax = mid;
        }
        evenBit = !evenBit;
      }
    }
    return GeoPoint2((latMin + latMax) / 2, (lngMin + lngMax) / 2);
  }

  /// Vergröbert einen genauen Punkt auf die gespeicherte Zelle.
  static ({String geohash, GeoPoint2 center}) coarse(double lat, double lng) {
    final hash = encode(lat, lng, storedPrecision);
    return (geohash: hash, center: decode(hash));
  }

  /// Entfernung in km (Haversine).
  static double distanceKm(GeoPoint2 a, GeoPoint2 b) {
    const earthRadius = 6371.0;
    double rad(double degrees) => degrees * math.pi / 180;
    final dLat = rad(b.lat - a.lat);
    final dLng = rad(b.lng - a.lng);
    final h =
        math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(a.lat)) *
            math.cos(rad(b.lat)) *
            math.pow(math.sin(dLng / 2), 2);
    return 2 * earthRadius * math.asin(math.min(1, math.sqrt(h)));
  }

  /// Höhe und Breite einer Zelle der Genauigkeit [precision] in Grad.
  static ({double lat, double lng}) cellSize(int precision) {
    final bits = precision * 5;
    final lngBits = (bits / 2).ceil();
    final latBits = bits - lngBits;
    return (lat: 180 / math.pow(2, latBits), lng: 360 / math.pow(2, lngBits));
  }

  /// Präfixe, deren Zellen den Umkreis [radiusKm] um [center] sicher
  /// abdecken: die Zelle des Mittelpunkts und ihre Nachbarn, in der feinsten
  /// Genauigkeit, deren Zellen noch mindestens so groß wie der Radius sind.
  /// Jedes Präfix wird zu einer Bereichsabfrage auf `geohash`.
  static List<String> coveringPrefixes(GeoPoint2 center, double radiusKm) {
    final latKm = 111.32;
    final lngKm = math.max(0.5, 111.32 * math.cos(center.lat * math.pi / 180));
    var precision = 1;
    for (var p = storedPrecision; p >= 1; p--) {
      final size = cellSize(p);
      if (size.lat * latKm >= radiusKm && size.lng * lngKm >= radiusKm) {
        precision = p;
        break;
      }
    }
    final size = cellSize(precision);
    final prefixes = <String>{};
    for (final dLat in [-size.lat, 0.0, size.lat]) {
      for (final dLng in [-size.lng, 0.0, size.lng]) {
        final lat = (center.lat + dLat).clamp(-89.9999, 89.9999);
        var lng = center.lng + dLng;
        if (lng > 180) lng -= 360;
        if (lng < -180) lng += 360;
        prefixes.add(encode(lat.toDouble(), lng, precision));
      }
    }
    return prefixes.toList()..sort();
  }
}

/// Einträge aus [candidates] im Umkreis [radiusKm] um [center], die nächsten
/// zuerst. Einträge ohne Ort fehlen.
List<T> withinRadius<T>(
  Iterable<T> candidates,
  GeoPoint2? Function(T item) locationOf,
  GeoPoint2 center,
  double radiusKm,
) {
  final hits = <({T item, double km})>[];
  for (final item in candidates) {
    final location = locationOf(item);
    if (location == null) continue;
    final km = Geo.distanceKm(center, location);
    if (km <= radiusKm) hits.add((item: item, km: km));
  }
  hits.sort((a, b) => a.km.compareTo(b.km));
  return [for (final h in hits) h.item];
}
