import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScanRecord {
  final String id;
  final String imagePath;
  final String diseaseKey;
  final double confidence;
  final DateTime timestamp;

  ScanRecord({
    required this.id,
    required this.imagePath,
    required this.diseaseKey,
    required this.confidence,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'imagePath': imagePath,
    'diseaseKey': diseaseKey,
    'confidence': confidence,
    'timestamp': timestamp.toIso8601String(),
  };

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
    id: json['id'] ?? '',
    imagePath: json['imagePath'] ?? '',
    diseaseKey: json['diseaseKey'] ?? 'Healthy',
    confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
  );
}

class HistoryService {
  static const String _key = 'coffee_scan_history';

  static Future<List<ScanRecord>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final String? rawJson = prefs.getString(_key);
    if (rawJson == null || rawJson.isEmpty) return [];

    try {
      final List<dynamic> decoded = jsonDecode(rawJson);
      return decoded.map((item) => ScanRecord.fromJson(item)).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> saveScan({
    required String imagePath,
    required String diseaseKey,
    required double confidence,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final List<ScanRecord> currentList = await getHistory();

    final newRecord = ScanRecord(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: imagePath,
      diseaseKey: diseaseKey,
      confidence: confidence,
      timestamp: DateTime.now(),
    );

    currentList.insert(0, newRecord);
    if (currentList.length > 50) {
      currentList.removeRange(50, currentList.length);
    }

    final encoded = jsonEncode(currentList.map((e) => e.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}