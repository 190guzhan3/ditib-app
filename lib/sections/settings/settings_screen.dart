import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/location_service.dart';
import 'package:moschee_app/core/services/prayer_times.dart';
import 'package:moschee_app/sections/mosques/location_actions.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/mosques/mosque_labels.dart';
import 'package:moschee_app/sections/settings/account_card.dart';
import 'package:moschee_app/sections/start/welcome_screen.dart';
import 'package:moschee_app/shared/widgets/app_segmented_button.dart';
import 'package:moschee_app/shared/widgets/section_title.dart';
import 'package:moschee_app/shared/widgets/settings_tiles.dart';
import 'package:moschee_app/shared/widgets/sliding_segments.dart';
import 'package:moschee_app/shared/widgets/widget_container.dart';

/// Einstellungen öffnen: über allem, ohne Tab-Leiste darunter.
void openSettings(BuildContext context) => Navigator.of(
  context,
  rootNavigator: true,
).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));

/// Allgemein (Konto, Sprache, Design), Gebetszeiten, Daten, Über die App.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  /// Sprachen in ihrer eigenen Schreibweise.
  static const _languageNames = {
    'de': 'Deutsch',
    'tr': 'Türkçe',
    'en': 'English',
  };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final settings = SettingsService.instance;
    return Scaffold(
      // Ohne Überschrift wie alle Seiten; nur der Zurück-Knopf.
      appBar: AppBar(leading: const AppBackButton()),
      body: ListenableBuilder(
        listenable: settings,
        builder: (context, _) => ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          children: [
            SectionTitle(t.settings_general),
            WidgetContainer(
              padding: WidgetContainer.settingsPadding,
              child: Column(
                children: [
                  const AccountCard(),
                  const Divider(height: 1),
                  SettingsGroup(
                    children: [
                      // Standard ist die Systemsprache; angezeigt wird
                      // trotzdem die Sprache selbst, nicht „System“.
                      SettingsChoiceTile<String>(
                        title: t.settings_language,
                        value: settings.effectiveLanguage,
                        options: [
                          for (final code in SettingsService.languages)
                            MapEntry(code, _languageNames[code]!),
                        ],
                        onChanged: (code) => settings.setLocale(Locale(code)),
                      ),
                      ListenableBuilder(
                        listenable: LocationService.instance,
                        builder: (context, _) => SettingsSwitchTile(
                          title: t.location_use,
                          subtitle: t.location_hint,
                          value: LocationService.instance.enabled,
                          onChanged: (on) => on
                              ? enableLocation(context)
                              : LocationService.instance.disable(),
                        ),
                      ),
                      SettingsBlock(
                        title: t.settings_theme,
                        child: SlidingSegments<ThemeMode>(
                          options: [
                            (
                              value: ThemeMode.system,
                              label: t.theme_system,
                              icon: Icons.contrast_rounded,
                            ),
                            (
                              value: ThemeMode.light,
                              label: t.theme_light,
                              icon: Icons.light_mode_rounded,
                            ),
                            (
                              value: ThemeMode.dark,
                              label: t.theme_dark,
                              icon: Icons.dark_mode_rounded,
                            ),
                          ],
                          value: settings.themeMode,
                          onChanged: settings.setThemeMode,
                        ),
                      ),
                      SettingsBlock(
                        title: t.settings_accent,
                        child: _AccentPicker(
                          value: settings.accent,
                          onChanged: settings.setAccent,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SectionTitle(t.settings_prayer),
            WidgetContainer(
              padding: WidgetContainer.settingsPadding,
              child: SettingsGroup(
                children: [
                  SettingsChoiceTile<PrayerMethod>(
                    title: t.settings_prayer_method,
                    value: settings.prayerMethod,
                    options: [
                      for (final m in PrayerMethod.values)
                        MapEntry(m, t.prayerMethod(m)),
                    ],
                    onChanged: settings.setPrayerMethod,
                  ),
                ],
              ),
            ),
            SectionTitle(t.settings_data),
            WidgetContainer(
              padding: WidgetContainer.settingsPadding,
              child: SettingsGroup(
                children: [
                  SettingsBlock(
                    title: t.settings_mode,
                    subtitle: SettingsService.cloudAvailable
                        ? t.mode_hint
                        : '${t.mode_hint} ${t.mode_cloud_unavailable}',
                    child: AppSegmentedButton<AppMode>(
                      segments: [
                        ButtonSegment(
                          value: AppMode.testData,
                          label: Text(t.mode_test),
                          icon: const Icon(Icons.science_outlined),
                        ),
                        ButtonSegment(
                          value: AppMode.cloud,
                          label: Text(t.mode_cloud),
                          icon: const Icon(Icons.cloud_outlined),
                          enabled: SettingsService.cloudAvailable,
                        ),
                      ],
                      selected: {settings.mode},
                      onSelectionChanged: (s) => settings.setMode(s.first),
                    ),
                  ),
                  // Vorübergehend, bis Rollen aus der Cloud kommen.
                  SettingsSwitchTile(
                    leading: const Icon(AppIcons.admin),
                    title: t.admin_preview_setting,
                    subtitle: t.admin_preview_hint,
                    value: settings.adminPreview,
                    onChanged: settings.setAdminPreview,
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.slideshow_outlined),
                    title: t.settings_show_intro,
                    trailing: const Icon(AppIcons.chevron),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const WelcomeScreen(replay: true),
                      ),
                    ),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.restart_alt),
                    title: t.settings_reset,
                    onTap: settings.reset,
                  ),
                ],
              ),
            ),
            SectionTitle(t.settings_about),
            WidgetContainer(
              padding: WidgetContainer.settingsPadding,
              child: SettingsGroup(
                children: [
                  FutureBuilder(
                    future: PackageInfo.fromPlatform(),
                    builder: (context, snap) => SettingsTile(
                      leading: const Icon(AppIcons.info),
                      title: t.settings_version,
                      trailing: Text(
                        snap.hasData
                            ? '${snap.data!.version} (${snap.data!.buildNumber})'
                            : '',
                        style: SettingsTextStyles.value(context),
                      ),
                    ),
                  ),
                  SettingsTile(
                    leading: const Icon(Icons.description_outlined),
                    title: t.settings_licenses,
                    trailing: const Icon(AppIcons.chevron),
                    onTap: () => showLicensePage(
                      context: context,
                      applicationName: t.app_title,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Farbkreise zur Wahl der Akzentfarbe.
class _AccentPicker extends StatelessWidget {
  const _AccentPicker({required this.value, required this.onChanged});

  final Color value;
  final ValueChanged<Color> onChanged;

  @override
  Widget build(BuildContext context) {
    final onSurface = Theme.of(context).colorScheme.onSurface;
    return LayoutBuilder(
      builder: (context, c) {
        const spacing = 8.0;
        final count = AppColors.accentChoices.length;
        final size = ((c.maxWidth - spacing * (count - 1)) / count).clamp(
          22.0,
          38.0,
        );
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final color in AppColors.accentChoices)
              GestureDetector(
                onTap: () => onChanged(color),
                // Gewählt: Ring rückt nach außen. Keine Kurve mit Nachfedern
                // (easeOutBack): Sie macht den Abstand kurz negativ, und
                // Container wirft dann einen Fehler (roter Bildschirm).
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  width: size,
                  height: size,
                  padding: EdgeInsets.all(
                    color.toARGB32() == value.toARGB32() ? 3 : 0,
                  ),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.toARGB32() == value.toARGB32()
                          ? onSurface
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
