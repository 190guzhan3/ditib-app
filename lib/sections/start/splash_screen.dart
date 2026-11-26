import 'package:flutter/material.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/theme/theme.dart';

/// Animierter Startbildschirm im Anschluss an den nativen Splash: gleicher
/// weißer Grund, gleiches Logo in gleicher Größe (kein Sprung). Ein Ring
/// läuft einmal um das Logo, dann erscheint der Name. Die Mindestdauer
/// legt `App` fest, damit man ihn auch auf schnellen Handys sieht.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  static const logo = 'assets/branding/ditib_logo.png';

  /// Breite des Logos in logischen Pixeln. Die nativen Splash-Bilder sind
  /// darauf abgestimmt (720 px als 4x-Bild, Android 12: 720 px auf
  /// 1152 px), bitte nur zusammen ändern.
  static const logoWidth = 180.0;

  static const animation = Duration(milliseconds: 550);
  static const minimumDuration = Duration(milliseconds: 650);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: SplashScreen.animation,
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ring = CurvedAnimation(
      parent: _c,
      curve: const Interval(0, 0.8, curve: Curves.easeInOutCubic),
    );
    final name = CurvedAnimation(
      parent: _c,
      curve: const Interval(0.4, 1, curve: Curves.easeOut),
    );
    const w = SplashScreen.logoWidth;
    return ColoredBox(
      color: AppColors.splashBackground,
      child: LayoutBuilder(
        builder: (context, c) => Stack(
          alignment: Alignment.center,
          children: [
            AnimatedBuilder(
              animation: ring,
              builder: (context, _) => CustomPaint(
                size: const Size(w + 56, (w + 56) * 0.62),
                painter: _RingPainter(ring.value),
              ),
            ),
            Image.asset(SplashScreen.logo, width: w),
            Positioned(
              top: c.maxHeight / 2 + w * 0.42,
              child: FadeTransition(
                opacity: name,
                child: Text(
                  AppLocalizations.of(context)!.app_title,
                  style: AppTypography.titleLarge.copyWith(
                    color: AppColors.splashText,
                    letterSpacing: 4,
                    decoration: TextDecoration.none,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Roter Ring um das ovale Logo, der sich einmal schließt.
class _RingPainter extends CustomPainter {
  _RingPainter(this.t);

  final double t;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = AppColors.splashAccent.withValues(alpha: 0.5);
    canvas.drawArc(Offset.zero & size, -1.5708, 6.2832 * t, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.t != t;
}
