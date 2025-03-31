// lib/widgets/smith_chart_widget.dart

import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math.dart' as vector;
import '../models/scan_result.dart';

class SmithChartWidget extends StatelessWidget {
  final List<ScanResult> scanResults;
  final double size;
  final bool showLabels;
  final bool showFrequencyMarkers;

  const SmithChartWidget({
    Key? key,
    required this.scanResults,
    this.size = 300,
    this.showLabels = true,
    this.showFrequencyMarkers = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: CustomPaint(
        size: Size(size, size),
        painter: SmithChartPainter(
          scanResults: scanResults,
          showLabels: showLabels,
          showFrequencyMarkers: showFrequencyMarkers,
        ),
      ),
    );
  }
}

class SmithChartPainter extends CustomPainter {
  final List<ScanResult> scanResults;
  final bool showLabels;
  final bool showFrequencyMarkers;

  // Referenzimpedanz (normalerweise 50 Ohm)
  final double z0 = 50.0;

  SmithChartPainter({
    required this.scanResults,
    this.showLabels = true,
    this.showFrequencyMarkers = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2 - 10;

    // Styles definieren
    final gridPaint =
        Paint()
          ..color = Colors.grey.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0;

    final borderPaint =
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;

    final dataPaint =
        Paint()
          ..color = Colors.blue
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0;

    final markPaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;

    final labelStyle = TextStyle(color: Colors.black87, fontSize: 10);

    // Äußerer Kreis zeichnen
    canvas.drawCircle(Offset(centerX, centerY), radius, borderPaint);

    // Horizontale Linie zeichnen
    canvas.drawLine(
      Offset(centerX - radius, centerY),
      Offset(centerX + radius, centerY),
      borderPaint,
    );

    // Widerstandskreise zeichnen
    _drawResistanceCircles(canvas, centerX, centerY, radius, gridPaint);

    // Reaktanzkreise zeichnen
    _drawReactanceArcs(canvas, centerX, centerY, radius, gridPaint);

    // Beschriftungen hinzufügen
    if (showLabels) {
      _drawLabels(canvas, centerX, centerY, radius, labelStyle);
    }

    // Datenpunkte zeichnen
    if (scanResults.isNotEmpty) {
      _drawDataPoints(canvas, centerX, centerY, radius, dataPaint, markPaint);
    }
  }

  void _drawResistanceCircles(
    Canvas canvas,
    double centerX,
    double centerY,
    double radius,
    Paint paint,
  ) {
    // Kreise für konstanten Widerstand (normalisiert zu z0)
    final resistanceValues = [0.2, 0.5, 1.0, 2.0, 5.0];

    for (double r in resistanceValues) {
      // Für r = ∞ ist der Kreis der äußere Rand
      if (r == double.infinity) continue;

      // Kreiszentrum und Radius berechnen
      double circleRadius = radius / (1 + r);
      double circleCenterX = centerX + radius * r / (1 + r);

      canvas.drawCircle(Offset(circleCenterX, centerY), circleRadius, paint);
    }
  }

  void _drawReactanceArcs(
    Canvas canvas,
    double centerX,
    double centerY,
    double radius,
    Paint paint,
  ) {
    // Kreise für konstante Reaktanz (normalisiert zu z0)
    final reactanceValues = [
      -5.0,
      -2.0,
      -1.0,
      -0.5,
      -0.2,
      0.2,
      0.5,
      1.0,
      2.0,
      5.0,
    ];

    for (double x in reactanceValues) {
      // Kreiszentrum und Radius berechnen
      double circleRadius = radius / x.abs();

      // Positive Reaktanz (obere Hälfte)
      // Negative Reaktanz (untere Hälfte)
      double circleCenterY = centerY + (x > 0 ? circleRadius : -circleRadius);

      // Zeichne nur den relevanten Bogen des Kreises
      Rect circleRect = Rect.fromCircle(
        center: Offset(centerX, circleCenterY),
        radius: circleRadius,
      );

      // Start- und Endwinkel berechnen
      double startAngle, sweepAngle;

      if (x > 0) {
        // Obere Hälfte
        startAngle = math.pi;
        sweepAngle = -math.pi;
      } else {
        // Untere Hälfte
        startAngle = 0;
        sweepAngle = math.pi;
      }

      canvas.drawArc(circleRect, startAngle, sweepAngle, false, paint);
    }
  }

  void _drawLabels(
    Canvas canvas,
    double centerX,
    double centerY,
    double radius,
    TextStyle style,
  ) {
    // Beschriftungen für Widerstandskreise
    final resistanceLabels = {
      0.0: '0Ω',
      0.2: '0.2',
      0.5: '0.5',
      1.0: '1.0',
      2.0: '2.0',
      5.0: '5.0',
      double.infinity: '∞',
    };

    for (var entry in resistanceLabels.entries) {
      double r = entry.key;
      String label = entry.value;

      if (r == double.infinity) {
        // ∞ Beschriftung ganz rechts
        _drawText(canvas, label, centerX + radius + 5, centerY, style);
        continue;
      }

      // Position auf dem Widerstandskreis berechnen
      double x = centerX + radius * r / (1 + r);
      _drawText(canvas, label, x, centerY + 15, style);
    }

    // Beschriftungen für Reaktanzkreise
    final reactanceLabels = {
      -5.0: '-j5',
      -2.0: '-j2',
      -1.0: '-j1',
      -0.5: '-j0.5',
      0.5: 'j0.5',
      1.0: 'j1',
      2.0: 'j2',
      5.0: 'j5',
    };

    for (var entry in reactanceLabels.entries) {
      double x = entry.key;
      String label = entry.value;

      // Position am Rand des Smith-Diagramms berechnen
      double angle =
          x > 0
              ? (-math.pi / 4 - math.atan(1 / x.abs()))
              : (math.pi / 4 + math.atan(1 / x.abs()));

      double textX = centerX + radius * math.cos(angle) * 0.85;
      double textY = centerY + radius * math.sin(angle) * 0.85;

      _drawText(canvas, label, textX, textY, style);
    }
  }

  void _drawDataPoints(
    Canvas canvas,
    double centerX,
    double centerY,
    double radius,
    Paint linePaint,
    Paint pointPaint,
  ) {
    // Pfad für die Datenlinie erstellen
    final path = Path();
    bool isFirst = true;

    // Normalisierte Punkte berechnen und zeichnen
    for (int i = 0; i < scanResults.length; i++) {
      ScanResult result = scanResults[i];

      // Normalisieren der Impedanz mit Z0
      double normalizedR = result.r / z0;
      double normalizedX = result.x / z0;

      // Konvertieren in Smith-Chart-Koordinaten
      Offset point = _impedanceToSmithCoordinates(
        normalizedR,
        normalizedX,
        centerX,
        centerY,
        radius,
      );

      // Ersten Punkt setzen oder Linie zum nächsten Punkt ziehen
      if (isFirst) {
        path.moveTo(point.dx, point.dy);
        isFirst = false;
      } else {
        path.lineTo(point.dx, point.dy);
      }

      // Datenpunkte zeichnen
      canvas.drawCircle(point, 3, pointPaint);

      // Frequenzmarker anzeigen, wenn aktiviert
      if (showFrequencyMarkers && i % (scanResults.length ~/ 5) == 0) {
        final String freqLabel = '${result.frequency.toStringAsFixed(0)}kHz';
        _drawText(
          canvas,
          freqLabel,
          point.dx,
          point.dy - 10,
          TextStyle(color: Colors.black, fontSize: 8),
        );
      }
    }

    // Datenlinie zeichnen
    canvas.drawPath(path, linePaint);
  }

  // Hilfsfunktion zur Konvertierung von Impedanz zu Smith-Chart-Koordinaten
  Offset _impedanceToSmithCoordinates(
    double normalizedR,
    double normalizedX,
    double centerX,
    double centerY,
    double radius,
  ) {
    // Reflexionskoeffizient berechnen
    final complex = _impedanceToReflectionCoefficient(normalizedR, normalizedX);

    // Konvertieren in kartesische Koordinaten auf dem Smith-Diagramm
    double x = centerX + radius * complex.x;
    double y = centerY - radius * complex.y; // Y-Achse ist in Flutter umgekehrt

    return Offset(x, y);
  }

  // Berechnung des Reflexionskoeffizienten aus normalisierter Impedanz
  vector.Vector2 _impedanceToReflectionCoefficient(
    double normalizedR,
    double normalizedX,
  ) {
    // Γ = (Z - 1) / (Z + 1) mit Z = R + jX (normalisiert)
    double numeratorReal = normalizedR - 1;
    double numeratorImag = normalizedX;
    double denominatorReal = normalizedR + 1;
    double denominatorImag = normalizedX;

    // Komplex-Division
    double denomSquare =
        denominatorReal * denominatorReal + denominatorImag * denominatorImag;
    double resultReal =
        (numeratorReal * denominatorReal + numeratorImag * denominatorImag) /
        denomSquare;
    double resultImag =
        (numeratorImag * denominatorReal - numeratorReal * denominatorImag) /
        denomSquare;

    return vector.Vector2(resultReal, resultImag);
  }

  void _drawText(
    Canvas canvas,
    String text,
    double x,
    double y,
    TextStyle style,
  ) {
    final textSpan = TextSpan(text: text, style: style);
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(x - textPainter.width / 2, y - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
