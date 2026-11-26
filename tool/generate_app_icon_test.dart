// Erzeugt das App-Icon (assets/icon/app_icon.png) und den Vordergrund für
// das adaptive Android-Icon (assets/icon/app_icon_foreground.png).
//
// Aufruf: flutter test tool/generate_app_icon_test.dart
// Danach: dart run flutter_launcher_icons
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _size = 1024.0;
const _top = Color(0xFF2BB3A3);
const _bottom = Color(0xFF167A70);

/// Moschee-Silhouette mit Kuppel, zwei Minaretten und Mondsichel,
/// gezeichnet in ein Quadrat der Kantenlänge [s] ab [o].
void _drawMosque(Canvas canvas, Offset o, double s, Color color) {
  final p = Paint()
    ..color = color
    ..isAntiAlias = true;
  double x(double f) => o.dx + f * s;
  double y(double f) => o.dy + f * s;

  // Sockel.
  canvas.drawRRect(
    RRect.fromLTRBR(
      x(0.22),
      y(0.62),
      x(0.78),
      y(0.86),
      Radius.circular(s * 0.02),
    ),
    p,
  );
  // Kuppel: Halbkreis mit leichter Zwiebelspitze.
  final dome = Path()
    ..moveTo(x(0.30), y(0.62))
    ..cubicTo(x(0.30), y(0.42), x(0.42), y(0.36), x(0.50), y(0.30))
    ..cubicTo(x(0.58), y(0.36), x(0.70), y(0.42), x(0.70), y(0.62))
    ..close();
  canvas.drawPath(dome, p);
  // Spitze mit Mondsichel.
  canvas.drawRect(Rect.fromLTRB(x(0.493), y(0.22), x(0.507), y(0.31)), p);
  final crescent = Path()
    ..addOval(
      Rect.fromCircle(center: Offset(x(0.50), y(0.175)), radius: s * 0.05),
    )
    ..fillType = PathFillType.evenOdd;
  final cut = Path()
    ..addOval(
      Rect.fromCircle(center: Offset(x(0.522), y(0.162)), radius: s * 0.043),
    );
  canvas.drawPath(Path.combine(PathOperation.difference, crescent, cut), p);
  // Minarette.
  for (final cx in [0.14, 0.86]) {
    canvas.drawRRect(
      RRect.fromLTRBR(
        x(cx - 0.035),
        y(0.34),
        x(cx + 0.035),
        y(0.86),
        Radius.circular(s * 0.01),
      ),
      p,
    );
    canvas.drawRect(
      Rect.fromLTRB(x(cx - 0.05), y(0.46), x(cx + 0.05), y(0.49)),
      p,
    );
    final roof = Path()
      ..moveTo(x(cx - 0.035), y(0.34))
      ..lineTo(x(cx), y(0.22))
      ..lineTo(x(cx + 0.035), y(0.34))
      ..close();
    canvas.drawPath(roof, p);
  }
  // Tür: ausgespart (BlendMode.clear in der Ebene des Aufrufers), damit
  // dort der Hintergrund durchscheint.
  final door = Path()
    ..moveTo(x(0.45), y(0.86))
    ..lineTo(x(0.45), y(0.74))
    ..arcToPoint(Offset(x(0.55), y(0.74)), radius: Radius.circular(s * 0.05))
    ..lineTo(x(0.55), y(0.86))
    ..close();
  canvas.drawPath(door, Paint()..blendMode = BlendMode.clear);
}

Future<void> _write(String path, void Function(Canvas) draw) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, _size, _size));
  draw(canvas);
  final image = await recorder.endRecording().toImage(
    _size.toInt(),
    _size.toInt(),
  );
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path).writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('App-Icon erzeugen', (tester) async {
    await tester.runAsync(() async {
      // Vollständiges Icon (iOS: ohne Transparenz).
      await _write('assets/icon/app_icon.png', (canvas) {
        const rect = Rect.fromLTWH(0, 0, _size, _size);
        canvas.drawRect(
          rect,
          Paint()
            ..shader = const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_top, _bottom],
            ).createShader(rect),
        );
        // Weicher Lichtkreis hinter der Moschee.
        canvas.drawCircle(
          const Offset(_size / 2, _size * 0.5),
          _size * 0.36,
          Paint()..color = Colors.white.withValues(alpha: 0.08),
        );
        canvas.saveLayer(rect, Paint());
        _drawMosque(
          canvas,
          const Offset(_size * 0.17, _size * 0.15),
          _size * 0.66,
          Colors.white,
        );
        canvas.restore();
      });
      // Vordergrund für Android (adaptive): transparent, im sicheren Bereich.
      await _write('assets/icon/app_icon_foreground.png', (canvas) {
        canvas.saveLayer(const Rect.fromLTWH(0, 0, _size, _size), Paint());
        _drawMosque(
          canvas,
          const Offset(_size * 0.25, _size * 0.23),
          _size * 0.5,
          Colors.white,
        );
        canvas.restore();
      });
    });
    expect(File('assets/icon/app_icon.png').existsSync(), isTrue);
  });
}
