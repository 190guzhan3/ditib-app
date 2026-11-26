import 'package:flutter/material.dart';

/// Kleiner Monat als Kachelraster (Wochen ab Montag), wie im
/// Jahresrückblick und im Kalender-Widget des Profils.
class MiniMonthGrid extends StatelessWidget {
  const MiniMonthGrid({
    super.key,
    required this.year,
    required this.month,
    required this.tile,
    required this.label,
    required this.colorOf,
    this.borderOf,
  });

  final int year;
  final int month;
  final double tile;
  final String label;
  final Color Function(DateTime day) colorOf;

  /// Optionaler Rahmen je Tag.
  final Color? Function(DateTime day)? borderOf;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final first = DateTime(year, month);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    // Wochen beginnen am Montag.
    final offset = first.weekday - 1;
    final cells = offset + daysInMonth;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 3),
        Wrap(
          spacing: 2,
          runSpacing: 2,
          children: [
            for (var i = 0; i < cells; i++)
              if (i < offset)
                SizedBox(width: tile, height: tile)
              else
                Builder(
                  builder: (context) {
                    final day = DateTime(year, month, i - offset + 1);
                    final border = borderOf?.call(day);
                    return Container(
                      width: tile,
                      height: tile,
                      decoration: BoxDecoration(
                        color: colorOf(day),
                        borderRadius: BorderRadius.circular(tile * 0.25),
                        border: border == null
                            ? null
                            : Border.all(color: border, width: 1.5),
                      ),
                    );
                  },
                ),
          ],
        ),
      ],
    );
  }
}
