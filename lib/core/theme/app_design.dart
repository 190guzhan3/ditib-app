import 'package:flutter/material.dart';

/// Einheitliche Gestaltung der App. Alle Screens greifen auf diese wenigen
/// Stufen zurück statt eigene Größen, Icons oder Button-Stile zu wählen.
///
/// Schrift: Die Stufen legen nur Größe und Gewicht fest; Farben kommen aus
/// dem Theme ([buildAppTextTheme]) bzw. vom Aufrufer.
class AppTypography {
  const AppTypography._();

  /// Sehr große Zahlen auf Vollbild-Seiten (Jahresrückblick).
  static const display = TextStyle(
    fontSize: 44,
    fontWeight: FontWeight.w800,
    height: 1.05,
  );

  /// Große Zahlen (Ergebnis, Kennzahl).
  static const headline = TextStyle(fontSize: 24, fontWeight: FontWeight.w700);

  /// Screen- und Dialogtitel.
  static const titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
  );

  /// Kopf einer Karte oder eines Abschnitts.
  static const titleMedium = TextStyle(
    fontSize: 17,
    fontWeight: FontWeight.w600,
  );

  /// Hervorgehobene Einträge (Namen in Listen).
  static const titleSmall = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w600,
  );

  /// Zeilen und Haupttext.
  static const bodyLarge = TextStyle(fontSize: 15);

  /// Standardtext.
  static const body = TextStyle(fontSize: 14);

  /// Zweitrangiger Text, Hinweise.
  static const bodySmall = TextStyle(fontSize: 12);

  /// Buttons und Werte.
  static const label = TextStyle(fontSize: 14, fontWeight: FontWeight.w600);

  /// Kleine Beschriftungen (Chips, Badges).
  static const labelSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
  );

  /// Kleinste Stufe (Mini-Beschriftungen, Einheiten).
  static const caption = TextStyle(fontSize: 11);
}

/// Schriften des Themes aus den Stufen von [AppTypography].
TextTheme buildAppTextTheme({
  required Color strong,
  required Color normal,
  required Color muted,
}) {
  return TextTheme(
    headlineSmall: AppTypography.headline.copyWith(color: strong),
    titleLarge: AppTypography.titleLarge.copyWith(color: strong),
    titleMedium: AppTypography.titleMedium.copyWith(color: strong),
    titleSmall: AppTypography.titleSmall.copyWith(color: strong),
    bodyLarge: AppTypography.bodyLarge.copyWith(color: strong),
    bodyMedium: AppTypography.body.copyWith(color: normal),
    bodySmall: AppTypography.bodySmall.copyWith(color: muted),
    labelLarge: AppTypography.label.copyWith(color: strong),
    labelMedium: AppTypography.labelSmall.copyWith(color: normal),
    labelSmall: AppTypography.caption.copyWith(
      color: muted,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.3,
    ),
  );
}

/// Schrift und Icons auf der Akzentfarbe (ausgewählte Elemente, gefüllte
/// Buttons): immer weiß, nur bei sehr hellen Akzentfarben dunkel.
Color onAccentColor(Color accent) =>
    accent.computeLuminance() > 0.6 ? const Color(0xFF182026) : Colors.white;

/// Ein Icon pro Aktion, überall gleich.
class AppIcons {
  const AppIcons._();

  static const delete = Icons.delete;
  static const edit = Icons.edit_outlined;
  static const add = Icons.add;
  static const more = Icons.more_vert;
  static const info = Icons.info_outline;
  static const close = Icons.close;
  static const copy = Icons.copy_outlined;
  static const share = Icons.share_outlined;
  static const settings = Icons.settings_outlined;
  static const chevron = Icons.chevron_right;
  static const qibla = Icons.explore_outlined;
  static const mosque = Icons.mosque;
  static const map = Icons.map_outlined;
  static const list = Icons.view_list_rounded;
  static const search = Icons.search;
  static const place = Icons.place_outlined;
  static const star = Icons.star_rounded;
  static const starOutline = Icons.star_outline_rounded;
  static const verified = Icons.verified;
  static const calendar = Icons.event_outlined;
  static const notice = Icons.campaign_outlined;
  static const time = Icons.schedule;
  static const radius = Icons.radar;
  static const sort = Icons.sort_rounded;
  static const interest = Icons.waving_hand_outlined;
  static const interestDone = Icons.waving_hand;
  static const report = Icons.flag_outlined;
  static const account = Icons.person_outline;
  static const login = Icons.login_rounded;
  static const logout = Icons.logout;
  static const community = Icons.volunteer_activism_outlined;
  static const communityActive = Icons.volunteer_activism;
  static const home = Icons.home_outlined;
  static const homeActive = Icons.home_rounded;
  static const mosquesNav = Icons.mosque_outlined;
  static const myLocation = Icons.my_location_rounded;
  static const admin = Icons.admin_panel_settings_outlined;
  static const adminActive = Icons.admin_panel_settings;
  static const lock = Icons.lock_outline;
  static const phone = Icons.phone_outlined;
  static const web = Icons.language;
}

/// Knopf der Schieberegler: Kreis in der Akzentfarbe mit hellem Kern, der
/// beim Ziehen leicht wächst.
class AppSliderThumbShape extends SliderComponentShape {
  const AppSliderThumbShape({this.radius = 10});

  final double radius;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      Size.fromRadius(radius * 1.2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    final color =
        ColorTween(
          begin: sliderTheme.disabledThumbColor,
          end: sliderTheme.thumbColor,
        ).evaluate(enableAnimation) ??
        Colors.grey;
    final r = radius * (1 + 0.2 * activationAnimation.value);
    canvas.drawCircle(
      center.translate(0, 1),
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
    canvas.drawCircle(center, r, Paint()..color = color);
    canvas.drawCircle(center, r * 0.42, Paint()..color = Colors.white);
  }
}

/// Einheitliche Schieberegler: kräftige, abgerundete Spur ohne
/// Rasterpunkte und der Knopf aus [AppSliderThumbShape].
SliderThemeData buildAppSliderTheme({
  required Color accent,
  required Color muted,
}) {
  return SliderThemeData(
    trackHeight: 6,
    activeTrackColor: accent,
    inactiveTrackColor: accent.withValues(alpha: 0.18),
    disabledActiveTrackColor: muted.withValues(alpha: 0.5),
    disabledInactiveTrackColor: muted.withValues(alpha: 0.15),
    thumbColor: accent,
    disabledThumbColor: muted,
    overlayColor: accent.withValues(alpha: 0.12),
    overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
    thumbShape: const AppSliderThumbShape(),
    trackShape: const RoundedRectSliderTrackShape(),
    tickMarkShape: SliderTickMarkShape.noTickMark,
    valueIndicatorShape: const RoundedRectSliderValueIndicatorShape(),
    valueIndicatorColor: accent,
    valueIndicatorTextStyle: AppTypography.labelSmall.copyWith(
      color: onAccentColor(accent),
    ),
    showValueIndicator: ShowValueIndicator.onDrag,
  );
}

/// Die wenigen Button-Varianten der App. Grundstil kommt aus dem Theme;
/// hier stehen nur die Abweichungen.
class AppButtonStyles {
  const AppButtonStyles._();

  /// Unumkehrbare Aktionen (Löschen, Entfernen).
  static ButtonStyle destructive(BuildContext context) =>
      ElevatedButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.error,
        foregroundColor: Colors.white,
      );

  /// Kleine Buttons in Kopfzeilen und Karten ("+ Hinzufügen").
  static ButtonStyle compact(BuildContext context) => ElevatedButton.styleFrom(
    visualDensity: VisualDensity.compact,
    padding: const EdgeInsets.symmetric(horizontal: 12),
    minimumSize: const Size(0, 36),
    textStyle: AppTypography.labelSmall,
  );
}

/// Einheitliche Bestätigung: Abbrechen links, Aktion rechts; bei
/// unumkehrbaren Aktionen in der Fehlerfarbe.
Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, false),
          child: Text(cancelLabel),
        ),
        ElevatedButton(
          style: destructive
              ? AppButtonStyles.destructive(dialogContext)
              : null,
          onPressed: () => Navigator.pop(dialogContext, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result == true;
}
