// Erweitere das ScanResult-Modell um alle vier Werte
class ScanResult {
  final double frequency; // in kHz
  final double swr;
  final double r; // Widerstand
  final double x; // Reaktanz
  final double z; // Impedanz

  ScanResult({
    required this.frequency,
    required this.swr,
    this.r = 0.0,
    this.x = 0.0,
    this.z = 0.0,
  });

  @override
  String toString() =>
      'Frequenz: ${frequency.toStringAsFixed(0)} kHz, ' +
      'SWR: ${swr.toStringAsFixed(2)}, ' +
      'R: ${r.toStringAsFixed(2)}, ' +
      'X: ${x.toStringAsFixed(2)}, ' +
      'Z: ${z.toStringAsFixed(2)}';
}
