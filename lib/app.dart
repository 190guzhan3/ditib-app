import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/shell/main_shell.dart';
import 'package:moschee_app/sections/start/splash_screen.dart';
import 'package:moschee_app/sections/start/welcome_screen.dart';
import 'package:moschee_app/shared/widgets/app_scrollbar.dart';

/// Ablauf: Splash (mindestens [SplashScreen.minimumDuration], solange die
/// Daten laden) → beim ersten Start die Einführung → die App.
class App extends StatefulWidget {
  const App({super.key, this.splashDuration = SplashScreen.minimumDuration});

  final Duration splashDuration;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _settings = SettingsService.instance;
  late AppMode _attachedMode = _settings.mode;
  bool _splashDone = false;

  @override
  void initState() {
    super.initState();
    _settings.addListener(_onSettingsChanged);
    Future.wait([
      DataRepository.instance.attach(_attachedMode),
      Future<void>.delayed(widget.splashDuration),
    ]).whenComplete(() {
      if (mounted) setState(() => _splashDone = true);
    });
  }

  @override
  void dispose() {
    _settings.removeListener(_onSettingsChanged);
    super.dispose();
  }

  /// Datenquelle bei Moduswechsel austauschen.
  void _onSettingsChanged() {
    if (_attachedMode != _settings.mode) {
      _attachedMode = _settings.mode;
      DataRepository.instance.attach(_attachedMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Weiß hinter der App, bis der Splash vorbei ist: Das erste Bild von
    // MaterialApp ist leer (Übersetzungen laden), sonst blitzt es schwarz
    // zwischen nativem und animiertem Splash.
    return ColoredBox(
      color: _splashDone ? Colors.transparent : AppColors.splashBackground,
      child: ListenableBuilder(
        listenable: _settings,
        builder: (context, _) => MaterialApp(
          onGenerateTitle: (context) => AppLocalizations.of(context)!.app_title,
          debugShowCheckedModeBanner: false,
          // Greifbare Scrollleiste in allen senkrechten Listen.
          scrollBehavior: const AppScrollBehavior(),
          theme: buildLightTheme(_settings.accent),
          darkTheme: buildDarkTheme(_settings.accent),
          themeMode: _settings.themeMode,
          locale: _settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          // Tippen auf eine freie Stelle schließt überall die Tastatur.
          builder: (context, child) => GestureDetector(
            onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
            child: child,
          ),
          home: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            switchInCurve: Curves.easeOut,
            child: !_splashDone
                ? const SplashScreen(key: ValueKey('splash'))
                : !_settings.introSeen
                ? const WelcomeScreen(key: ValueKey('intro'))
                : const MainShell(key: ValueKey('shell')),
          ),
        ),
      ),
    );
  }
}
