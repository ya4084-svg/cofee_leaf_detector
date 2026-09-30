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

      if (result != null && result.isValidLeaf) {
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
    if (_result == null || !_result!.isValidLeaf) return;
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
      builder: (ctx) => TreatmentBottomSheet(info: info),
    );
  }

  Color _getBadgeColor(String label) {
    if (label.toLowerCase() == 'healthy') return Colors.green.shade700;
    if (label.toLowerCase().contains('rust') || label.toLowerCase().contains('phoma')) {
      return Colors.deepOrange.shade700;
    }
    return Colors.amber.shade800;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 250,
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

          if (_result != null && !_result!.isValidLeaf) ...[
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber.shade400, width: 1.5),
              ),
              child: Column(
                children: [
                  Icon(Icons.warning_amber_rounded, size: 52, color: Colors.amber.shade900),
                  const SizedBox(height: 10),
                  const Text(
                    'ትክክለኛ የቡና ቅጠል ፎቶ አይደለም!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7A4100),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _result!.validationMessage ??
                        'የተነሳው ፎቶ የቡና ቅጠል መሆኑ አልተረጋገጠም። እባክዎ ካሜራውን ወደ ቡና ቅጠሉ አስጠግተው በደንብ የሚያሳይ ፎቶ ያንሱ።',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, height: 1.4, color: Colors.amber.shade900),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton.icon(
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('እንደገና ፎቶ አንሳ (Retake)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade800,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (_result != null && _result!.isValidLeaf) ...[
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
                        final score = entry.value;
                        final name = entry.key;
                        final local = CoffeeDiseaseDatabase.get(name).getName(_lang.currentLanguage);
                        final isTop = name == _result!.label;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    local,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                      color: isTop ? const Color(0xFF1E5E3A) : Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    '${(score * 100).toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: isTop ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 3),
                              LinearProgressIndicator(
                                value: score.clamp(0.0, 1.0),
                                minHeight: 5,
                                borderRadius: BorderRadius.circular(4),
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isTop ? _getBadgeColor(name) : Colors.grey.shade400,
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ],
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }
}
