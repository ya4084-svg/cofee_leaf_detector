import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../classifier.dart';
import '../models/disease_data.dart';
import '../services/history_service.dart';
import '../services/language_service.dart';
import '../services/tts_service.dart';
import '../widgets/treatment_bottom_sheet.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  final CoffeeClassifier _classifier = CoffeeClassifier();
  final LanguageService _lang = LanguageService.instance;
  final ScrollController _scrollController = ScrollController();

  File? _selectedImage;
  PredictionResult? _result;
  bool _isClassifying = false;

  @override
  void initState() {
    super.initState();
    _classifier.loadModel();
  }

  @override
  void dispose() {
    _classifier.close();
    TtsService.stop();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) return;

      setState(() {
        _selectedImage = File(pickedFile.path);
        _result = null;
        _isClassifying = true;
      });

      final result = await _classifier.classifyImage(_selectedImage!);

      if (result != null) {
        await HistoryService.saveScan(
          imagePath: pickedFile.path,
          diseaseKey: result.label,
          confidence: result.confidence,
        );
      }

      setState(() {
        _result = result;
        _isClassifying = false;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            270.0,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        }
      });
    } catch (e) {
      setState(() {
        _isClassifying = false;
      });
    }
  }

  void _speakDiagnosis() {
    if (_result == null) return;
    final info = CoffeeDiseaseDatabase.get(_result!.label);
    final text = "${info.getName(_lang.currentLanguage)}. "
        "${_lang.t('confidence')}: ${(_result!.confidence * 100).toStringAsFixed(0)}%. "
        "${info.getSymptoms(_lang.currentLanguage)}. "
        "${info.getOrganicCare(_lang.currentLanguage)}";

    TtsService.speak(text, _lang.currentLanguage);
  }

  void _openTreatmentSheet(DiseaseInfo info) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => TreatmentBottomSheet(info: info),
    );
  }

  Color _getBadgeColor(String diseaseKey) {
    switch (diseaseKey) {
      case 'Healthy':
        return Colors.green.shade700;
      case 'Leaf rust':
        return Colors.deepOrange.shade800;
      case 'Cerscospora':
        return Colors.brown.shade700;
      case 'Miner':
        return Colors.purple.shade700;
      case 'Phoma':
        return Colors.red.shade900;
      default:
        return const Color(0xFF1E5E3A);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: _selectedImage != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.file(_selectedImage!, fit: BoxFit.cover),
                        if (_isClassifying)
                          Container(
                            color: Colors.black54,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const CircularProgressIndicator(color: Colors.white),
                                  const SizedBox(height: 12),
                                  Text(
                                    _lang.t('analyzing'),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    )
                  : Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.spa_rounded, size: 68, color: Colors.green.shade300),
                          const SizedBox(height: 10),
                          Text(
                            _lang.t('empty_picker_title'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3748),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            _lang.t('empty_picker_subtitle'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isClassifying ? null : () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: Text(_lang.t('take_photo')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E5E3A),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isClassifying ? null : () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: Text(_lang.t('pick_gallery')),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E5E3A),
                      side: const BorderSide(color: Color(0xFF1E5E3A), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 18),

            // Prediction Card displayed immediately
            if (_result != null) ...[
              Builder(builder: (context) {
                final diseaseInfo = CoffeeDiseaseDatabase.get(_result!.label);
                final localizedName = diseaseInfo.getName(_lang.currentLanguage);
                final badgeColor = _getBadgeColor(_result!.label);

                return Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizedName,
                                    style: const TextStyle(
                                      fontSize: 19,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E5E3A),
                                    ),
                                  ),
                                  Text(
                                    _result!.label,
                                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: badgeColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: badgeColor.withOpacity(0.4)),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${(_result!.confidence * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: badgeColor,
                                    ),
                                  ),
                                  Text(
                                    _lang.t('confidence'),
                                    style: TextStyle(fontSize: 10, color: badgeColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 14),

                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _speakDiagnosis,
                            icon: const Icon(Icons.volume_up_rounded, color: Color(0xFF1E5E3A)),
                            label: Text(
                              _lang.t('listen_voice'),
                              style: const TextStyle(
                                color: Color(0xFF1E5E3A),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: Color(0xFF1E5E3A)),
                              padding: const EdgeInsets.symmetric(vertical: 11),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () => _openTreatmentSheet(diseaseInfo),
                            icon: const Icon(Icons.medical_services_outlined),
                            label: Text(_lang.t('treatment_btn')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E5E3A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          ),
                        ),

                        const Divider(height: 28),

                        ..._result!.allScores.entries.map((entry) {
                          final pct = (entry.value * 100).clamp(0.0, 100.0);
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      CoffeeClassifier.amharicNames[entry.key] ?? entry.key,
                                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                    ),
                                    Text('${pct.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: entry.value,
                                    backgroundColor: Colors.grey.shade200,
                                    color: entry.key == _result!.label ? const Color(0xFF1E5E3A) : Colors.grey.shade400,
                                    minHeight: 6,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}