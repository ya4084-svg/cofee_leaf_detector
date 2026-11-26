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

  /// Load model and labels from assets
  Future<void> loadModel() async {
    try {
      // 1. Try loading coffee_leaf_model.tflite first (the new 224x224 model)
      try {
        _interpreter = await Interpreter.fromAsset('assets/coffee_leaf_model.tflite');
      } catch (e) {
        try {
          _interpreter = await Interpreter.fromAsset('assets/coffee_disease_model.tflite');
        } catch (e2) {
          _interpreter = await Interpreter.fromAsset('assets/_coffee_leaf_model.tflite');
        }
      }

      // 2. Load labels
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
      print('CoffeeClassifier: Model loaded successfully.');
    } catch (e) {
      print('CoffeeClassifier Error loading model: $e');
      _isLoaded = false;
    }
  }

  /// Classify image with dynamic input shape detection
  Future<PredictionResult?> classifyImage(File imageFile) async {
    try {
      if (_interpreter == null) {
        await loadModel();
        if (_interpreter == null) {
          print('CoffeeClassifier: Interpreter is null!');
          return null;
        }
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      // Dynamically get model input dimensions (224x224 for EfficientNet)
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final int inputHeight = (inputShape.length > 1) ? inputShape[1] : 224;
      final int inputWidth = (inputShape.length > 2) ? inputShape[2] : 224;

      // 1. Direct Resize to model dimensions
      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: inputWidth,
        height: inputHeight,
      );

      // 2. Botanical Pre-Check
      int foliagePixels = 0;
      int totalSampled = 0;
      for (int y = 0; y < resizedImage.height; y += 4) {
        for (int x = 0; x < resizedImage.width; x += 4) {
          final pixel = resizedImage.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;
          totalSampled++;

          final isGreenish = (g > r * 0.80 && g > b * 1.10 && g > 25);
          final isYellowBrownRust = (r > 35 && g > 30 && b < (r + g) * 0.50);
          final isDarkFoliage = (g >= b && r >= b && (r + g + b) > 30 && (r + g + b) < 420);

          if (isGreenish || isYellowBrownRust || isDarkFoliage) {
            foliagePixels++;
          }
        }
      }

      final double foliageRatio = totalSampled > 0 ? (foliagePixels / totalSampled) : 0.0;

      // 3. Raw 0-255 float32 input tensor for EfficientNetB0
      var input = List.generate(
        1,
        (_) => List.generate(
          inputHeight,
          (y) => List.generate(
            inputWidth,
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

      final outputShape = _interpreter!.getOutputTensor(0).shape;
      final int numClasses = (outputShape.length > 1) ? outputShape[1] : _labels.length;
      var output = List.generate(1, (_) => List<double>.filled(numClasses, 0.0));

      // 4. Run inference
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

      // Check if image has leaf characteristics
      if (foliageRatio < 0.15 || maxProb < 0.40) {
        isValid = false;
        validationMsg = 'ትክክለኛ የቡና ቅጠል ፎቶ አይደለም ወይም በቂ ብርሃን የለውም!\nእባክዎ ካሜራውን ወደ ቡና ቅጠሉ አስጠግተው በድጋሚ ፎቶ ያንሱ።';
      }

      return PredictionResult(
        label: topLabel,
        amharicLabel: amharicName,
        confidence: maxProb,
        allScores: allScores,
        isValidLeaf: isValid,
        validationMessage: validationMsg,
      );
    } catch (e) {
      print('CoffeeClassifier error: $e');
      return null;
    }
  }

  void close() {
    _interpreter?.close();
  }
}