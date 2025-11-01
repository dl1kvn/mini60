import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/scan_result.dart';

class SWRChartWidget extends StatelessWidget {
  final List<ScanResult> scanResults;
  final double minFreq;
  final double maxFreq;
  final bool showResistance; // Neue Option

  const SWRChartWidget({
    Key? key,
    required this.scanResults,
    this.minFreq = 0.0,
    this.maxFreq = 0.0,
    this.showResistance = true, // Standardmäßig aktiviert
  }) : super(key: key);

  double _scaleSWRtoResistance(
    double scaled,
    double minR,
    double maxR,
    double minSWR,
    double maxSWR,
  ) {
    if (maxSWR == minSWR) return minR; // Sicherheitscheck
    return minR + (scaled - minSWR) * (maxR - minR) / (maxSWR - minSWR);
  }

  @override
  Widget build(BuildContext context) {
    if (scanResults.isEmpty) {
      return Center(
        child: Text(
          'Keine Daten für Chart verfügbar',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    // Berechne Wertebereiche für die Achsen
    double minSWR = 999.0;
    double maxSWR = 1.0;
    double minR = 999.0;
    double maxR = 0.0;
    double actualMinFreq = minFreq > 0 ? minFreq : scanResults.first.frequency;
    double actualMaxFreq = maxFreq > 0 ? maxFreq : scanResults.last.frequency;

    // Wenn keine Bereichsgrenzen angegeben sind, berechne sie aus den Daten
    if (minFreq <= 0 || maxFreq <= 0) {
      for (var result in scanResults) {
        if (result.frequency < actualMinFreq) actualMinFreq = result.frequency;
        if (result.frequency > actualMaxFreq) actualMaxFreq = result.frequency;
      }
    }

    // Finde min/max SWR und R für die Y-Achsen
    for (var result in scanResults) {
      if (result.swr < minSWR) minSWR = result.swr;
      if (result.swr > maxSWR) maxSWR = result.swr;

      if (result.r < minR) minR = result.r;
      if (result.r > maxR) maxR = result.r;
    }

    // Füge etwas Abstand zu den Grenzen hinzu
    actualMinFreq -= (actualMaxFreq - actualMinFreq) * 0.02;
    actualMaxFreq += (actualMaxFreq - actualMinFreq) * 0.02;

    // SWR sollte immer mindestens 1.0 sein und etwas Platz nach oben haben
    minSWR = minSWR < 1.0 ? 1.0 : minSWR * 0.95;
    maxSWR = maxSWR * 1.1;

    // Begrenze den maximalen SWR für bessere Lesbarkeit
    if (maxSWR > 10.0) maxSWR = 10.0;

    // Widerstandswerte anpassen
    minR = minR < 0.0 ? 0.0 : minR * 0.9;
    maxR = maxR * 1.1;

    // Stelle sicher, dass R-Bereich vernünftig ist
    if (maxR - minR < 10.0) {
      maxR = minR + 10.0;
    }

    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Minimal SWR: ${_findMinSWR().toStringAsFixed(2)} at ${_findMinSWRFrequency().toStringAsFixed(1)} kHz',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue,
              fontWeight: FontWeight.bold,
            ),
          ),

          // Legende für die Linien
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('SWR', Colors.red),
                SizedBox(width: 12),
                if (showResistance) _buildLegendItem('R (Ω)', Colors.blue),
              ],
            ),
          ),

          SizedBox(height: 2),

          Expanded(
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: true,
                  drawHorizontalLine: true,
                  horizontalInterval: 1.0, // SWR-Intervalle von 1.0
                ),
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: _calculateFrequencyInterval(
                        actualMinFreq,
                        actualMaxFreq,
                      ),
                      getTitlesWidget: (value, meta) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${value.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 8,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Linke Y-Achse (SWR)
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40,
                      interval: 1.0,
                      getTitlesWidget: (value, meta) {
                        if (value == 0) return SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text(
                            '${value.toStringAsFixed(1)}',
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  // Rechte Y-Achse (R)
                  // Rechte Y-Achse (zeigt aktuell echte R-Werte, soll aber skalierte anzeigen)
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: showResistance,
                      reservedSize: 40,
                      interval: 1.0, // Gleicher Abstand wie bei SWR
                      getTitlesWidget: (value, meta) {
                        // Rechne den skalierten Wert zurück zu einem echten R-Wert:
                        final rValue = _scaleSWRtoResistance(
                          value,
                          minR,
                          maxR,
                          minSWR,
                          maxSWR,
                        );
                        return Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Text(
                            '${rValue.toStringAsFixed(0)}',
                            style: TextStyle(
                              color: Colors.blue,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),
                borderData: FlBorderData(
                  show: true,
                  border: Border.all(color: Colors.black, width: 1),
                ),
                minX: actualMinFreq,
                maxX: actualMaxFreq,
                minY: minSWR,
                maxY: maxSWR,
                // Zweite Y-Achse für Widerstandswerte
                extraLinesData:
                    showResistance
                        ? ExtraLinesData(
                          horizontalLines: [
                            HorizontalLine(
                              y: 50, // 50 Ohm Referenzlinie
                              color: Colors.blue.withOpacity(0.5),
                              strokeWidth: 1,
                              dashArray: [5, 5],
                              label: HorizontalLineLabel(
                                show: true,
                                alignment: Alignment.topRight,
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 10,
                                ),
                                labelResolver: (line) => '50Ω',
                              ),
                            ),
                          ],
                        )
                        : null,
                lineBarsData: [
                  // SWR-Linie (primäre Y-Achse)
                  LineChartBarData(
                    spots:
                        scanResults.map((result) {
                          return FlSpot(result.frequency, result.swr);
                        }).toList(),
                    isCurved: true,
                    color: Colors.red,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: FlDotData(
                      show:
                          scanResults.length <
                          30, // Zeige Punkte nur bei wenigen Datenpunkten
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.red.withOpacity(0.2),
                    ),
                  ),

                  // Widerstandslinie (sekundäre Y-Achse) - nur wenn aktiviert
                  if (showResistance)
                    LineChartBarData(
                      spots:
                          scanResults.map((result) {
                            // Skaliere R-Werte auf die SWR-Skala für die Anzeige
                            // Dies ist notwendig, weil die fl_chart-Bibliothek nicht direkt zwei
                            // verschiedene Y-Achsen unterstützt
                            final scaledR = _scaleResistanceToSWR(
                              result.r,
                              minR,
                              maxR,
                              minSWR,
                              maxSWR,
                            );
                            return FlSpot(result.frequency, scaledR);
                          }).toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: scanResults.length < 30),
                      dashArray: [5, 5], // Gestrichelte Linie für R
                    ),
                ],
                lineTouchData: LineTouchData(
                  enabled: true,
                  touchTooltipData: LineTouchTooltipData(
                    // Angepasstes Tooltip
                    getTooltipItems: (touchedSpots) {
                      return touchedSpots.map((spot) {
                        // Finde das entsprechende ScanResult
                        final index = touchedSpots.indexOf(spot);
                        final freq = spot.x;

                        // Finde das nächstgelegene Ergebnis
                        ScanResult? nearestResult;
                        double minDistance = double.infinity;
                        for (var result in scanResults) {
                          final distance = (result.frequency - freq).abs();
                          if (distance < minDistance) {
                            minDistance = distance;
                            nearestResult = result;
                          }
                        }

                        if (nearestResult == null) {
                          return LineTooltipItem(
                            '${spot.x.toStringAsFixed(1)} kHz\nSWR: ${spot.y.toStringAsFixed(2)}',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }

                        // Unterschiedliche Anzeige je nach Linie
                        if (spot.barIndex == 0) {
                          // SWR-Linie
                          return LineTooltipItem(
                            '${spot.x.toStringAsFixed(1)} kHz\nSWR: ${nearestResult.swr.toStringAsFixed(2)}\nR: ${nearestResult.r.toStringAsFixed(1)} Ω',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        } else {
                          // R-Linie
                          // Hier nehmen wir den tatsächlichen R-Wert, nicht den skalierten
                          return LineTooltipItem(
                            '${spot.x.toStringAsFixed(1)} kHz\nR: ${nearestResult.r.toStringAsFixed(1)} Ω\nSWR: ${nearestResult.swr.toStringAsFixed(2)}',
                            TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      }).toList();
                    },
                  ),
                  touchCallback: (event, response) {},
                  handleBuiltInTouches: true,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hilfsmethode zum Skalieren von R-Werten auf die SWR-Skala
  double _scaleResistanceToSWR(
    double r,
    double minR,
    double maxR,
    double minSWR,
    double maxSWR,
  ) {
    // Lineare Skalierung von R-Bereich auf SWR-Bereich
    if (maxR == minR) return minSWR; // Vermeidet Division durch Null

    return minSWR + (r - minR) * (maxSWR - minSWR) / (maxR - minR);
  }

  // Hilfsmethode für Legendenelement
  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(width: 16, height: 2, color: color),
        SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  // Hilfreiche Hilfsfunktionen
  double _findMinSWR() {
    if (scanResults.isEmpty) return 1.0;
    double minSWR = scanResults.first.swr;
    for (var result in scanResults) {
      if (result.swr < minSWR) minSWR = result.swr;
    }
    return minSWR;
  }

  double _findMinSWRFrequency() {
    if (scanResults.isEmpty) return 0.0;
    double minSWR = scanResults.first.swr;
    double minFreq = scanResults.first.frequency;
    for (var result in scanResults) {
      if (result.swr < minSWR) {
        minSWR = result.swr;
        minFreq = result.frequency;
      }
    }
    return minFreq;
  }

  double _calculateFrequencyInterval(double min, double max) {
    final range = max - min;
    if (range <= 100) return 10.0;
    if (range <= 500) return 50.0;
    if (range <= 1000) return 100.0;
    return 200.0;
  }

  double _calculateResistanceInterval(double min, double max) {
    final range = max - min;
    if (range <= 50) return 10.0;
    if (range <= 100) return 20.0;
    if (range <= 500) return 50.0;
    return 100.0;
  }
}
