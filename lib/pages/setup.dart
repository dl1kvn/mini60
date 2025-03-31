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

  @override
  void initState() {
    super.initState();
    _loadBands();
  }

  void _loadBands() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList('bandRanges') ?? [];
    setState(() {
      bands = list.map((e) => BandRange.fromJson(jsonDecode(e))).toList();
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
      bands.add(BandRange(name, start, end));
      nameController.clear();
      startController.clear();
      endController.clear();
      _saveBands();
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
      appBar: AppBar(title: Text('Bänder verwalten')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name (z. B. 160m)'),
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
                    decoration: InputDecoration(labelText: 'Ende (kHz)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: _addBand,
              icon: Icon(Icons.add),
              label: Text('Band hinzufügen'),
            ),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: bands.length,
                itemBuilder: (context, index) {
                  final band = bands[index];
                  return ListTile(
                    title: Text(
                      '${band.name}: ${band.start.toInt()}–${band.end.toInt()} kHz',
                    ),
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
