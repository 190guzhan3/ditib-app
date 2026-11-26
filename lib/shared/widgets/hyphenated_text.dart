import 'package:flutter/material.dart';

/// Text auf höchstens [maxLines] Zeilen. Passt ein einzelnes Wort nicht in
/// die Breite, wird es an einer Silbengrenze mit "-" getrennt, statt es
/// abzuschneiden. Flutter trennt Wörter nicht selbst.
class HyphenatedText extends StatelessWidget {
  const HyphenatedText(
    this.text, {
    super.key,
    required this.style,
    this.maxLines = 2,
    this.minLines = 1,
    this.maxWidth,
    this.textAlign,
  });

  final TextAlign? textAlign;

  final String text;
  final TextStyle style;
  final int maxLines;

  /// Mindestens so viele Zeilen hoch, damit nebeneinanderliegende Kacheln
  /// gleich aufgebaut sind (fehlende Zeilen bleiben leer).
  final int minLines;

  /// Verfügbare Breite, falls bekannt. Nötig z. B. in [IntrinsicHeight], wo
  /// kein LayoutBuilder möglich ist.
  final double? maxWidth;

  @override
  Widget build(BuildContext context) {
    // Gemessen wird mit dem Stil, mit dem der Text auch erscheint (inklusive
    // geerbter Laufweite); sonst bricht der Trennstrich allein um.
    final style = DefaultTextStyle.of(context).style.merge(this.style);
    Widget build(double width) {
      final scaler = MediaQuery.textScalerOf(context);
      final direction = Directionality.of(context);
      final hyphenated = hyphenateToFit(
        text,
        style: style,
        maxWidth: width,
        textScaler: scaler,
        textDirection: direction,
      );
      final lines = countLines(
        hyphenated,
        style: style,
        maxWidth: width,
        maxLines: maxLines,
        textScaler: scaler,
        textDirection: direction,
      );
      final padding = '\n' * (minLines.clamp(1, maxLines) - lines).clamp(0, 9);
      return Text(
        hyphenated + padding,
        style: style,
        maxLines: maxLines,
        textAlign: textAlign,
        overflow: TextOverflow.ellipsis,
      );
    }

    final width = maxWidth;
    if (width != null) return build(width);
    return LayoutBuilder(
      builder: (context, constraints) => build(constraints.maxWidth),
    );
  }
}

/// Fügt in Wörter, die breiter als [maxWidth] sind, eine Trennung "-\n"
/// ein. Kurze Wörter bleiben unverändert und brechen am Leerzeichen um.
String hyphenateToFit(
  String text, {
  required TextStyle style,
  required double maxWidth,
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection textDirection = TextDirection.ltr,
}) {
  if (!maxWidth.isFinite || maxWidth <= 0) return text;
  double widthOf(String value) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: textDirection,
      textScaler: textScaler,
      maxLines: 1,
    )..layout();
    return painter.width;
  }

  return text
      .split(' ')
      .map((word) {
        if (widthOf(word) <= maxWidth) return word;
        // Etwas Spielraum, damit der Trennstrich nicht allein umbricht.
        final limit = maxWidth - 2;
        final fitting = [
          for (final index in syllableBreaks(word))
            if (widthOf('${word.substring(0, index)}-') <= limit) index,
        ];
        if (fitting.isEmpty) return word;
        // Schöner trennen: erst an einer Wortfuge („Teilnahme-quote“), sonst
        // möglichst mittig, damit nicht nur eine Silbe umbricht. Beide Teile
        // müssen in die Breite passen.
        final bothFit = [
          for (final index in fitting)
            if (widthOf(word.substring(index)) <= maxWidth) index,
        ];
        final candidates = bothFit.isEmpty ? [fitting.last] : bothFit;
        final compound = candidates.where(
          (index) =>
              _compoundTails.contains(word.substring(index).toLowerCase()),
        );
        final index = compound.isNotEmpty
            ? compound.first
            : candidates.reduce(
                (a, b) =>
                    (word.length - 2 * a).abs() <= (word.length - 2 * b).abs()
                    ? a
                    : b,
              );
        return '${word.substring(0, index)}-\n${word.substring(index)}';
      })
      .join(' ');
}

/// Häufige Wortteile am Ende zusammengesetzter Wörter; dort zu trennen
/// liest sich natürlicher als mitten in einer Silbe.
const _compoundTails = {
  'quote',
  'rate',
  'serie',
  'serien',
  'spiele',
  'spiel',
  'punkte',
  'tage',
  'tag',
  'zahl',
  'wert',
  'siege',
  'ausbeute',
  'verlauf',
  'bilanz',
  'rang',
  'liste',
  'dauer',
  'form',
  'heit',
  'keit',
  'ung',
  'schaft',
};

const _vowels = 'aeiouyäöüáàâãéèêíìîóòôõúùûıAEIOUYÄÖÜ';

bool _isVowel(String char) => _vowels.contains(char);

/// Mögliche Trennstellen (Index des ersten Zeichens der neuen Zeile).
/// Einfache Regel: Vor einem Vokal kommt ein Konsonant auf die neue Zeile
/// ("Nie-der-la-gen-se-rie"); "ch", "ck", "sch", "ph" und "th" bleiben
/// zusammen. Beide Teile haben mindestens zwei Buchstaben.
List<int> syllableBreaks(String word) {
  final breaks = <int>[];
  for (var i = 2; i < word.length - 1; i++) {
    final char = word[i];
    if (_isVowel(char) || !_isVowel(word[i + 1])) continue;
    var index = i;
    final pair = word.substring(i - 1, i + 1).toLowerCase();
    if (pair == 'ch' || pair == 'ph' || pair == 'th' || pair == 'ck') {
      index = i - 1;
      if (pair == 'ch' && i >= 2 && word[i - 2].toLowerCase() == 's') {
        index = i - 2;
      }
    }
    // „sch“ vor einem Konsonanten bleibt zusammen und kommt mit auf die
    // neue Zeile („unge-schlagen“, nicht „ungesch-lagen“).
    if (index == i &&
        i >= 3 &&
        word.substring(i - 3, i).toLowerCase() == 'sch') {
      index = i - 3;
    }
    if (index < 2 || word.length - index < 2) continue;
    if (!breaks.contains(index)) breaks.add(index);
  }
  return breaks;
}

/// Zeilen, die [text] bei [maxWidth] belegt (höchstens [maxLines]).
int countLines(
  String text, {
  required TextStyle style,
  required double maxWidth,
  int maxLines = 2,
  TextScaler textScaler = TextScaler.noScaling,
  TextDirection textDirection = TextDirection.ltr,
}) {
  if (!maxWidth.isFinite || maxWidth <= 0) return 1;
  final painter = TextPainter(
    text: TextSpan(text: text, style: style),
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: maxLines,
  )..layout(maxWidth: maxWidth);
  return painter.computeLineMetrics().length.clamp(1, maxLines);
}

/// Größte Zeilenzahl der [texts] nach Silbentrennung, z. B. um Titel in
/// nebeneinanderliegenden Kacheln gleich hoch zu machen.
int maxHyphenatedLines(
  Iterable<String> texts, {
  required TextStyle style,
  required double maxWidth,
  int maxLines = 2,
  TextScaler textScaler = TextScaler.noScaling,
}) {
  var result = 1;
  for (final text in texts) {
    final lines = countLines(
      hyphenateToFit(
        text,
        style: style,
        maxWidth: maxWidth,
        textScaler: textScaler,
      ),
      style: style,
      maxWidth: maxWidth,
      maxLines: maxLines,
      textScaler: textScaler,
    );
    if (lines > result) result = lines;
  }
  return result;
}
