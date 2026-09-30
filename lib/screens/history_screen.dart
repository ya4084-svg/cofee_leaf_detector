import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/disease_data.dart';
import '../services/history_service.dart';
import '../services/language_service.dart';
import '../widgets/treatment_bottom_sheet.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final LanguageService _lang = LanguageService.instance;
  List<ScanRecord> _records = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final list = await HistoryService.getHistory();
    setState(() {
      _records = list;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    if (_records.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 10),
            Text(_lang.t('no_history'), style: TextStyle(color: Colors.grey.shade600)),
          ],
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_records.length} ${_lang.t('tab_history')}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextButton.icon(
                onPressed: () async {
                  await HistoryService.clearHistory();
                  _load();
                },
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                label: Text(_lang.t('clear_history'), style: const TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _records.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final item = _records[index];
              final info = CoffeeDiseaseDatabase.get(item.diseaseKey);
              final localizedName = info.getName(_lang.currentLanguage);
              final dateStr = DateFormat('MMM d, y • h:mm a').format(item.timestamp);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: File(item.imagePath).existsSync()
                        ? Image.file(File(item.imagePath), width: 48, height: 48, fit: BoxFit.cover)
                        : Container(width: 48, height: 48, color: Colors.grey.shade300, child: const Icon(Icons.spa)),
                  ),
                  title: Text(localizedName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  subtitle: Text(dateStr, style: const TextStyle(fontSize: 11)),
                  trailing: Text(
                    '${(item.confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E5E3A)),
                  ),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => TreatmentBottomSheet(info: info),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
