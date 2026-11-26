import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:moschee_app/core/data/data_repository.dart';
import 'package:moschee_app/core/l10n/app_localizations.dart';
import 'package:moschee_app/core/services/location_service.dart';
import 'package:moschee_app/core/services/prayer_times.dart';
import 'package:moschee_app/sections/mosques/location_actions.dart';
import 'package:moschee_app/core/theme/theme.dart';
import 'package:moschee_app/shared/widgets/app_empty_state.dart';

void openQibla(BuildContext context) => Navigator.of(
  context,
  rootNavigator: true,
).push(MaterialPageRoute<void>(builder: (_) => const QiblaScreen()));

/// Qibla-Kompass. Die Richtung gilt für den Standort des Handys, wenn er
/// freigegeben ist, sonst für die Hauptmoschee (in deren Umkreis ist der
/// Unterschied verschwindend gering).
class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = DataRepository.instance;
    return Scaffold(
      appBar: AppBar(leading: const AppBackButton()),
      body: ListenableBuilder(
        listenable: Listenable.merge([data, LocationService.instance]),
        builder: (context, _) => _body(context, data.origin),
      ),
    );
  }

  Widget _body(BuildContext context, Origin? origin) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final place = origin == null
        ? null
        : origin.isDevice
        ? t.location_mine
        : DataRepository.instance.primaryMosque!.name;
    return origin == null
        ? AppEmptyState(
            icon: AppIcons.qibla,
            title: t.qibla_title,
            message: t.qibla_no_mosque,
          )
        : StreamBuilder<CompassEvent>(
            stream: FlutterCompass.events,
            builder: (context, snap) {
              final qibla = PrayerTimesCalculator.qiblaDirection(
                origin.lat,
                origin.lng,
              );
              final heading = snap.data?.heading;
              final hasSensor = heading != null;
              final diff = ((qibla - (heading ?? 0)) + 540) % 360 - 180;
              final aligned = hasSensor && diff.abs() < 5;
              final color = aligned
                  ? AppColors.success
                  : theme.colorScheme.primary;
              return ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                children: [
                  Text(
                    '${qibla.round()}°',
                    textAlign: TextAlign.center,
                    style: AppTypography.display.copyWith(color: color),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    t.qibla_title,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    origin.isDevice
                        ? t.qibla_based_on_location
                        : t.qibla_based_on(place!),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 28),
                  AspectRatio(
                    aspectRatio: 1,
                    child: CustomPaint(
                      painter: _CompassPainter(
                        heading: heading ?? 0,
                        qibla: qibla,
                        color: color,
                        dial: theme.colorScheme.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: Text(
                      !hasSensor
                          ? t.qibla_no_sensor
                          : aligned
                          ? t.qibla_aligned
                          : t.qibla_turn,
                      key: ValueKey('$hasSensor$aligned'),
                      textAlign: TextAlign.center,
                      style: aligned
                          ? theme.textTheme.titleMedium?.copyWith(
                              color: AppColors.success,
                            )
                          : theme.textTheme.bodyMedium,
                    ),
                  ),
                  if (hasSensor) ...[
                    const SizedBox(height: 8),
                    Text(
                      t.qibla_calibrate,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                  if (!origin.isDevice) ...[
                    const SizedBox(height: 16),
                    Center(
                      child: OutlinedButton.icon(
                        icon: const Icon(AppIcons.myLocation),
                        label: Text(t.location_use),
                        onPressed: () => enableLocation(context),
                      ),
                    ),
                  ],
                ],
              );
            },
          );
  }
}

/// Kompassrose (dreht sich mit dem Handy) und Pfeil Richtung Kaaba.
class _CompassPainter extends CustomPainter {
  _CompassPainter({
    required this.heading,
    required this.qibla,
    required this.color,
    required this.dial,
  });

  final double heading;
  final double qibla;
  final Color color;
  final Color dial;

  double _rad(double deg) => deg * math.pi / 180;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide / 2;

    canvas.drawCircle(c, r, Paint()..color = dial.withValues(alpha: 0.05));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = dial.withValues(alpha: 0.15),
    );

    // Skala: Norden oben, dreht sich gegen die Blickrichtung.
    canvas.save();
    canvas.translate(c.dx, c.dy);
    canvas.rotate(_rad(-heading));
    for (var deg = 0; deg < 360; deg += 10) {
      final major = deg % 90 == 0;
      final p = Paint()
        ..strokeWidth = major ? 3 : 1.5
        ..strokeCap = StrokeCap.round
        ..color = dial.withValues(alpha: major ? 0.55 : 0.22);
      final a = _rad(deg.toDouble());
      final dir = Offset(math.sin(a), -math.cos(a));
      canvas.drawLine(dir * (r - 6), dir * (r - (major ? 22 : 14)), p);
    }
    // Norden: rotes Dreieck.
    final north = Path()
      ..moveTo(0, -r + 26)
      ..lineTo(-8, -r + 42)
      ..lineTo(8, -r + 42)
      ..close();
    canvas.drawPath(north, Paint()..color = AppColors.error);

    // Pfeil zur Kaaba.
    canvas.rotate(_rad(qibla));
    final arrow = Paint()
      ..color = color
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(0, r * 0.35), Offset(0, -r * 0.55), arrow);
    final head = Path()
      ..moveTo(0, -r * 0.72)
      ..lineTo(-18, -r * 0.5)
      ..lineTo(18, -r * 0.5)
      ..close();
    canvas.drawPath(head, Paint()..color = color);
    // Kaaba-Würfel an der Spitze.
    final kaaba = Rect.fromCenter(
      center: Offset(0, -r * 0.82),
      width: 22,
      height: 22,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(kaaba, const Radius.circular(3)),
      Paint()..color = dial.withValues(alpha: 0.85),
    );
    canvas.drawRect(
      Rect.fromLTWH(kaaba.left, kaaba.top + 6, kaaba.width, 3),
      Paint()..color = AppColors.warning,
    );
    canvas.restore();

    canvas.drawCircle(c, 7, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_CompassPainter old) =>
      old.heading != heading || old.color != color || old.qibla != qibla;
}
