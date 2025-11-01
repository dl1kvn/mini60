// lib/main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini6060/pages/antennatypes.dart';
import 'package:mini6060/pages/splash_screen.dart';
import 'controllers/bluetooth_controller.dart';
import 'widgets/connect_dialog.dart';
import 'pages/frequency_scan_page.dart';

void main() {
  // Ensure Flutter binding is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Start the app
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Mini60 App',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: SplashScreen(nextPage: HomePage()),
    );
  }
}

class HomePage extends StatelessWidget {
  // Initialize Bluetooth controller
  final BluetoothController bluetoothController = Get.put(
    BluetoothController(),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mini60 App')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show connection status
            Obx(() {
              return Column(
                children: [
                  Icon(
                    bluetoothController.isConnected.value
                        ? Icons.bluetooth_connected
                        : Icons.bluetooth_disabled,
                    size: 64,
                    color:
                        bluetoothController.isConnected.value
                            ? Colors.green
                            : Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    bluetoothController.isConnected.value
                        ? 'Connected to ${bluetoothController.deviceName.value}'
                        : 'Not connected',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            }),

            SizedBox(height: 32),

            // Connection button
            ElevatedButton.icon(
              icon: Icon(Icons.bluetooth_searching),
              label: Text('Connect to Mini60'),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              onPressed: () async {
                // Show connection dialog
                final result = await Get.dialog(
                  ConnectDialog(),
                  barrierDismissible: false,
                );

                if (result == true) {
                  // Connected
                  Get.snackbar(
                    'Connected',
                    'Successfully connected to ${bluetoothController.deviceName.value}',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.green,
                    colorText: Colors.white,
                  );
                }
              },
            ),

            SizedBox(height: 16),

            // Action buttons (only show when connected)
            Obx(() {
              if (!bluetoothController.isConnected.value) {
                return SizedBox.shrink();
              }

              return Column(
                children: [
                  TextButton.icon(
                    icon: Icon(Icons.bluetooth_disabled),
                    label: Text('Disconnect'),
                    onPressed: () async {
                      await bluetoothController.disconnectDevice();
                      Get.snackbar(
                        'Disconnected',
                        'Connection disconnected',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),

                  // Frequency Scan Button
                  SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: Icon(Icons.radio_button_checked),
                    label: Text('Start Frequency Scan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      Get.to(() => FrequencyScanPage());
                    },
                  ),
                ],
              );
            }),
            SizedBox(height: 16),
            ElevatedButton.icon(
              icon: Icon(Icons.list),
              label: Text("Antenna DB"),
              onPressed: () {
                Get.to(() => AntennaTypesPage());
              },
            ),
          ],
        ),
      ),
    );
  }
}
