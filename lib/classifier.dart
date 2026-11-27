import 'dart:io';
import 'dart:math' as math;
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
        _interpreter = await Interpreter.fromAsset('assets/coffee_leaf_model.tflite');
      } catch (e) {
        try {
          _interpreter = await Interpreter.fromAsset('assets/coffee_disease_model.tflite');
        } catch (e2) {
          _interpreter = await Interpreter.fromAsset('assets/_coffee_leaf_model.tflite');
        }
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
      print('CoffeeClassifier: Model loaded successfully.');
    } catch (e) {
      print('CoffeeClassifier Error loading model: $e');
      _isLoaded = false;
    }
  }

  Future<PredictionResult?> classifyImage(File imageFile) async {
    try {
      if (_interpreter == null) {
        await loadModel();
        if (_interpreter == null) return null;
      }

      final Uint8List imageBytes = await imageFile.readAsBytes();
      final img.Image? originalImage = img.decodeImage(imageBytes);
      if (originalImage == null) return null;

      final inputTensor = _interpreter!.getInputTensor(0);
      final inputShape = inputTensor.shape;
      final int inputHeight = (inputShape.length > 1) ? inputShape[1] : 224;
      final int inputWidth = (inputShape.length > 2) ? inputShape[2] : 224;

      final img.Image resizedImage = img.copyResize(
        originalImage,
        width: inputWidth,
        height: inputHeight,
      );

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

      final outputTensor = _interpreter!.getOutputTensor(0);
      final outputShape = outputTensor.shape;
      final int numClasses = (outputShape.length > 1) ? outputShape[1] : _labels.length;
      var output = List.generate(1, (_) => List<double>.filled(numClasses, 0.0));

      _interpreter!.run(input, output);

      List<double> rawOutput = List<double>.from(output[0]);

      // Softmax normalization
      double sum = rawOutput.fold(0.0, (prev, elem) => prev + elem);
      List<double> probabilities;
      if ((sum - 1.0).abs() > 0.05 || rawOutput.any((val) => val < 0.0)) {
        double maxLogit = rawOutput.reduce((a, b) => a > b ? a : b);
        List<double> expValues = rawOutput.map((val) => math.exp(val - maxLogit)).toList();
        double sumExp = expValues.fold(0.0, (prev, elem) => prev + elem);
        probabilities = expValues.map((val) => val / sumExp).toList();
      } else {
        probabilities = rawOutput;
      }

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

      return PredictionResult(
        label: topLabel,
        amharicLabel: amharicName,
        confidence: maxProb,
        allScores: allScores,
        isValidLeaf: true,
        validationMessage: null,
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