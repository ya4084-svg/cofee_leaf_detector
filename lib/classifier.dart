import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class PredictionResult {
  final String label;
  final String amharicLabel;
  final double confidence;
  final Map<String, double> allScores;
  final bool isValidLeaf;
  final String? validationMessage;

  PredictionResult({
    required this.label,
    required this.amharicLabel,
    required this.confidence,
    required this.allScores,
    this.isValidLeaf = true,
    this.validationMessage,
  });
}

class CoffeeClassifier {
  Interpreter? _interpreter;
  List<String> _labels = [];
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  static const Map<String, String> amharicNames = {
    'Cerscospora': 'ሰርኮስፖራ (ቡናማ አይን)',
    'Healthy': 'ጤናማ ቅጠል',
    'Leaf rust': 'የቡና ቅጠል ዝገት',
    'Miner': 'ቅጠል ቆፋሪ ትል',
    'Phoma': 'ፎማ (የቅጠል ጫፍ መድረቅ)',
  };

  Future<void> loadModel() async {
    try {
      try {
        _interpreter = await Interpreter.fromAsset('assets/coffee_disease_model.tflite');
      } catch (e) {
        _interpreter = await Interpreter.fromAsset('assets/coffee_leaf_model.tflite');
      }
      
      try {
        final labelData = await rootBundle.loadString('assets/labels.txt');
        _labels = labelData
            .split('\n')
            .map((s) => s.trim())
            .where((s) => s.isNotEmpty)
            .toList();
      } catch (e) {
        _labels = ['Cerscospora', 'Healthy', 'Leaf rust', 'Miner', 'Phoma'];
      }

      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
    }
  }

  Future<PredictionResult?> classifyImage(File imageFile) async {
    if (_interpreter == null) {
      await loadModel();
      if (_interpreter == null) return null;
    }

    final Uint8List imageBytes = await imageFile.readAsBytes();
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) return null;

    final img.Image resizedImage = img.copyResize(
      originalImage,
      width: 128,
      height: 128,
    );

    int foliagePixels = 0;
    int totalSampled = 0;
    for (int y = 0; y < resizedImage.height; y += 2) {
      for (int x = 0; x < resizedImage.width; x += 2) {
        final pixel = resizedImage.getPixel(x, y);
        final r = pixel.r;
        final g = pixel.g;
        final b = pixel.b;
        totalSampled++;

        final isGreenish = (g > r * 0.82 && g > b * 1.15 && g > 25);
        final isYellowBrownRust = (r > 35 && g > 30 && b < (r + g) * 0.48);
        final isDarkFoliage = (g >= b && r >= b && (r + g + b) > 30 && (r + g + b) < 420);

        if (isGreenish || isYellowBrownRust || isDarkFoliage) {
          foliagePixels++;
        }
      }
    }

    final double foliageRatio = totalSampled > 0 ? (foliagePixels / totalSampled) : 0.0;

    var input = List.generate(
      1,
      (_) => List.generate(
        128,
        (y) => List.generate(
          128,
          (x) {
            final pixel = resizedImage.getPixel(x, y);
            return [
              pixel.r.toDouble(),
              pixel.g.toDouble(),
              pixel.b.toDouble(),
            ];
          },
        ),
      ),
    );

    var output = List.generate(1, (_) => List<double>.filled(5, 0.0));
    _interpreter!.run(input, output);

    final List<double> probabilities = output[0];

    int maxIndex = 0;
    double maxProb = -1.0;
    final Map<String, double> allScores = {};

    for (int i = 0; i < probabilities.length; i++) {
      final labelName = i < _labels.length ? _labels[i] : 'Class $i';
      final prob = probabilities[i];
      allScores[labelName] = prob;

      if (prob > maxProb) {
        maxProb = prob;
        maxIndex = i;
      }
    }

    final topLabel = maxIndex < _labels.length ? _labels[maxIndex] : 'Unknown';
    final amharicName = amharicNames[topLabel] ?? topLabel;

    bool isValid = true;
    String? validationMsg;

    if (foliageRatio < 0.22 || maxProb < 0.55) {
      isValid = false;
      validationMsg = 'ትክክለኛ የቡና ቅጠል ፎቶ አይደለም!\nእባክዎ ካሜራውን ወደ ቡና ቅጠሉ አስጠግተው በቂ ብርሃን ባለበት ቦታ ፎቶ ያንሱ።';
    }

    return PredictionResult(
      label: topLabel,
      amharicLabel: amharicName,
      confidence: maxProb,
      allScores: allScores,
      isValidLeaf: isValid,
      validationMessage: validationMsg,
    );
  }

  void close() {
    _interpreter?.close();
  }
}
