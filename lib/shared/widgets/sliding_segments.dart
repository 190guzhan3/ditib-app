import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moschee_app/core/theme/theme.dart';

/// Auswahl aus wenigen Optionen nebeneinander: abgerundet, die gewählte
/// liegt auf einer Blase, die beim Wechsel hinübergleitet. Antippen oder
/// mit dem Finger über die Leiste ziehen.
class SlidingSegments<T> extends StatelessWidget {
  const SlidingSegments({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
  });

  final List<({T value, String label, IconData? icon})> options;
  final T value;
  final ValueChanged<T> onChanged;

  static const height = 44.0;
  static const _pad = 4.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;
    final index = options.indexWhere((o) => o.value == value).clamp(0, 99);
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - _pad * 2) / options.length;
        void pick(double dx) {
          final i = ((dx - _pad) / w).floor().clamp(0, options.length - 1);
          if (options[i].value != value) {
            HapticFeedback.selectionClick();
            onChanged(options[i].value);
          }
        }

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: (d) => pick(d.localPosition.dx),
          onHorizontalDragUpdate: (d) => pick(d.localPosition.dx),
          child: Container(
            height: height,
            padding: const EdgeInsets.all(_pad),
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(height / 2),
            ),
            child: Stack(
              children: [
                // Die Blase unter der gewählten Option.
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 380),
                  curve: Curves.easeOutBack,
                  left: index * w,
                  top: 0,
                  bottom: 0,
                  width: w,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(height / 2),
                      boxShadow: [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                  ),
                ),
                Row(
                  children: [
                    for (final (i, o) in options.indexed)
                      Expanded(
                        child: Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 220),
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: i == index
                                  ? onAccentColor(accent)
                                  : theme.colorScheme.onSurface.withValues(
                                      alpha: 0.65,
                                    ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (o.icon != null) ...[
                                  TweenAnimationBuilder<Color?>(
                                    tween: ColorTween(
                                      end: i == index
                                          ? onAccentColor(accent)
                                          : theme.colorScheme.onSurface
                                                .withValues(alpha: 0.65),
                                    ),
                                    duration: const Duration(milliseconds: 220),
                                    builder: (_, color, _) =>
                                        Icon(o.icon, size: 16, color: color),
                                  ),
                                  const SizedBox(width: 6),
                                ],
                                Flexible(
                                  child: Text(
                                    o.label,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
