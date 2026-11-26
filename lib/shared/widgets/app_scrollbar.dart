import 'dart:async';

import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

/// Scrollverhalten der App: Jede senkrechte Liste zeigt beim Scrollen rechts
/// eine schmale Leiste – man sieht, wie weit es noch geht, und kann sie
/// greifen, um schnell zu springen. (Flutter zeigt sie sonst nur am Desktop.)
class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (axisDirectionToAxis(details.direction) != Axis.vertical) return child;
    return Scrollbar(
      controller: details.controller,
      interactive: true,
      child: child,
    );
  }
}

/// Keine Scrollleiste unterhalb (z. B. wo rechts schon eine eigene Leiste sitzt).
class NoScrollbar extends StatelessWidget {
  const NoScrollbar({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => ScrollConfiguration(
    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
    child: child,
  );
}

/// Scrollleiste für [ScrollablePositionedList] (hat keinen ScrollController,
/// darum aus den sichtbaren Einträgen berechnet). Erscheint beim Scrollen,
/// lässt sich ziehen und blendet danach wieder aus.
class PositionedListScrollbar extends StatefulWidget {
  const PositionedListScrollbar({
    super.key,
    required this.positions,
    required this.controller,
    required this.itemCount,
    required this.child,
    this.bottomInset = 0,
  });

  final ItemPositionsListener positions;
  final ItemScrollController controller;
  final int itemCount;
  final Widget child;

  /// Unten verdeckter Bereich (z. B. eine schwebende Leiste).
  final double bottomInset;

  @override
  State<PositionedListScrollbar> createState() =>
      _PositionedListScrollbarState();
}

class _PositionedListScrollbarState extends State<PositionedListScrollbar> {
  bool _visible = false;
  bool _dragging = false;
  Timer? _hide;

  /// Anfang (0–1) und Anteil des sichtbaren Bereichs an der ganzen Liste.
  double _start = 0, _extent = 1;

  @override
  void initState() {
    super.initState();
    widget.positions.itemPositions.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(PositionedListScrollbar old) {
    super.didUpdateWidget(old);
    if (old.positions != widget.positions) {
      old.positions.itemPositions.removeListener(_onScroll);
      widget.positions.itemPositions.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _hide?.cancel();
    widget.positions.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  bool _first = true;

  void _onScroll() {
    final items = widget.positions.itemPositions.value;
    final n = widget.itemCount;
    if (items.isEmpty || n == 0) return;
    var first = items.first, last = items.first;
    for (final p in items) {
      if (p.index < first.index) first = p;
      if (p.index > last.index) last = p;
    }
    double part(ItemPosition p, double edge) {
      final h = p.itemTrailingEdge - p.itemLeadingEdge;
      return h <= 0 ? 0 : ((edge - p.itemLeadingEdge) / h).clamp(0.0, 1.0);
    }

    final start = (first.index + part(first, 0)) / n;
    final end = (last.index + part(last, 1)) / n;
    _start = start;
    _extent = (end - start).clamp(0.0, 1.0);
    // Der erste Aufbau ist kein Scrollen: Leiste nicht zeigen.
    if (_first) {
      _first = false;
      return;
    }
    if (_extent >= 0.999) return;
    _hide?.cancel();
    if (!_dragging) {
      _hide = Timer(const Duration(milliseconds: 1100), () {
        if (mounted) setState(() => _visible = false);
      });
    }
    setState(() => _visible = true);
  }

  void _jump(double dy, double height, double thumb) {
    final f = ((dy - thumb / 2) / (height - thumb)).clamp(0.0, 1.0);
    if (!widget.controller.isAttached) return;
    widget.controller.jumpTo(index: (f * (widget.itemCount - 1)).round());
  }

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurface;
    return Stack(
      children: [
        widget.child,
        Positioned(
          top: 0,
          right: 0,
          bottom: widget.bottomInset,
          width: 28,
          child: LayoutBuilder(
            builder: (context, c) {
              final h = c.maxHeight;
              final thumb = (h * _extent).clamp(40.0, h);
              final top =
                  (h - thumb) * (_start / (1 - _extent).clamp(0.001, 1));
              return IgnorePointer(
                ignoring: !_visible,
                child: AnimatedOpacity(
                  opacity: _visible ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  child: Stack(
                    children: [
                      Positioned(
                        top: top.clamp(0.0, h - thumb),
                        right: 0,
                        width: 28,
                        height: thumb,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onVerticalDragStart: (_) {
                            _hide?.cancel();
                            setState(() => _dragging = true);
                          },
                          onVerticalDragUpdate: (d) {
                            final box = context.findRenderObject() as RenderBox;
                            _jump(
                              box.globalToLocal(d.globalPosition).dy,
                              h,
                              thumb,
                            );
                          },
                          onVerticalDragEnd: (_) {
                            setState(() => _dragging = false);
                            _onScroll();
                          },
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 120),
                              width: _dragging ? 8 : 4,
                              margin: const EdgeInsets.only(right: 3),
                              decoration: BoxDecoration(
                                color: color.withValues(
                                  alpha: _dragging ? 0.6 : 0.4,
                                ),
                                borderRadius: BorderRadius.circular(99),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
