import 'package:flutter/material.dart';

/// Dezente Bewegungen, die überall gleich wirken: gleiche Dauer, gleiche
/// Kurven. Bei „Animationen reduzieren“ des Systems entfallen sie.
class AppMotion {
  const AppMotion._();

  static const short = Duration(milliseconds: 220);
  static const medium = Duration(milliseconds: 420);
  static const curve = Curves.easeOutCubic;

  static bool reduced(BuildContext context) =>
      MediaQuery.maybeDisableAnimationsOf(context) ?? false;
}

/// Pulsierender Punkt für „läuft gerade / wartet auf dich“ (z. B. offenes
/// Spiel): ein fester Punkt mit einem Ring, der langsam nach außen verblasst.
class PulsingDot extends StatefulWidget {
  const PulsingDot({super.key, required this.color, this.size = 8});

  final Color color;
  final double size;

  @override
  State<PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<PulsingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1600),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (AppMotion.reduced(context)) {
      _controller.stop();
    } else if (!_controller.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final box = widget.size * 2.4;
    return SizedBox(
      width: box,
      height: box,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = Curves.easeOut.transform(_controller.value);
          return Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: widget.size + (box - widget.size) * t,
                height: widget.size + (box - widget.size) * t,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.45 * (1 - t)),
                ),
              ),
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Blendet ein Element beim ersten Erscheinen ein und schiebt es leicht
/// nach oben. [index] staffelt Listen (gedeckelt, damit lange Listen nicht
/// ewig nachlaufen).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return child;
    final delay = (index.clamp(0, 8)) * 0.06;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration:
          AppMotion.medium + Duration(milliseconds: (delay * 1000).round()),
      curve: Interval(delay / (0.42 + delay), 1, curve: AppMotion.curve),
      child: child,
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: child,
        ),
      ),
    );
  }
}

/// Zahl, die beim Erscheinen und bei Änderungen zum neuen Wert hochzählt.
class CountUpText extends StatelessWidget {
  const CountUpText({
    super.key,
    required this.value,
    required this.format,
    this.style,
  });

  final double value;
  final String Function(double value) format;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    if (AppMotion.reduced(context)) return Text(format(value), style: style);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value),
      duration: const Duration(milliseconds: 700),
      curve: AppMotion.curve,
      builder: (context, current, _) => Text(format(current), style: style),
    );
  }
}

/// Kurzes Einblenden, sobald sich [trigger] ändert (z. B. beim Tab-Wechsel).
/// Das Kind bleibt dabei erhalten, sein Zustand geht nicht verloren.
class FadeOnChange extends StatefulWidget {
  const FadeOnChange({super.key, required this.trigger, required this.child});

  final Object? trigger;
  final Widget child;

  @override
  State<FadeOnChange> createState() => _FadeOnChangeState();
}

class _FadeOnChangeState extends State<FadeOnChange>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.short,
    value: 1,
  );

  @override
  void didUpdateWidget(FadeOnChange oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.trigger != widget.trigger && !AppMotion.reduced(context)) {
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        // Immer dieselbe Struktur, sonst würde das Kind neu aufgebaut.
        final t = AppMotion.curve.transform(_controller.value);
        return Opacity(
          opacity: 0.35 + 0.65 * t,
          child: Transform.translate(
            offset: Offset(0, 8 * (1 - t)),
            child: child,
          ),
        );
      },
    );
  }
}
