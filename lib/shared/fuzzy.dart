/// Fehlertolerante Suche: Wörter der Anfrage werden einzeln gesucht;
/// ein Tippfehler pro Wort (bei langen Wörtern zwei) ist erlaubt.
/// Liefert 0 (kein Treffer) bis 3 (genauer Treffer).
double fuzzyScore(String query, String text) {
  final q = _norm(query).trim();
  if (q.isEmpty) return 0;
  final (t, words) = _normWords(text);
  if (t.contains(q)) return t.startsWith(q) ? 3 : 2.5;
  var total = 0.0;
  final tokens = q.split(_spaces);
  for (final token in tokens) {
    var best = 0.0;
    for (final w in words) {
      if (w.startsWith(token)) {
        best = 2;
        break;
      }
      if (token.length < 3) continue;
      // Mit dem ganzen Wort und Wortanfängen ähnlicher Länge vergleichen:
      // "moning" ~ "morning", "müncen" ~ "München", "lihgt" ~ "light".
      final allowed = token.length >= 7 ? 2 : 1;
      for (final len in {
        token.length - 1,
        token.length,
        token.length + 1,
        w.length,
      }) {
        if (len < 1 || len > w.length) continue;
        if (_distance(token, w.substring(0, len)) <= allowed) {
          best = best < 1 ? 1 : best;
          break;
        }
      }
    }
    if (best == 0) return 0; // jedes Wort muss irgendwo passen
    total += best;
  }
  return total / tokens.length;
}

final _spaces = RegExp(r'\s+');
final _separators = RegExp(r'[\s\-_/,.()]+');

/// Normalisierte Texte gemerkt: Bei jeder Suche werden sonst alle Einträge
/// neu aufbereitet (spürbar bei großen Listen).
final _cache = <String, (String, List<String>)>{};

String _norm(String s) => searchKey(s);

(String, List<String>) _normWords(String text) {
  final hit = _cache[text];
  if (hit != null) return hit;
  if (_cache.length > 50000) _cache.clear();
  final t = _norm(text);
  return _cache[text] = (
    t,
    [
      for (final w in t.split(_separators))
        if (w.isNotEmpty) w,
    ],
  );
}

/// Levenshtein-Distanz (mit Vertauschung zweier Buchstaben als 1).
int _distance(String a, String b) {
  final m = a.length, n = b.length;
  var prev2 = List<int>.filled(n + 1, 0);
  var prev = List<int>.generate(n + 1, (j) => j);
  for (var i = 1; i <= m; i++) {
    final cur = List<int>.filled(n + 1, 0)..[0] = i;
    for (var j = 1; j <= n; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      var v = [
        prev[j] + 1,
        cur[j - 1] + 1,
        prev[j - 1] + cost,
      ].reduce((x, y) => x < y ? x : y);
      if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
        v = v < prev2[j - 2] + 1 ? v : prev2[j - 2] + 1;
      }
      cur[j] = v;
    }
    prev2 = prev;
    prev = cur;
  }
  return prev[n];
}

/// Schlüssel zum Vergleichen und Sortieren: ohne Groß/klein und Akzente
/// ("Çay" → "cay", "Straße" → "strasse").
String searchKey(String value) {
  final b = StringBuffer();
  for (final r in value.trim().toLowerCase().runes) {
    final c = String.fromCharCode(r);
    b.write(_accents[c] ?? c);
  }
  return b.toString();
}

const _accents = {
  'ä': 'a',
  'á': 'a',
  'à': 'a',
  'â': 'a',
  'ö': 'o',
  'ó': 'o',
  'ò': 'o',
  'ô': 'o',
  'ü': 'u',
  'ú': 'u',
  'ù': 'u',
  'û': 'u',
  'é': 'e',
  'è': 'e',
  'ê': 'e',
  'í': 'i',
  'ì': 'i',
  'î': 'i',
  'ß': 'ss',
  'ç': 'c',
  'ñ': 'n',
  'ş': 's',
  'ğ': 'g',
  'ı': 'i',
};
