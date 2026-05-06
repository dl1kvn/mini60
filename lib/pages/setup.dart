import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BandRange {
  final String name;
  final double start;
  final double end;

  BandRange(this.name, this.start, this.end);

  Map<String, dynamic> toJson() => {'name': name, 'start': start, 'end': end};

  factory BandRange.fromJson(Map<String, dynamic> json) =>
      BandRange(json['name'], json['start'], json['end']);
}

class SetupPage extends StatefulWidget {
  @override
  _SetupPageState createState() => _SetupPageState();
}

class _SetupPageState extends State<SetupPage> {
  final nameController = TextEditingController();
  final startController = TextEditingController();
  final endController = TextEditingController();

  List<BandRange> bands = [];
  int? editingIndex;
  double _stepsPerScan = 50.0;

  @override
  void initState() {
    super.initState();
    _loadBands();
    _loadStepsPerScan();
  }

  void _loadBands() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bandRanges') ?? [];
    setState(() {
      bands = list.map((e) => BandRange.fromJson(jsonDecode(e))).toList();
    });
  }

  void _loadStepsPerScan() async {
    final prefs = await SharedPreferences.getInstance();
    final steps = prefs.getInt('steps_per_scan') ?? 50;
    setState(() {
      _stepsPerScan = steps.toDouble();
    });
  }

  void _saveStepsPerScan(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps_per_scan', value.round());
    setState(() {
      _stepsPerScan = value;
    });
  }

  void _saveBands() async {
    final prefs = await SharedPreferences.getInstance();
    final list = bands.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('bandRanges', list);
  }

  void _addBand() {
    final name = nameController.text.trim();
    final start = double.tryParse(startController.text);
    final end = double.tryParse(endController.text);
    if (name.isEmpty || start == null || end == null || start >= end) return;

    setState(() {
      if (editingIndex != null) {
        // Update existing band
        bands[editingIndex!] = BandRange(name, start, end);
        editingIndex = null;
      } else {
        // Add new band
        bands.add(BandRange(name, start, end));
      }
      nameController.clear();
      startController.clear();
      endController.clear();
      _saveBands();
    });
  }

  void _editBand(int index) {
    final band = bands[index];
    setState(() {
      editingIndex = index;
      nameController.text = band.name;
      startController.text = band.start.toInt().toString();
      endController.text = band.end.toInt().toString();
    });
  }

  void _cancelEdit() {
    setState(() {
      editingIndex = null;
      nameController.clear();
      startController.clear();
      endController.clear();
    });
  }

  void _removeBand(int index) {
    setState(() {
      bands.removeAt(index);
      _saveBands();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Steps Per Scan Section
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.tune, color: Colors.blue),
                        SizedBox(width: 8),
                        Text(
                          'Steps Per Scan',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Slider(
                            value: _stepsPerScan,
                            min: 20,
                            max: 120,
                            divisions: 160,
                            label: _stepsPerScan.round().toString(),
                            onChanged: (value) {
                              _saveStepsPerScan(value);
                            },
                          ),
                        ),
                        SizedBox(width: 8),
                        Container(
                          width: 50,
                          child: Text(
                            '${_stepsPerScan.round()}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Number of measurement points per frequency scan (default: 50)',
                      style: TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16),
            // Band Management Section
            Text(
              'Manage Bands',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name (e.g. 160m)'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: startController,
                    decoration: InputDecoration(labelText: 'Start (kHz)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: endController,
                    decoration: InputDecoration(labelText: 'End (kHz)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _addBand,
                    icon: Icon(editingIndex != null ? Icons.save : Icons.add),
                    label: Text(
                      editingIndex != null ? 'Update Band' : 'Add Band',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          editingIndex != null ? Colors.orange : null,
                    ),
                  ),
                ),
                if (editingIndex != null) ...[
                  SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: _cancelEdit,
                    icon: Icon(Icons.cancel),
                    label: Text('Cancel'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey,
                    ),
                  ),
                ],
              ],
            ),
            Divider(),
            Expanded(
              child: ReorderableListView.builder(
                itemCount: bands.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) {
                      newIndex -= 1;
                    }
                    final item = bands.removeAt(oldIndex);
                    bands.insert(newIndex, item);
                    _saveBands();
                  });
                },
                itemBuilder: (context, index) {
                  final band = bands[index];
                  final isEditing = editingIndex == index;
                  return ListTile(
                    key: ValueKey(band.name + band.start.toString()),
                    leading: Icon(Icons.drag_handle),
                    title: Text(
                      '${band.name}: ${band.start.toInt()}–${band.end.toInt()} kHz',
                    ),
                    tileColor:
                        isEditing ? Colors.orange.withOpacity(0.2) : null,
                    onTap: () => _editBand(index),
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removeBand(index),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
