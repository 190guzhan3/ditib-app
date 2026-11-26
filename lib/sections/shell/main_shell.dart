import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/sections/admin/admin_screen.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/community/community_screen.dart';
import 'package:moschee_app/sections/home/home_screen.dart';
import 'package:moschee_app/sections/mosques/mosques_screen.dart';
import 'package:moschee_app/shared/widgets/app_motion.dart';

/// Grundgerüst: drei Tabs (Start, Moscheen, Community), für Verantwortliche
/// ein vierter (Verwaltung). Einstellungen und Qibla liegen oben in der
/// Kopfleiste jedes Tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _tab = 0;

  static const _pages = [
    HomeScreen(),
    MosquesScreen(),
    CommunityScreen(),
    AdminScreen(),
  ];

  /// Verwaltung nur für Verantwortliche (vorerst: Vorschau-Schalter).
  bool get _showAdmin => SettingsService.instance.adminPreview;

  @override
  void initState() {
    super.initState();
    SettingsService.instance.addListener(_onSettings);
  }

  void _onSettings() {
    // Verwaltung ausgeschaltet, während sie offen war: zurück zum Start.
    if (!_showAdmin && _tab == 3) setState(() => _tab = 0);
    setState(() {});
  }

  /// Jeder Tab bekommt seinen eigenen PrimaryScrollController. Sonst
  /// hängen die Listen aller Tabs (im IndexedStack gleichzeitig aufgebaut)
  /// am selben Controller, und die greifbare Scrollleiste stürzt ab
  /// („ScrollController attached to more than one ScrollPosition“).
  final _scrollControllers = List.generate(
    _pages.length,
    (_) => ScrollController(),
  );

  @override
  void dispose() {
    SettingsService.instance.removeListener(_onSettings);
    for (final c in _scrollControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _select(int i) {
    // Nochmal auf den aktiven Tab: nach oben scrollen.
    if (i == _tab) {
      final c = _scrollControllers[i];
      if (c.hasClients) {
        c.animateTo(0, duration: AppMotion.medium, curve: AppMotion.curve);
      }
      return;
    }
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Scaffold(
      body: IndexedStack(
        index: _tab,
        children: [
          for (final (i, page) in _pages.indexed)
            if (i < 3 || _showAdmin)
              PrimaryScrollController(
                controller: _scrollControllers[i],
                child: page,
              ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _tab,
        onTap: _select,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: theme.colorScheme.primary,
        unselectedItemColor: theme.disabledColor,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(AppIcons.home),
            activeIcon: const Icon(AppIcons.homeActive),
            label: t.nav_home,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppIcons.mosquesNav),
            activeIcon: const Icon(AppIcons.mosque),
            label: t.nav_mosques,
          ),
          BottomNavigationBarItem(
            icon: const Icon(AppIcons.community),
            activeIcon: const Icon(AppIcons.communityActive),
            label: t.nav_community,
          ),
          if (_showAdmin)
            BottomNavigationBarItem(
              icon: const Icon(AppIcons.admin),
              activeIcon: const Icon(AppIcons.adminActive),
              label: t.nav_admin,
            ),
        ],
      ),
    );
  }
}
