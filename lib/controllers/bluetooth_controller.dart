// lib/controllers/bluetooth_controller.dart

import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:get/get.dart';
import 'package:flutter_blue_classic/flutter_blue_classic.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import '../models/mini60_device.dart';
import '../models/scan_result.dart';

class BluetoothController extends GetxController {
  // Bluetooth-Instanz
  final FlutterBlueClassic flutterBlue = FlutterBlueClassic();

  // Reaktive Zustandsvariablen für Bluetooth-Verbindung
  Rx<BluetoothAdapterState> adapterState = BluetoothAdapterState.unknown.obs;
  RxBool isConnected = false.obs;
  RxString deviceName = "Nicht verbunden".obs;
  RxList<Mini60Device> devices = <Mini60Device>[].obs;

  // Zustandsvariablen für Frequency-Scan
  RxList<ScanResult> scanResults = <ScanResult>[].obs;
  RxBool isScanning = false.obs;
  RxDouble progress = 0.0.obs;
  RxString scanStatus = "".obs;

  bool _scanStarted = false;
  int _expectedDatapoints = 0;
  int _receivedDatapoints = 0;

  // Füge diese Variable zu deinen Klassenvariablen hinzu
  String _receiveBuffer = "";

  // Verbindung und Streams
  BluetoothConnection? connection;
  StreamSubscription? _scanSubscription;
  StreamSubscription? _adapterStateSubscription;
  StreamSubscription? _scanningStateSubscription;

  // Timer für Scan-Steuerung
  Timer? _scanTimer;
  double _currentFrequency = 0;
  double _endFrequency = 0;
  double _stepSize = 0.0; // 10 kHz Schritte

  @override
  void onInit() {
    super.onInit();
    _initBluetooth();
  }

  //---------------------------------------------------
  // Berechtigungsverwaltung
  //---------------------------------------------------

  // Prüfe und fordere Bluetooth-Berechtigungen an
  Future<bool> requestBluetoothPermissions() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        // debugPrint'Android SDK Version: $sdkInt');

        if (sdkInt >= 31) {
          // Android 12+ (API 31+)
          // debugPrint'Fordere Android 12+ Berechtigungen an (BLUETOOTH_SCAN, BLUETOOTH_CONNECT)');

          final statuses =
              await [
                Permission.bluetoothScan,
                Permission.bluetoothConnect,
              ].request();

          final allGranted = statuses.values.every(
            (status) => status.isGranted,
          );

          if (!allGranted) {
            // debugPrint'Nicht alle Berechtigungen erteilt: $statuses');
          }

          return allGranted;
        } else if (sdkInt >= 23) {
          // Android 6-11 (API 23-30)
          // debugPrint'Fordere Android 6-11 Berechtigungen an (BLUETOOTH, LOCATION)');

          final statuses =
              await [Permission.bluetooth, Permission.location].request();

          final allGranted = statuses.values.every(
            (status) => status.isGranted,
          );

          if (!allGranted) {
            // debugPrint'Nicht alle Berechtigungen erteilt: $statuses');
          }

          // Prüfe zusätzlich, ob Standortdienste aktiviert sind
          if (allGranted && sdkInt >= 23 && sdkInt <= 30) {
            final locationServiceEnabled =
                await Permission.location.serviceStatus.isEnabled;
            if (!locationServiceEnabled) {
              // debugPrint'Standortdienste sind nicht aktiviert');
              Get.snackbar(
                'Standortdienste erforderlich',
                'Bitte aktivieren Sie die Standortdienste für Bluetooth-Scanning',
                snackPosition: SnackPosition.BOTTOM,
                duration: Duration(seconds: 5),
              );
              return false;
            }
          }

          return allGranted;
        } else {
          // Android 5 (API 21-22) - keine Runtime-Berechtigungen erforderlich
          // debugPrint'Android < 6.0, keine Runtime-Berechtigungen erforderlich');
          return true;
        }
      } catch (e) {
        // debugPrint'Fehler beim Anfordern von Berechtigungen: $e');
        return false;
      }
    }
    // Für andere Plattformen (iOS) geben wir true zurück
    return true;
  }

  // Prüfe, ob alle erforderlichen Berechtigungen erteilt sind
  Future<bool> hasBluetoothPermissions() async {
    if (Platform.isAndroid) {
      try {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        final sdkInt = androidInfo.version.sdkInt;

        if (sdkInt >= 31) {
          // Android 12+
          final scanStatus = await Permission.bluetoothScan.status;
          final connectStatus = await Permission.bluetoothConnect.status;
          return scanStatus.isGranted && connectStatus.isGranted;
        } else if (sdkInt >= 23) {
          // Android 6-11
          final bluetoothStatus = await Permission.bluetooth.status;
          final locationStatus = await Permission.location.status;
          return bluetoothStatus.isGranted && locationStatus.isGranted;
        } else {
          // Android 5
          return true;
        }
      } catch (e) {
        // debugPrint'Fehler beim Prüfen von Berechtigungen: $e');
        return false;
      }
    }
    return true;
  }

  //---------------------------------------------------
  // Bluetooth-Verbindung
  //---------------------------------------------------

  // Bluetooth initialisieren
  Future<void> _initBluetooth() async {
    try {
      // Adapter-Status abrufen
      adapterState.value = await flutterBlue.adapterStateNow;

      // Adapter-Status überwachen
      _adapterStateSubscription = flutterBlue.adapterState.listen((state) {
        // debugPrint'Bluetooth-Status geändert: $state');
        adapterState.value = state;
      });

      // Scan-Status überwachen
      _scanningStateSubscription = flutterBlue.isScanning.listen((scanning) {
        isScanning.value = scanning;
      });
    } catch (e) {
      // debugPrint'Fehler bei Bluetooth-Initialisierung: $e');
    }
  }

  // Starte Bluetooth-Scan nach Geräten
  void startScan() async {
    try {
      if (isScanning.value) return;

      // Prüfe und fordere Berechtigungen an
      final hasPermissions = await requestBluetoothPermissions();
      if (!hasPermissions) {
        Get.snackbar(
          'Fehlende Berechtigungen',
          'Bluetooth-Berechtigungen werden benötigt, um nach Geräten zu suchen',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.theme.colorScheme.error,
          colorText: Get.theme.colorScheme.onError,
          duration: Duration(seconds: 5),
        );
        return;
      }

      // debugPrint'Starte Bluetooth-Scan');
      devices.clear();

      _scanSubscription = flutterBlue.scanResults.listen(
        (device) {
          // debugPrint'Gerät gefunden: ${device.name} (${device.address})');

          // Filter für Mini60-Geräte
          final name = device.name ?? "";
          if (name.toUpperCase().contains('MINI')) {
            final mini60Device = Mini60Device(
              device: device,
              rssi: device.rssi ?? 0,
            );

            // Prüfe, ob das Gerät bereits in der Liste ist
            final existingIndex = devices.indexWhere(
              (d) => d.device.address == device.address,
            );

            // Aktualisiere oder füge hinzu
            if (existingIndex >= 0) {
              final updatedList = List<Mini60Device>.from(devices);
              updatedList[existingIndex] = mini60Device;
              devices.value = updatedList;
            } else {
              final updatedList = List<Mini60Device>.from(devices);
              updatedList.add(mini60Device);
              devices.value = updatedList;
            }
          }
        },
        onError: (error) {
          // debugPrint'Scan-Fehler: $error');
        },
      );

      // Scan starten
      flutterBlue.startScan();

      // Scan nach 30 Sekunden automatisch beenden
      Future.delayed(Duration(seconds: 30), () {
        if (isScanning.value) {
          stopScan();
        }
      });
    } catch (e) {
      // debugPrint'Fehler beim Starten des Scans: $e');
    }
  }

  // Beende Bluetooth-Scan
  void stopScan() {
    try {
      if (!isScanning.value) return;

      // debugPrint'Stoppe Bluetooth-Scan');
      flutterBlue.stopScan();
      _scanSubscription?.cancel();
      _scanSubscription = null;
    } catch (e) {
      // debugPrint'Fehler beim Stoppen des Scans: $e');
    }
  }

  // Verbinde mit Gerät
  Future<bool> connectToDevice(Mini60Device device) async {
    try {
      // debugPrint'Verbinde mit Gerät: ${device.device.name ?? "Unbekannt"}');

      // Bestehende Verbindung trennen
      await disconnectDevice();

      // Neue Verbindung herstellen
      connection = await flutterBlue.connect(device.device.address);

      if (connection != null && connection!.isConnected) {
        isConnected.value = true;
        deviceName.value = device.device.name ?? "Unbekanntes Gerät";

        _receiveBuffer = "";
        _setupResponseListener();

        // debugPrint('Verbindung hergestellt! Verbindung hergestellt! Verbindung  Verbindung hergestellt! Verbindung hergestellt!Verbindung hergestellt!Verbindung hergestellt! Verbindung hergestellt!llt! Verbindung hergestellt! Verbindung hergestellt! Verbindung hergestellt!',);
        return true;
      } else {
        // debugPrint'Verbindung konnte nicht hergestellt werden');
        return false;
      }
    } catch (e) {
      // debugPrint'Fehler beim Verbinden: $e');
      return false;
    }
  }

  // Trenne Verbindung
  Future<void> disconnectDevice() async {
    try {
      if (connection != null) {
        // debugPrint'Trenne Verbindung');
        connection?.dispose();
        connection = null;
        isConnected.value = false;
        deviceName.value = "Nicht verbunden";
      }
    } catch (e) {
      // debugPrint'Fehler beim Trennen der Verbindung: $e');
    }
  }

  // Bluetooth einschalten
  void turnOnBluetooth() {
    try {
      flutterBlue.turnOn();
    } catch (e) {
      // debugPrint'Fehler beim Einschalten von Bluetooth: $e');
    }
  }

  // Prüfe, ob Bluetooth ausgeschaltet ist
  bool isBluetoothOff() {
    final state = adapterState.value;
    return state == BluetoothAdapterState.unknown ||
        state.toString().toLowerCase().contains('off');
  }

  //---------------------------------------------------
  // Frequenz-Scan
  //---------------------------------------------------

  // Starte einen Frequenz-Scan
  // Wenn du einen kompletten Scan von Start bis Ende auf einmal durchführen möchtest
  // Starte einen Frequenz-Scan
  Future<bool> startFrequencyScan(double startFreq, double endFreq) async {
    try {
      if (!isConnected.value || connection == null) {
        // debugPrint'Nicht verbunden, kann keinen Scan starten');
        return false;
      }

      if (isScanning.value) {
        await cancelScan();
        await Future.delayed(Duration(milliseconds: 500));
      }

      _receiveBuffer = "";

      // debugPrint'Starte Frequenz-Scan von $startFreq kHz bis $endFreq kHz');
      isScanning.value = true;
      progress.value = 0.0;
      scanResults.clear();
      scanStatus.value = "Scan gestartet...";

      _scanStarted = false;
      _currentFrequency = startFreq;
      _endFrequency = endFreq;

      _expectedDatapoints = 50;
      _stepSize = (endFreq - startFreq) / (_expectedDatapoints - 1);

      final int start = (startFreq * 1000).toInt();
      final int end = (endFreq * 1000).toInt();
      final int step = (_stepSize * 1000).round(); // in Hz

      _expectedDatapoints = ((end - start) / step).floor() + 1;

      // STEP???
      final command = "scan $start $end $step\r\n";
      // debugPrint'Sende Scan-Befehl: "$command"');

      connection!.output.add(Uint8List.fromList(command.codeUnits));
      await connection!.output.allSent;

      await Future.delayed(Duration(milliseconds: 1600));

      return true;
    } catch (e) {
      // debugPrint'Fehler beim Starten des Frequenz-Scans: $e');
      isScanning.value = false;
      scanStatus.value = "Fehler: $e";
      return false;
    }
  }

  Future<void> clearInputBuffer() async {
    try {
      if (connection != null && connection!.isConnected) {
        // debugPrint'Leere den Eingangspuffer...');

        // Sende ein spezielles Kommando, das keine Antwort erfordert
        connection!.output.add(Uint8List.fromList("\r\n".codeUnits));
        await connection!.output.allSent;

        // Kurze Pause
        await Future.delayed(Duration(milliseconds: 100));

        // Lege einen Flag fest, dass die nächsten Eingaben ignoriert werden sollen
        _ignoreNextResponses = true;

        // Nach einer gewissen Zeit den Flag zurücksetzen
        Future.delayed(Duration(milliseconds: 500), () {
          _ignoreNextResponses = false;
        });
      }
    } catch (e) {
      // debugPrint'Fehler beim Leeren des Eingangspuffers: $e');
    }
  }

  // Scan der nächsten Frequenz
  // Ändere dies in der _scanNextFrequency-Methode
  void _scanNextFrequency() async {
    try {
      // Überprüfe, ob der Scan abgeschlossen ist
      if (_currentFrequency > _endFrequency) {
        _scanTimer?.cancel();
        _scanTimer = null;
        isScanning.value = false;
        scanStatus.value = "Scan finished";
        progress.value = 1.0;
        return;
      }

      // Aktualisiere Status
      scanStatus.value =
          "Scanne ${_currentFrequency.toStringAsFixed(0)} kHz...";

      // Aktualisiere Fortschritt
      final totalRange = _endFrequency - (_currentFrequency - _stepSize);
      final currentProgress =
          (_currentFrequency - (_currentFrequency - _stepSize)) / totalRange;
      progress.value = currentProgress.clamp(0.0, 1.0);

      // Mini60 Scan-Befehl formatieren mit korrektem Format:
      // "scan [start] [end] [step]"
      final int start = _currentFrequency.toInt();
      final int end =
          _currentFrequency
              .toInt(); // Einzelfrequenz = gleicher Start- und Endwert
      final int step = 10;

      // Korrektes Befehlsformat laut Dokumentation
      final command = "scan $start $end $step\n";

      // debugPrint('Sende Scan-Befehl als Hex: ${command.codeUnits.map((b) => b.toRadixString(16).padLeft(2, '0')).join(' ')}',);
      // debugPrint('Sende Scan-Befehl: "$command"');

      // Befehl senden
      connection!.output.add(Uint8List.fromList(command.codeUnits));
      await connection!.output.allSent;

      // Im realen Betrieb würden wir jetzt auf die Antwort warten
      // Hier simulieren wir eine Antwort mit zufälligen Daten für Testzwecke
      // _simulateScanResponse(_currentFrequency);
      await Future.delayed(Duration(milliseconds: 1400));

      // Zur nächsten Frequenz wechseln
      _currentFrequency += _stepSize;
    } catch (e) {
      // debugPrint'Fehler beim Scannen der Frequenz $_currentFrequency: $e');
      scanStatus.value = "Fehler: $e";
    }
  }

  void debugRawData(Uint8List data) {
    final String asText = String.fromCharCodes(
      data,
    ).trim().replaceAll('\n', '\\n').replaceAll('\r', '\\r');
    final String asHex = data
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(' ');

    print('=== DEBUG EMPFANGENE DATEN ===');
    print('Länge: ${data.length} Bytes');
    print('Als Text: "$asText"');
    print('Als Hex: $asHex');
    print('============================');
  }

  // Diese Methode simuliert eine Antwort vom Mini60
  // Im realen Betrieb würde diese durch die tatsächliche Antwort des Geräts ersetzt
  void _simulateScanResponse(double frequency) {
    // Erzeuge einen zufälligen SWR-Wert für Testzwecke
    final random = Random();
    // SWR zwischen 1.0 und 5.0, wobei Werte um 1.5 wahrscheinlicher sind
    double swr = 1.0 + (random.nextDouble() * 4.0);

    // Simuliere einen guten SWR um die 7100 kHz
    if (frequency > 7050 && frequency < 7150) {
      swr = 1.0 + (random.nextDouble() * 0.5); // SWR zwischen 1.0 und 1.5
    }

    final result = ScanResult(frequency: frequency, swr: swr);

    // Ergebnis zur Liste hinzufügen
    final updatedResults = List<ScanResult>.from(scanResults);
    updatedResults.add(result);
    // Sortiere nach Frequenz
    updatedResults.sort((a, b) => a.frequency.compareTo(b.frequency));

    scanResults.value = updatedResults;

    // debugPrint'Scan-Ergebnis hinzugefügt: $result');
  }

  // Im realen Betrieb würden wir diese Methode verwenden
  void _processScanResponse(Uint8List data) {
    try {
      // Konvertiere die Bytes in einen String
      final response = String.fromCharCodes(data);

      // Zum Debuggen
      // debugPrint'Rohes Datenpaket: "$response"');

      // Füge die Antwort zum Puffer hinzu
      _receiveBuffer += response;

      // Suche nach kompletten Zeilen im Puffer
      _processBufferForCompleteLines();
    } catch (e) {
      // debugPrint'Fehler beim Konvertieren der Antwortdaten: $e');
    }
  }

  void _processBufferForCompleteLines() {
    // Verarbeite nur, wenn der Puffer nicht leer ist
    if (_receiveBuffer.isEmpty) return;

    // Prüfe auf spezielle Nachrichten
    if (_receiveBuffer.startsWith("Start")) {
      _scanStarted = true;
      _receivedDatapoints = 0;
      scanStatus.value = "Scan läuft...";
      _receiveBuffer = _receiveBuffer.substring("Start".length).trim();

      // debugPrint('Scan gestartet erkannt, restlicher Puffer: "$_receiveBuffer"',);
      // Verarbeite den Rest des Puffers rekursiv
      _processBufferForCompleteLines();
      return;
    }

    if (_receiveBuffer.startsWith("End")) {
      _scanStarted = false;
      progress.value = 1.0;
      scanStatus.value = "Scan finished";
      isScanning.value = false;
      _receiveBuffer = _receiveBuffer.substring("End".length).trim();

      // debugPrint('Scan beendet erkannt, restlicher Puffer: "$_receiveBuffer"');
      // Verarbeite den Rest des Puffers rekursiv
      _processBufferForCompleteLines();
      return;
    }

    // Suche nach einer kompletten Datenzeile (4 kommagetrennte Werte)
    // Ein komplettes Datenpaket sollte das Format "swr,r,x,z" haben

    // Suche nach Kommas im Puffer
    final commaCount = _receiveBuffer.split(',').length - 1;

    // Suche nach Zeilenumbrüchen
    final hasNewline =
        _receiveBuffer.contains('\n') || _receiveBuffer.contains('\r');

    // Wenn wir 3 Kommas haben (also 4 Werte) oder einen Zeilenumbruch, versuche zu parsen
    if (commaCount >= 3 || hasNewline) {
      // Suche nach dem Ende der Datenzeile
      int endIndex = _receiveBuffer.indexOf('\n');
      if (endIndex == -1) endIndex = _receiveBuffer.indexOf('\r');

      // Wenn kein Zeilenumbruch gefunden wurde, aber 4 Werte, dann suche nach dem dritten Komma
      if (endIndex == -1 && commaCount >= 3) {
        // Finde die Position nach dem dritten Komma
        int commaPos = -1;
        for (int i = 0; i < 3; i++) {
          commaPos = _receiveBuffer.indexOf(',', commaPos + 1);
        }
        // Setze das Ende nach dem letzten erwarteten Wert
        endIndex = _receiveBuffer.indexOf(',', commaPos + 1);
        // Wenn kein weiteres Komma gefunden, nehme den ganzen Rest
        if (endIndex == -1) endIndex = _receiveBuffer.length;
      }

      // Wenn ein Ende gefunden wurde, verarbeite bis zu diesem Punkt
      if (endIndex != -1) {
        final line = _receiveBuffer.substring(0, endIndex).trim();
        _receiveBuffer = _receiveBuffer.substring(endIndex + 1);

        // debugPrint('Gefundene komplette Zeile: "$line", restlicher Puffer: "$_receiveBuffer"',);

        // Verarbeite die Datenzeile
        if (line.isNotEmpty) {
          _processDataLine(line);
        }

        // Verarbeite den Rest des Puffers rekursiv
        _processBufferForCompleteLines();
      }
    }
  }

  void _processDataLine(String line) {
    try {
      // Entferne alle Zeilenumbrüche
      line = line.replaceAll('\r', '').replaceAll('\n', '');

      // Versuche, die Zeile zu parsen
      final parts = line.split(',');
      if (parts.length >= 4) {
        try {
          final swr = double.parse(parts[0]);
          final r = double.parse(parts[1]);
          final x = double.parse(parts[2]);
          final z = double.parse(parts[3]);

          // Berechne die Frequenz
          final double start = _currentFrequency;
          final double end = _endFrequency;
          final double step = (end - start) / (_expectedDatapoints - 1);
          final double frequency =
              _currentFrequency + (_receivedDatapoints * _stepSize);

          // debugPrint('Geparste Werte: Frequenz=${frequency.toStringAsFixed(1)} kHz, SWR=$swr, R=$r, X=$x, Z=$z',);

          // Erstelle ein neues Scan-Ergebnis
          final result = ScanResult(
            frequency: frequency,
            swr: swr,
            r: r,
            x: x,
            z: z,
          );

          // Prüfe die Plausibilität der Werte
          if (swr < 1.0 || swr > 30.0) {
            // debugPrint('Ignoriere unplausiblen SWR-Wert: $swr');
            return;
          }

          // Ergebnis zur Liste hinzufügen
          final updatedResults = List<ScanResult>.from(scanResults);
          updatedResults.add(result);
          // Sortiere nach Frequenz
          updatedResults.sort((a, b) => a.frequency.compareTo(b.frequency));
          scanResults.value = updatedResults;

          // Nach erfolgreichem Hinzufügen eines Datenpunkts
          _receivedDatapoints++;

          // Aktualisiere Fortschritt
          if (_expectedDatapoints > 0) {
            progress.value = (_receivedDatapoints / _expectedDatapoints).clamp(
              0.0,
              1.0,
            );
            scanStatus.value =
                "Scan läuft... ${(_receivedDatapoints * 100 / _expectedDatapoints).toInt()}%";
          }
        } catch (e) {
          // debugPrint('Fehler beim Parsen der Werte: $e');
        }
      } else {
        // debugPrint('Ungültiges Format (zu wenige Werte): "$line"');
      }
    } catch (e) {
      // debugPrint('Fehler beim Verarbeiten der Datenzeile: $e');
    }
  }

  void _processResponseLine(String line) {
    try {
      // Versuche, die Antwort zu parsen (Format: swr,r,x,z)
      final parts = line.split(',');
      if (parts.length >= 4) {
        try {
          final swr = double.parse(parts[0]);
          final r = double.parse(parts[1]);
          final x = double.parse(parts[2]);
          final z = double.parse(parts[3]);

          // Berechne die Frequenz basierend auf dem aktuellen Datenpunkt
          final double start = _currentFrequency;
          final double end = _endFrequency;
          final double step = (end - start) / (_expectedDatapoints - 1);
          final double frequency = start + (_receivedDatapoints * step);

          // debugPrint('Geparste Werte: Frequenz=${frequency.toStringAsFixed(1)} kHz, SWR=$swr, R=$r, X=$x, Z=$z',);

          // Erstelle ein neues Scan-Ergebnis
          final result = ScanResult(
            frequency: frequency,
            swr: swr,
            r: r,
            x: x,
            z: z,
          );

          // Prüfe, ob der Wert plausibel ist
          if (swr < 0 || swr > 30) {
            // debugPrint'Ignoriere unplausiblen SWR-Wert: $swr');
            return;
          }

          // Ergebnis zur Liste hinzufügen
          final updatedResults = List<ScanResult>.from(scanResults);

          // Überprüfe auf Duplikate (gleiche Frequenz)
          final existingIndex = updatedResults.indexWhere(
            (r) => (r.frequency - frequency).abs() < 0.001,
          );

          if (existingIndex >= 0) {
            // Ersetze den existierenden Wert
            updatedResults[existingIndex] = result;
          } else {
            // Füge neuen Wert hinzu
            updatedResults.add(result);
          }

          // Sortiere nach Frequenz
          updatedResults.sort((a, b) => a.frequency.compareTo(b.frequency));
          scanResults.value = updatedResults;

          // debugPrint'Scan-Ergebnis hinzugefügt: $result');

          // Nach erfolgreichem Hinzufügen eines Datenpunkts
          _receivedDatapoints++;

          // Aktualisiere Fortschritt
          if (_expectedDatapoints > 0) {
            progress.value = (_receivedDatapoints / _expectedDatapoints).clamp(
              0.0,
              1.0,
            );
            scanStatus.value =
                "Scan läuft... ${(_receivedDatapoints * 100 / _expectedDatapoints).toInt()}%";
          }
        } catch (e) {
          // debugPrint'Fehler beim Parsen der Werte: $e');
        }
      }
    } catch (e) {
      // debugPrint'Fehler beim Verarbeiten der Antwortzeile: $e');
    }
  }

  // In _setupResponseListener
  bool _ignoreNextResponses = false;

  void _setupResponseListener() {
    if (connection != null && connection!.isConnected) {
      connection!.input!.listen(
        (data) {
          if (_ignoreNextResponses) {
            // debugPrint('Ignoriere Antwort (Puffer wird geleert): ${String.fromCharCodes(data)}',);
            return;
          }

          // Normale Verarbeitung
          _processScanResponse(data);
        },
        // ...
      );
    }
  }

  // Scan abbrechen
  // Ändere die Methode, um einen Future<void> zurückzugeben
  Future<void> cancelScan() async {
    try {
      // debugPrint('Versuche, Scan abzubrechen...');

      // 1. Timer abbrechen
      if (_scanTimer != null) {
        // debugPrint'Timer wird abgebrochen');
        _scanTimer?.cancel();
        _scanTimer = null;
      }

      // 2. Status aktualisieren (vor dem Senden des Befehls!)
      isScanning.value = false;
      scanStatus.value = "Scan abgebrochen";
      progress.value = 0.0;

      // 3. Befehl an das Gerät senden - verschiedene Möglichkeiten probieren
      if (connection != null && connection!.isConnected) {
        // debugPrint'Sende Abbruchbefehl an das Gerät');

        // Versuche verschiedene mögliche Abbruchbefehle
        final commands = [
          'off\r\n',
          'stop\r\n',
          '\r\n', // Leere Zeile könnte den aktuellen Befehl abbrechen
          'scan 0 0 0\r\n', // Ungültiger Scan-Befehl könnte aktuellen Scan abbrechen
        ];

        // Sende alle Befehle mit kurzen Pausen dazwischen
        for (var cmd in commands) {
          try {
            // debugPrint'Sende Abbruchbefehl: $cmd');
            connection!.output.add(Uint8List.fromList(cmd.codeUnits));
            await connection!.output.allSent;
            await Future.delayed(Duration(milliseconds: 100));
          } catch (e) {
            // debugPrint'Fehler beim Senden von $cmd: $e');
          }
        }
      }

      // 4. Puffer leeren
      _receiveBuffer = "";

      // 5. Variablen zurücksetzen
      _scanStarted = false;
      _receivedDatapoints = 0;

      // 6. Kurze Pause, um sicherzustellen, dass alles gestoppt ist
      await Future.delayed(Duration(milliseconds: 300));

      // debugPrint'Scan abgebrochen');
    } catch (e) {
      // debugPrint'Fehler beim Abbrechen des Scans: $e');
    }
  }

  // Aufräumen
  @override
  void onClose() {
    _scanTimer?.cancel();
    _scanSubscription?.cancel();
    _adapterStateSubscription?.cancel();
    _scanningStateSubscription?.cancel();
    disconnectDevice();
    super.onClose();
  }
}
