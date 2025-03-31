// lib/widgets/connect_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bluetooth_controller.dart';
import '../models/mini60_device.dart';

class ConnectDialog extends StatelessWidget {
  final BluetoothController controller = Get.find<BluetoothController>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            SizedBox(height: 16),
            _buildContent(),
            SizedBox(height: 16),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(Icons.bluetooth_searching, size: 48, color: Colors.blue),
        SizedBox(height: 8),
        Text(
          'Mit Mini60 verbinden',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Obx(() {
      // Überprüfe Bluetooth-Status
      if (controller.isBluetoothOff()) {
        return Column(
          children: [
            Text('Bluetooth ist deaktiviert', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.turnOnBluetooth,
              child: Text('Bluetooth aktivieren'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ],
        );
      }

      // Zeige Scan-Status
      if (controller.isScanning.value) {
        return Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Suche nach Mini60-Geräten...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      }

      // Zeige gefundene Geräte oder "Keine Geräte gefunden"
      final devices = controller.devices;
      if (devices.isEmpty) {
        return Column(
          children: [
            Text(
              'Keine Mini60-Geräte gefunden',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'Stelle sicher, dass dein Mini60 eingeschaltet und in Reichweite ist',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        );
      }

      // Zeige Geräteliste
      return Container(
        height: 200,
        child: ListView.builder(
          itemCount: devices.length,
          itemBuilder: (context, index) {
            final device = devices[index];
            return _buildDeviceItem(device, context);
          },
        ),
      );
    });
  }

  Widget _buildDeviceItem(Mini60Device device, BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        leading: Icon(Icons.bluetooth, color: Colors.blue),
        title: Text(
          device.device.name ?? 'Unbekanntes Gerät',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Signal: ${device.rssi} dBm'),
        onTap: () async {
          // Verbindungsversuch anzeigen
          Get.dialog(
            Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Verbinde mit ${device.device.name ?? "Gerät"}...'),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );

          // Verbinden
          final success = await controller.connectToDevice(device);

          // Dialog schließen
          Get.back();

          if (success) {
            // Erfolgreich verbunden, schließe den Verbindungsdialog
            Get.back(result: true);
          } else {
            // Fehler anzeigen
            Get.snackbar(
              'Verbindungsfehler',
              'Konnte keine Verbindung zum Gerät herstellen.',
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          }
        },
      ),
    );
  }

  Widget _buildActions() {
    return Obx(() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('Abbrechen'),
          ),
          if (!controller.isBluetoothOff())
            ElevatedButton(
              onPressed:
                  controller.isScanning.value
                      ? controller.stopScan
                      : controller.startScan,
              child: Text(
                controller.isScanning.value ? 'Scan stoppen' : 'Scan starten',
              ),
            ),
        ],
      );
    });
  }
}
