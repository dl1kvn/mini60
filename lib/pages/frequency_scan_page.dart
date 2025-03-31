import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:mini6060/pages/setup.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../controllers/bluetooth_controller.dart';
import '../models/scan_result.dart';
import '../widgets/swr_chart_widget.dart';

class FrequencyScanPage extends StatefulWidget {
  @override
  _FrequencyScanPageState createState() => _FrequencyScanPageState();
}

class _FrequencyScanPageState extends State<FrequencyScanPage> {
  List<BandRange> bandRanges = [];
  BandRange? selectedBand;
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBandRanges();
  }

  final BluetoothController controller = Get.find<BluetoothController>();

  final TextEditingController startFreqController = TextEditingController(
    text: '13900',
  );
  final TextEditingController endFreqController = TextEditingController(
    text: '14400',
  );
  final TextEditingController antennaTypeController = TextEditingController();

  double sliderMin = 1800;
  double sliderMax = 50400;
  RangeValues freqRange = RangeValues(13950, 14400);

  @override
  void initState() {
    super.initState();
    _loadSavedFrequencies();
    _loadBandRanges();
    startFreqController.addListener(_syncTextToSlider);
    endFreqController.addListener(_syncTextToSlider);
  }

  void _loadSavedFrequencies() async {
    final prefs = await SharedPreferences.getInstance();
    final start = prefs.getDouble('startFreq') ?? 1800;
    final end = prefs.getDouble('endFreq') ?? 60000;

    setState(() {
      freqRange = RangeValues(start, end);
      startFreqController.text = start.round().toString();
      endFreqController.text = end.round().toString();
    });
  }

  void _saveFrequencies(double start, double end) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('startFreq', start);
    await prefs.setDouble('endFreq', end);
  }

  void _syncTextToSlider() {
    final start = double.tryParse(startFreqController.text) ?? freqRange.start;
    final end = double.tryParse(endFreqController.text) ?? freqRange.end;
    if (start < end && start >= sliderMin && end <= sliderMax) {
      setState(() {
        freqRange = RangeValues(start, end);
        _saveFrequencies(start, end);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frequenz-Scan'),
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () async {
              await Get.to(() => SetupPage());
              _loadBandRanges(); // reload after coming back
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildFrequencyInputs(),
          _buildRangeSlider(),
          DropdownButton<BandRange>(
            hint: Text("Band wählen"),
            value: selectedBand,
            items:
                bandRanges.map((band) {
                  return DropdownMenuItem(
                    value: band,
                    child: Text(
                      "${band.name} (${band.start.toInt()}–${band.end.toInt()} kHz)",
                    ),
                  );
                }).toList(),
            onChanged: (BandRange? band) {
              if (band != null) {
                setState(() {
                  selectedBand = band;
                  freqRange = RangeValues(band.start, band.end);
                  startFreqController.text = band.start.round().toString();
                  endFreqController.text = band.end.round().toString();
                });
              }
            },
          ),

          _buildScanStatus(),
          Obx(() {
            final _ = controller.scanResults.length;
            return SizedBox(
              height: 330,
              child: SWRChartWidget(
                scanResults: controller.scanResults,
                minFreq: freqRange.start,
                maxFreq: freqRange.end,
              ),
            );
          }),
          Expanded(flex: 1, child: _buildResultsList()),
        ],
      ),
    );
  }

  Future<void> _loadBandRanges() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bandRanges') ?? [];
    setState(() {
      bandRanges = list.map((e) => BandRange.fromJson(jsonDecode(e))).toList();
    });
  }

  Widget _buildFrequencyInputs() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: startFreqController,
                  decoration: InputDecoration(
                    labelText: 'Start (kHz)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: endFreqController,
                  decoration: InputDecoration(
                    labelText: 'Ende (kHz)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              SizedBox(width: 4),
              _buildScanControls(),
            ],
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: antennaTypeController,
                  decoration: InputDecoration(
                    labelText: 'Ant Infos',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 5),
              Expanded(
                child: ElevatedButton.icon(
                  icon: Icon(Icons.chat),
                  label: Text("GPT Check"),
                  onPressed: _analyzeWithChatGPT,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<List<BandRange>> loadBandRanges() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bandRanges') ?? [];
    return list.map((e) => BandRange.fromJson(jsonDecode(e))).toList();
  }

  Widget _buildRangeSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          RangeSlider(
            min: sliderMin,
            max: sliderMax,
            divisions: ((sliderMax - sliderMin) / 100).round(),
            labels: RangeLabels(
              freqRange.start.round().toString(),
              freqRange.end.round().toString(),
            ),
            values: freqRange,
            onChanged: (RangeValues values) {
              setState(() {
                freqRange = values;
                startFreqController.text = values.start.round().toString();
                endFreqController.text = values.end.round().toString();
                _saveFrequencies(values.start, values.end);
              });
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Start: ${freqRange.start.round()} kHz"),
              Text("Ende: ${freqRange.end.round()} kHz"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScanControls() {
    return Obx(() {
      final isScanning = controller.isScanning.value;
      return ElevatedButton.icon(
        icon: Icon(isScanning ? Icons.stop : Icons.play_arrow),
        label: Text(isScanning ? 'Scan abbrechen' : 'Scan starten'),
        style: ElevatedButton.styleFrom(
          backgroundColor: isScanning ? Colors.red : Colors.green,
          foregroundColor: Colors.white,
        ),
        onPressed: _startScan,
      );
    });
  }

  Widget _buildScanStatus() {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Column(
        children: [
          Obx(() {
            if (!controller.isScanning.value) return SizedBox.shrink();
            return Column(
              children: [
                LinearProgressIndicator(
                  value: controller.progress.value,
                  minHeight: 4,
                ),
                SizedBox(height: 3),
              ],
            );
          }),
          Obx(() {
            final status = controller.scanStatus.value;
            final progress = controller.progress.value;
            if (controller.isScanning.value) {
              return Text(
                status.isEmpty
                    ? 'Scan läuft... ${(progress * 100).toInt()}%'
                    : status,
              );
            } else if (status.isNotEmpty) {
              return Text(status, style: TextStyle(fontSize: 11));
            } else {
              return SizedBox.shrink();
            }
          }),
          Obx(
            () =>
                controller.scanResults.isNotEmpty || controller.isScanning.value
                    ? Text(
                      'Gefundene Ergebnisse: ${controller.scanResults.length}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    )
                    : SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    return Obx(() {
      final results = controller.scanResults;
      if (results.isEmpty) {
        return Center(
          child: Text(
            controller.isScanning.value
                ? 'Scan läuft...'
                : 'Noch keine Scan-Ergebnisse vorhanden',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        itemCount: results.length,
        itemBuilder: (context, index) {
          final result = results[index];
          return _buildResultItem(result);
        },
      );
    });
  }

  Widget _buildResultItem(ScanResult result) {
    Color swrColor =
        result.swr > 3.0
            ? Colors.red
            : result.swr > 1.5
            ? Colors.orange
            : Colors.green;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 1, vertical: 1),
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              '${result.frequency.toStringAsFixed(0)}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            Text(
              '- ${result.swr.toStringAsFixed(2)}',
              style: TextStyle(
                color: swrColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              ' R: ${result.r.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              ' Z: ${result.z.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            Text(
              ' X: ${result.x.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startScan() async {
    final startFreq = freqRange.start;
    final endFreq = freqRange.end;

    if (startFreq >= endFreq) {
      Get.snackbar(
        'Ungültiger Bereich',
        'Startfrequenz muss kleiner als Endfrequenz sein.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await controller.startFrequencyScan(startFreq, endFreq);

    if (!success) {
      Get.snackbar(
        'Scan-Fehler',
        'Der Scan konnte nicht gestartet werden',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _analyzeWithChatGPT() async {
    final results = controller.scanResults;
    if (results.isEmpty) {
      Get.snackbar("Keine Daten", "Es gibt keine Ergebnisse zum Analysieren.");
      return;
    }

    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text(
                  "GPT analysiert die Daten...",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          ),
    );

    String dataText = results
        .map(
          (r) =>
              "Frequenz: ${r.frequency} kHz, SWR: ${r.swr}, R: ${r.r}, X: ${r.x}, Z: ${r.z}",
        )
        .join("\n");

    final prompt = '''
Analysiere die folgenden Antennenmesswerte und mache Antennenvorschläge.
${antennaTypeController.text.trim().isNotEmpty ? "Antennentyp: ${antennaTypeController.text.trim()}\n" : ""}
$dataText
''';

    final apiKey = 'sk-...'; // dein eigener API-Key
    final url = Uri.parse("https://api.openai.com/v1/chat/completions");

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          "model": "gpt-3.5-turbo",
          "messages": [
            {
              "role": "system",
              "content": "Du bist ein Experte für Antennenanalyse.",
            },
            {"role": "user", "content": prompt},
          ],
          "temperature": 0.7,
        }),
      );

      Navigator.of(Get.context!).pop();

      if (response.statusCode == 200) {
        final decoded = utf8.decode(response.bodyBytes);
        final result = jsonDecode(decoded);
        final answer = result['choices'][0]['message']['content'];

        showDialog(
          context: Get.context!,
          builder:
              (context) => AlertDialog(
                title: Text("GPT-Analyse"),
                content: SingleChildScrollView(
                  child: Text(answer ?? "Keine Antwort erhalten."),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text("Schließen"),
                  ),
                ],
              ),
        );
      } else {
        Get.snackbar("Fehler", "ChatGPT API-Fehler: ${response.statusCode}");
      }
    } catch (e) {
      Navigator.of(Get.context!).pop();
      Get.snackbar("Fehler", "Fehler bei der Anfrage: $e");
    }
  }
}
