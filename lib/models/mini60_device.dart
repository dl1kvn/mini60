// lib/models/mini60_device.dart

import 'package:flutter_blue_classic/flutter_blue_classic.dart';

class Mini60Device {
  final BluetoothDevice device;
  final int rssi;

  Mini60Device({required this.device, required this.rssi});

  @override
  String toString() =>
      '${device.name ?? "Unbekannt"} (${device.address}) - $rssi dBm';
}
