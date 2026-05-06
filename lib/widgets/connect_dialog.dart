// lib/widgets/connect_dialog.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../controllers/bluetooth_controller.dart';
import '../models/mini60_device.dart';

class ConnectDialog extends StatefulWidget {
  @override
  _ConnectDialogState createState() => _ConnectDialogState();
}

class _ConnectDialogState extends State<ConnectDialog> {
  final BluetoothController controller = Get.find<BluetoothController>();
  bool _permissionsChecked = false;

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndStartScan();
  }

  Future<void> _checkPermissionsAndStartScan() async {
    // Prüfe und fordere Berechtigungen an
    final hasPermissions = await controller.requestBluetoothPermissions();
    setState(() {
      _permissionsChecked = true;
    });

    if (hasPermissions && !controller.isBluetoothOff()) {
      // Start scan automatically when permissions are granted
      controller.startScan();
    }
  }

  Future<void> _openAppSettings() async {
    await openAppSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (!_permissionsChecked) {
      // Show loading indicator during permission check
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
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Checking permissions...'),
            ],
          ),
        ),
      );
    }

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
          'Connect to Mini60',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Obx(() {
      // Check Bluetooth status
      if (controller.isBluetoothOff()) {
        return Column(
          children: [
            Text('Bluetooth is disabled', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.turnOnBluetooth,
              child: Text('Enable Bluetooth'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 40),
              ),
            ),
          ],
        );
      }

      // Show scan status
      if (controller.isScanning.value) {
        return Column(
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Searching for Mini60 devices...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        );
      }

      // Show found devices or "No devices found"
      final devices = controller.devices;
      if (devices.isEmpty) {
        return Column(
          children: [
            Text('No Mini60 devices found', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text(
              'Make sure your Mini60 is turned on and within range',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            SizedBox(height: 16),
            TextButton.icon(
              onPressed: _openAppSettings,
              icon: Icon(Icons.settings, size: 18),
              label: Text('Open App Permissions'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          ],
        );
      }

      // Show device list
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
          device.device.name ?? 'Unknown Device',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Signal: ${device.rssi} dBm'),
        onTap: () async {
          // Show connection attempt
          Get.dialog(
            Dialog(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Connecting to ${device.device.name ?? "device"}...'),
                  ],
                ),
              ),
            ),
            barrierDismissible: false,
          );

          // Connect
          final success = await controller.connectToDevice(device);

          // Close dialog
          Get.back();

          if (success) {
            // Successfully connected, close connection dialog
            Get.back(result: true);
          } else {
            // Show error
            Get.snackbar(
              'Connection Error',
              'Could not establish connection to device.',
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
      return Column(
        children: [
          // Link to app permissions
          TextButton.icon(
            onPressed: _openAppSettings,
            icon: Icon(Icons.settings, size: 16),
            label: Text('App Permissions', style: TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: Colors.grey[700],
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            ),
          ),
          SizedBox(height: 8),
          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Get.back(result: false),
                child: Text('Cancel'),
              ),
              if (!controller.isBluetoothOff())
                ElevatedButton(
                  onPressed:
                      controller.isScanning.value
                          ? controller.stopScan
                          : controller.startScan,
                  child: Text(controller.isScanning.value ? 'Stop' : 'Start'),
                ),
            ],
          ),
        ],
      );
    });
  }
}
