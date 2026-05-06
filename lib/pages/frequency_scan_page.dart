import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mini60/pages/setup.dart';
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
        title: Text('Frequency Scan'),
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
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 8.0),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.blue.shade100],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.blue.shade300, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.03),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 4.0,
                  vertical: 1.0,
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<BandRange>(
                    hint: Row(
                      children: [
                        Text(
                          "Select Band",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    value: bandRanges.contains(selectedBand) ? selectedBand : null,
                    isExpanded: true,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.blue.shade700,
                      size: 30,
                    ),
                    dropdownColor: Colors.blue.shade50,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900,
                    ),
                    items:
                        bandRanges.map((band) {
                          return DropdownMenuItem(
                            value: band,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.radio,
                                  color: Colors.blue.shade600,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  "${band.name} (${band.start.toInt()}–${band.end.toInt()} kHz)",
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                    onChanged: (BandRange? band) {
                      if (band != null) {
                        setState(() {
                          selectedBand = band;
                          freqRange = RangeValues(band.start, band.end);
                          startFreqController.text =
                              band.start.round().toString();
                          endFreqController.text = band.end.round().toString();
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
          ),
          _buildScanStatus(),
          Expanded(child: _buildTabView()),
        ],
      ),
    );
  }

  Widget _buildTabView() {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.blue,
            tabs: [
              Tab(icon: Icon(Icons.show_chart)),
              Tab(icon: Icon(Icons.list)),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                // Chart Tab
                Obx(() {
                  final _ = controller.scanResults.length;
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SWRChartWidget(
                      scanResults: controller.scanResults,
                      minFreq: freqRange.start,
                      maxFreq: freqRange.end,
                    ),
                  );
                }),
                // Liste Tab
                _buildResultsList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadBandRanges() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bandRanges') ?? [];
    setState(() {
      bandRanges = list.map((e) => BandRange.fromJson(jsonDecode(e))).toList();

      // Reset selectedBand if it's not in the updated list
      if (selectedBand != null) {
        final stillExists = bandRanges.any(
          (band) => band.name == selectedBand!.name &&
                    band.start == selectedBand!.start &&
                    band.end == selectedBand!.end
        );
        if (!stillExists) {
          selectedBand = null;
        }
      }
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
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(width: 4),
              Expanded(
                child: TextField(
                  controller: endFreqController,
                  decoration: InputDecoration(
                    labelText: 'End (kHz)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    isDense: true,
                  ),
                  keyboardType: TextInputType.number,
                  style: TextStyle(fontSize: 14),
                ),
              ),
              SizedBox(width: 4),
              _buildScanControls(),
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
              Text("End: ${freqRange.end.round()} kHz"),
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
        label: Text(isScanning ? 'Cancel' : 'Start'),
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
            final resultsCount = controller.scanResults.length;

            if (controller.isScanning.value) {
              return Text(
                status.isEmpty
                    ? 'Scanning... ${(progress * 100).toInt()}%'
                    : status,
              );
            } else if (status.isNotEmpty || resultsCount > 0) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (status.isNotEmpty)
                    Text(
                      status,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  if (status.isNotEmpty && resultsCount > 0)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text('•', style: TextStyle(fontSize: 11)),
                    ),
                  if (resultsCount > 0)
                    Text(
                      'Results: $resultsCount',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                ],
              );
            } else {
              return SizedBox.shrink();
            }
          }),
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
                ? 'Scanning...'
                : 'No scan results available yet',
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
        'Invalid Range',
        'Start frequency must be less than end frequency.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    final success = await controller.startFrequencyScan(startFreq, endFreq);

    if (!success) {
      Get.snackbar(
        'Scan Error',
        'The scan could not be started',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

}
