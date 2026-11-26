import 'package:flutter/material.dart';
import 'package:moschee_app/core/theme/app_design.dart';

export 'package:moschee_app/core/theme/app_design.dart';

/// Hervorhebung eines eigenen/ausgewählten Eintrags in Listen und Tabellen.
class AppHighlight {
  static Color ownFill(ThemeData theme, {Color? on}) => Color.alphaBlend(
    theme.colorScheme.primary.withValues(alpha: 0.12),
    on ?? theme.colorScheme.surfaceContainerHighest,
  );
}

/// Feste Farben der App. Die Akzentfarbe ist wählbar (SettingsService).
class AppColors {
  // Hintergrund & Flächen (Dark Mode)
  static const Color background = Color(0xFF0F0F0F);
  static const Color surface = Color(0xFF1F1F1F);

  // Status
  static const Color error = Color.fromARGB(255, 173, 71, 64);
  static const Color success = Colors.green;
  static const Color warning = Color.fromARGB(255, 208, 168, 87);

  /// Hervorgehobene Zusatzaktion (z. B. "Cloud aktivieren", Upgrade).
  static const Color highlight = Color(0xFFE59A2E);

  /// Hinweise (Demo-Modus, Tipps): ein Hinweis, keine Warnung.
  static const Color guide = Color(0xFFF5B82E);
  static const Color guideOnLight = Color(0xFFB7791F);
  static Color guideOf(Brightness brightness) =>
      brightness == Brightness.dark ? guide : guideOnLight;

  /// Auswahl für die Akzentfarbe in den Einstellungen.
  static const List<Color> accentChoices = [
    Color(0xFF4F8EF7),
    Color(0xFF26A69A),
    Color(0xFF66BB6A),
    Color(0xFFFFA726),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF8D6E63),
    Color(0xFF78909C),
  ];

  /// Ruhiges Grün-Türkis, passend zum Landesjugendverband.
  static const Color defaultAccent = Color(0xFF26A69A);

  // Arten von Terminen und Ankündigungen (Badges, Datumskacheln).
  static const Color kindCenaze = Color(0xFF64748B);
  static const Color kindCourse = Color(0xFF4F8EF7);
  static const Color kindFestival = Color(0xFFE59A2E);
  static const Color kindYouth = Color(0xFFAB47BC);
  static const Color kindEvent = Color(0xFF26A69A);
  static const Color kindInfo = Color(0xFF78909C);

  /// Farben für eigene Kategorien (Verwaltung).
  static const List<Color> categoryChoices = [
    Color(0xFF26A69A),
    Color(0xFF4F8EF7),
    Color(0xFF43A047),
    Color(0xFFE59A2E),
    Color(0xFFE53935),
    Color(0xFFD81B60),
    Color(0xFFAB47BC),
    Color(0xFF5C6BC0),
    Color(0xFF8D6E63),
    Color(0xFF64748B),
  ];

  /// Eigener Standort auf der Karte.
  static const Color myLocation = Color(0xFF2F7DF6);

  // Community: Biete / Suche.
  static const Color offer = Color(0xFF2E9E5B);
  static const Color request = Color(0xFF4F8EF7);

  // Splash: Hintergrund passend zum Logo (weiß), auch im Dark Mode.
  static const Color splashBackground = Colors.white;
  static const Color splashText = Color(0xFF3A3A3A);
  static const Color splashAccent = Color(0xFFE30613);
}

class AppFormStyles {
  static TextStyle? settingsFieldTextStyle(
    BuildContext context, {
    bool enabled = true,
  }) {
    final theme = Theme.of(context);
    final base = theme.textTheme.labelLarge;
    if (enabled) return base;
    return base?.copyWith(
      color: theme.colorScheme.onSurface.withValues(alpha: 0.38),
    );
  }

  static InputDecoration decoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
    bool isDense = true,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.symmetric(
      horizontal: 12,
      vertical: 8,
    ),
  }) {
    final theme = Theme.of(context);
    final border = OutlineInputBorder(borderRadius: BorderRadius.circular(8));
    final disabledBorder = border.copyWith(
      borderSide: BorderSide(color: Colors.transparent),
    );
    final disabledFill = theme.colorScheme.onSurface.withValues(alpha: 0.12);
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabled: enabled,
      isDense: isDense,
      filled: true,
      fillColor: enabled
          ? theme.colorScheme.surfaceContainerHighest
          : disabledFill,
      labelStyle: TextStyle(
        color: enabled
            ? theme.inputDecorationTheme.labelStyle?.color
            : theme.colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      floatingLabelStyle: TextStyle(
        color: enabled
            ? (theme.inputDecorationTheme.labelStyle?.color ??
                  theme.colorScheme.onSurface)
            : theme.colorScheme.onSurface.withValues(alpha: 0.38),
      ),
      contentPadding: contentPadding,
      border: border,
      enabledBorder: border.copyWith(
        borderSide: BorderSide(
          color: theme.colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
      disabledBorder: disabledBorder,
      focusedBorder: border.copyWith(
        borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
      ),
      errorBorder: border.copyWith(
        borderSide: BorderSide(color: theme.colorScheme.error),
      ),
      focusedErrorBorder: border.copyWith(
        borderSide: BorderSide(color: theme.colorScheme.error, width: 2),
      ),
    ).applyDefaults(theme.inputDecorationTheme);
  }

  static InputDecoration settingsDecoration(
    BuildContext context, {
    String? labelText,
    String? hintText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool enabled = true,
  }) {
    return decoration(
      context,
      labelText: labelText,
      hintText: hintText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabled: enabled,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    );
  }
}

class AppHeaderIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final double iconSize;
  final EdgeInsetsGeometry margin;

  /// Beschreibung für Screenreader und langes Drücken. Zurück- und
  /// Schließen-Symbole bekommen sie automatisch.
  final String? tooltip;

  const AppHeaderIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconSize = 22,
    this.margin = const EdgeInsets.only(left: 8),
    this.tooltip,
  });

  String? _tooltipOf(BuildContext context) {
    if (tooltip != null) return tooltip;
    final material = MaterialLocalizations.of(context);
    if (icon == Icons.arrow_back) return material.backButtonTooltip;
    if (icon == Icons.close) return material.closeButtonTooltip;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: IconButton(
          constraints: const BoxConstraints(),
          padding: const EdgeInsets.all(8),
          icon: Icon(
            icon,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.62),
            size: iconSize,
          ),
          onPressed: onPressed,
          tooltip: _tooltipOf(context),
        ),
      ),
    );
  }
}

/// Auffälliger Button für eine besondere Zusatzaktion (Upgrade, Cloud).
class AppHighlightButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool expanded;

  const AppHighlightButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.expanded = true,
  });

  @override
  Widget build(BuildContext context) {
    final button = ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.highlight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
      onPressed: onPressed,
      icon: const Icon(Icons.bolt, size: 18),
      label: Text(label),
    );

    if (!expanded) return button;
    return SizedBox(width: double.infinity, child: button);
  }
}

// --- Das globale Dark Theme ---
ThemeData buildDarkTheme(Color primaryColor) {
  return _withSharedComponents(
    _buildDarkBase(primaryColor),
    surface: AppColors.surface,
    strong: Colors.white,
    normal: Colors.white70,
    muted: Colors.grey,
  );
}

ThemeData _buildDarkBase(Color primaryColor) {
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,

    // ColorScheme ist das Herzstück von Material 3
    colorScheme: ColorScheme.dark(
      primary: primaryColor,
      onPrimary: onAccentColor(primaryColor),
      // Ohne Angabe nähme Flutter sein Standard-Türkis (#03DAC6) – z. B.
      // für die Markierung in der Seitenleiste und gewählte Schalter.
      secondary: primaryColor,
      onSecondary: onAccentColor(primaryColor),
      secondaryContainer: Color.alphaBlend(
        primaryColor.withValues(alpha: 0.28),
        AppColors.surface,
      ),
      onSecondaryContainer: Colors.white,
      tertiary: primaryColor,
      onTertiary: onAccentColor(primaryColor),
      surface: AppColors.surface,
      error: AppColors.error,
    ),

    // Standard-Hintergrund und einheitliche Größe/Abstände für Dialoge
    cardColor: AppColors.surface,
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),

    // --- KOMPONENTEN THEMES ---
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      // Etwas mehr Luft unter der Statusleiste, überall gleich.
      toolbarHeight: 64,
    ),

    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey,
      selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    ),

    cardTheme: CardThemeData(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: primaryColor.withValues(alpha: 0.3),
          width: 1,
        ), // Dezenterer Rand
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),

    listTileTheme: const ListTileThemeData(
      iconColor: Colors.white70,
      textColor: Colors.white,
      dense: true,
    ),

    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: AppColors.surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),

    iconTheme: const IconThemeData(color: Colors.white70),
    dividerTheme: const DividerThemeData(color: Colors.white12, thickness: 1),
    // Ladeanzeigen überall gleich: in der Themenfarbe, der Balken etwas
    // dicker und abgerundet auf einer dezenten Spur.
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: primaryColor,
      linearTrackColor: primaryColor.withValues(alpha: 0.15),
      circularTrackColor: Colors.transparent,
      linearMinHeight: 6,
      borderRadius: BorderRadius.circular(99),
      strokeCap: StrokeCap.round,
      // Moderne Darstellung (Lücke zwischen Balken und Spur); bis Flutter sie
      // zum Standard macht, nur über dieses (veraltete) Flag erreichbar.
      // ignore: deprecated_member_use
      year2023: false,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.fixed,
      backgroundColor: const Color(0xFF262626),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 10,
      actionTextColor: primaryColor,
      insetPadding: EdgeInsets.zero,
      showCloseIcon: false,
    ),

    // Buttons
    // 1. ELEVATED BUTTON (Deine Basis)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onAccentColor(primaryColor),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),

    // 2. OUTLINED BUTTON (Neu hinzugefügt für deine Sekundär-Aktionen)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(
          color: Colors.grey[700]!,
        ), // Dezenter Rand statt knallbunt
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),

    // 3. TEXT BUTTON (Deine Basis)
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),

    // 4. SEGMENTED BUTTON (Deine Basis)
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: primaryColor,
        selectedForegroundColor: onAccentColor(primaryColor),
        foregroundColor: Colors.white,
        backgroundColor: Colors.transparent,
        side: BorderSide(color: primaryColor),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.grey.shade500;
        }
        if (states.contains(WidgetState.selected)) {
          return primaryColor;
        }
        return Colors.white70;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return Colors.white10;
        }
        if (states.contains(WidgetState.selected)) {
          return primaryColor.withValues(alpha: 0.35);
        }
        return Colors.white24;
      }),
      // Ohne weißen Rand; die graue Spur zeigt den ausgeschalteten Zustand.
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}

ThemeData buildLightTheme(Color primaryColor) {
  return _withSharedComponents(
    _buildLightBase(primaryColor),
    surface: Colors.white,
    strong: const Color(0xFF20242B),
    normal: const Color(0xFF4F5763),
    muted: const Color(0xFF747A84),
  );
}

ThemeData _buildLightBase(Color primaryColor) {
  const background = Color(0xFFF5F7FA);
  const surface = Colors.white;
  const onSurface = Color(0xFF20242B);
  final onPrimary = onAccentColor(primaryColor);

  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: background,
    colorScheme: ColorScheme.light(
      primary: primaryColor,
      onPrimary: onPrimary,
      // Sonst Flutters Standard-Türkis (siehe dunkles Schema).
      secondary: primaryColor,
      onSecondary: onPrimary,
      secondaryContainer: Color.alphaBlend(
        primaryColor.withValues(alpha: 0.18),
        surface,
      ),
      onSecondaryContainer: onSurface,
      tertiary: primaryColor,
      onTertiary: onPrimary,
      surface: surface,
      onSurface: onSurface,
      error: AppColors.error,
    ),
    cardColor: surface,
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: background,
      foregroundColor: onSurface,
      elevation: 0,
      centerTitle: true,
      // Etwas mehr Luft unter der Statusleiste, überall gleich.
      toolbarHeight: 64,
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primaryColor,
      unselectedItemColor: const Color(0xFF747A84),
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w600),
    ),
    cardTheme: CardThemeData(
      color: surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: const Color(0xFF20242B).withValues(alpha: 0.1)),
      ),
      elevation: 0,
      margin: const EdgeInsets.symmetric(vertical: 8),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: Color(0xFF5B6370),
      textColor: onSurface,
      dense: true,
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: const TextStyle(color: Color(0xFF5B6370)),
      filled: true,
      fillColor: const Color(0xFFF0F2F5),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor.withValues(alpha: 0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: primaryColor, width: 2),
      ),
    ),
    iconTheme: const IconThemeData(color: Color(0xFF5B6370)),
    dividerTheme: const DividerThemeData(
      color: Color(0x1A20242B),
      thickness: 1,
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.fixed,
      backgroundColor: const Color(0xFF20242B),
      contentTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      elevation: 10,
      actionTextColor: primaryColor,
      insetPadding: EdgeInsets.zero,
      showCloseIcon: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: onSurface,
        side: const BorderSide(color: Color(0xFFCCD1D8)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: const TextStyle(fontWeight: FontWeight.bold),
      ),
    ),
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: SegmentedButton.styleFrom(
        selectedBackgroundColor: primaryColor,
        selectedForegroundColor: onPrimary,
        foregroundColor: onSurface,
        backgroundColor: const Color(0xFFF0F2F5),
        side: BorderSide(color: primaryColor.withValues(alpha: 0.55)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey.shade400;
        return states.contains(WidgetState.selected)
            ? primaryColor
            : Colors.white;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) {
          return const Color(0x1A20242B);
        }
        return states.contains(WidgetState.selected)
            ? primaryColor.withValues(alpha: 0.35)
            : const Color(0xFFB9C0C9);
      }),
      // Ohne den dunklen Standardrand, wie im Dark Mode.
      trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
    ),
  );
}

/// Komponenten, die in hellem und dunklem Design gleich aufgebaut sind.
/// Nur die Farben unterscheiden sich.
ThemeData _withSharedComponents(
  ThemeData base, {
  required Color surface,
  required Color strong,
  required Color normal,
  required Color muted,
}) {
  final textTheme = buildAppTextTheme(
    strong: strong,
    normal: normal,
    muted: muted,
  );
  const radius = 16.0;
  return base.copyWith(
    textTheme: textTheme,
    // Zurück und Schließen überall als runde, dezent hinterlegte Buttons
    // (wie AppHeaderIconButton), auch auf Systemseiten wie den Lizenzen.
    actionIconTheme: ActionIconThemeData(
      backButtonIconBuilder: (context) =>
          const _HeaderCircleIcon(Icons.arrow_back),
      closeButtonIconBuilder: (context) => const _HeaderCircleIcon(Icons.close),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      // Alle Dialoge gleich breit: auf dem Handy die volle Breite abzüglich
      // Rand, auf großen Displays höchstens 520.
      constraints: const BoxConstraints(minWidth: 520, maxWidth: 520),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: textTheme.titleLarge,
      contentTextStyle: textTheme.bodyMedium?.copyWith(height: 1.4),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      modalBackgroundColor: surface,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    // Menüs im Darkmode etwas heller als die Karten, damit ihr Rand
    // sichtbar ist (Schatten wirken auf dunklem Grund kaum).
    popupMenuTheme: PopupMenuThemeData(
      color: base.brightness == Brightness.dark
          ? Color.lerp(surface, Colors.white, 0.09)
          : surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: textTheme.bodyMedium?.copyWith(color: strong),
      labelTextStyle: WidgetStatePropertyAll(
        textTheme.bodyMedium?.copyWith(color: strong),
      ),
    ),
    listTileTheme: base.listTileTheme.copyWith(
      dense: false,
      titleTextStyle: textTheme.bodyLarge,
      subtitleTextStyle: textTheme.bodySmall,
      leadingAndTrailingTextStyle: textTheme.bodyMedium,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: base.elevatedButtonTheme.style?.copyWith(
        textStyle: const WidgetStatePropertyAll(AppTypography.label),
        minimumSize: const WidgetStatePropertyAll(Size(64, 44)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: base.outlinedButtonTheme.style?.copyWith(
        textStyle: const WidgetStatePropertyAll(AppTypography.label),
        minimumSize: const WidgetStatePropertyAll(Size(64, 44)),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: base.textButtonTheme.style?.copyWith(
        textStyle: const WidgetStatePropertyAll(AppTypography.label),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        textStyle: AppTypography.label,
        minimumSize: const Size(64, 44),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius - 4),
        ),
      ),
    ),
    // Chips flach und rund: dezenter Rand statt schwarzer Linie, gewählt
    // in der Akzentfarbe.
    chipTheme: base.chipTheme.copyWith(
      labelStyle: textTheme.labelMedium,
      shape: const StadiumBorder(),
      side: BorderSide(color: strong.withValues(alpha: 0.12)),
      backgroundColor: surface,
      selectedColor: base.colorScheme.primary.withValues(alpha: 0.16),
      checkmarkColor: base.colorScheme.primary,
      showCheckmark: false,
    ),
    sliderTheme: buildAppSliderTheme(
      accent: base.colorScheme.primary,
      muted: muted,
    ),
  );
}

class _HeaderCircleIcon extends StatelessWidget {
  const _HeaderCircleIcon(this.icon);

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    // Der IconButton der AppBar begrenzt das Symbol auf 24 px; der Kreis
    // darf darüber hinausragen, damit er so groß ist wie AppHeaderIconButton.
    return OverflowBox(
      maxWidth: 38,
      maxHeight: 38,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: onSurface.withValues(alpha: 0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 22, color: onSurface.withValues(alpha: 0.62)),
      ),
    );
  }
}

/// Runder Speichern-Haken oben rechts, im selben Stil und gleich groß wie
/// Zurück/Schließen oben links.
class AppSaveButton extends StatelessWidget {
  const AppSaveButton({super.key, required this.onPressed, this.tooltip});

  final VoidCallback? onPressed;
  final String? tooltip;

  @override
  Widget build(BuildContext context) => AnimatedOpacity(
    opacity: onPressed == null ? 0.35 : 1,
    duration: const Duration(milliseconds: 150),
    child: AppHeaderIconButton(
      icon: Icons.check,
      onPressed: onPressed,
      tooltip: tooltip,
      margin: const EdgeInsets.only(right: 12),
    ),
  );
}

/// Zurück bzw. Schließen (bei Vollbild-Dialogen) – gleich groß und im
/// gleichen Stil wie die übrigen runden Kopf-Buttons.
class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key});

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    final close = route is PageRoute && route.fullscreenDialog;
    return AppHeaderIconButton(
      icon: close ? Icons.close : Icons.arrow_back,
      margin: const EdgeInsets.only(left: 12),
      onPressed: () => Navigator.of(context).maybePop(),
    );
  }
}
