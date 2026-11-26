import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/settings_service.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/sections/auth/auth_screen.dart';

/// Einführung zum Wischen (wie im TeamManager), auf der letzten Seite die
/// Wahl: registrieren, anmelden oder ohne Konto – mit den Unterschieden.
///
/// [replay]: aus den Einstellungen erneut geöffnet; „Fertig“ schließt nur.
class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key, this.replay = false});

  final bool replay;

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final _pages = PageController();
  int _page = 0;

  static const _slideCount = 4;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int page) => _pages.animateToPage(
    page,
    duration: const Duration(milliseconds: 320),
    curve: Curves.easeOutCubic,
  );

  Future<void> _finish() async {
    if (widget.replay) {
      Navigator.of(context).pop();
      return;
    }
    // Wechselt in der App automatisch zur Startseite.
    await SettingsService.instance.setIntroSeen(true);
  }

  Future<void> _auth({required bool register}) async {
    if (await openAuth(context, register: register)) await _finish();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final slides = [
      (AppIcons.mosque, t.intro_mosque_title, t.intro_mosque_body),
      (AppIcons.qibla, t.intro_prayer_title, t.intro_prayer_body),
      (AppIcons.map, t.intro_nearby_title, t.intro_nearby_body),
      (AppIcons.community, t.intro_community_title, t.intro_community_body),
    ];
    final last = _page == _slideCount;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(
              height: 52,
              child: Row(
                children: [
                  if (widget.replay)
                    const AppBackButton()
                  else
                    const SizedBox(width: 12),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: TextButton(
                      onPressed: last ? null : () => _goTo(_slideCount),
                      child: Text(t.common_skip),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final s in slides)
                    _Slide(icon: s.$1, title: s.$2, body: s.$3),
                  _StartChoice(
                    onRegister: () => _auth(register: true),
                    onLogin: () => _auth(register: false),
                    onGuest: _finish,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: Row(
                children: [
                  for (var i = 0; i <= _slideCount; i++)
                    GestureDetector(
                      onTap: () => _goTo(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: _page == i ? 24 : 6,
                        decoration: BoxDecoration(
                          color: _page == i
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface.withValues(
                                  alpha: 0.2,
                                ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  const Spacer(),
                  AnimatedOpacity(
                    opacity: last ? 0 : 1,
                    duration: const Duration(milliseconds: 200),
                    child: FilledButton(
                      onPressed: last ? null : () => _goTo(_page + 1),
                      child: Text(t.common_continue),
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

class _Slide extends StatelessWidget {
  const _Slide({required this.icon, required this.title, required this.body});

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return LayoutBuilder(
      builder: (context, c) {
        final size = (c.maxHeight * 0.34).clamp(96.0, 200.0);
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: size,
                height: size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      accent.withValues(alpha: 0.22),
                      accent.withValues(alpha: 0.06),
                    ],
                  ),
                ),
                child: Icon(icon, size: size * 0.5, color: accent),
              ),
              SizedBox(height: size * 0.2),
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTypography.headline.copyWith(
                  color: theme.colorScheme.onSurface,
                  fontSize: 26,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                body,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  height: 1.45,
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Letzte Seite: die beiden Wege nebeneinander erklärt, darunter die Knöpfe.
class _StartChoice extends StatelessWidget {
  const _StartChoice({
    required this.onRegister,
    required this.onLogin,
    required this.onGuest,
  });

  final VoidCallback onRegister;
  final VoidCallback onLogin;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
      children: [
        Text(
          t.intro_start_title,
          textAlign: TextAlign.center,
          style: AppTypography.headline.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _Option(
                  icon: AppIcons.account,
                  title: t.intro_guest_title,
                  points: [t.intro_guest_1, t.intro_guest_2, t.intro_guest_3],
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _Option(
                  icon: AppIcons.community,
                  title: t.intro_account_title,
                  points: [
                    t.intro_account_1,
                    t.intro_account_2,
                    t.intro_account_3,
                  ],
                  highlighted: true,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(onPressed: onRegister, child: Text(t.intro_register)),
        const SizedBox(height: 8),
        OutlinedButton(onPressed: onLogin, child: Text(t.intro_login)),
        const SizedBox(height: 8),
        TextButton(onPressed: onGuest, child: Text(t.intro_guest)),
        const SizedBox(height: 4),
        Text(
          t.intro_later_hint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.icon,
    required this.title,
    required this.points,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final List<String> points;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: highlighted
            ? accent.withValues(alpha: 0.1)
            : theme.colorScheme.onSurface.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted
              ? accent.withValues(alpha: 0.5)
              : theme.dividerColor.withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accent),
          const SizedBox(height: 8),
          Text(title, style: theme.textTheme.titleSmall),
          const SizedBox(height: 8),
          for (final p in points)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_rounded, size: 14, color: accent),
                  ),
                  const SizedBox(width: 6),
                  Expanded(child: Text(p, style: theme.textTheme.bodySmall)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
