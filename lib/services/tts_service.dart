import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final FlutterTts _flutterTts = FlutterTts();
  static bool _isInitialized = false;
  static bool isSpeaking = false;

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      await _flutterTts.setSpeechRate(0.45);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() => isSpeaking = true);
      _flutterTts.setCompletionHandler(() => isSpeaking = false);
      _flutterTts.setErrorHandler((msg) => isSpeaking = false);

      _isInitialized = true;
    } catch (e) {
      print('TtsService init error: $e');
    }
  }

  static Future<void> speak(String text, String langCode) async {
    try {
      await init();
      if (isSpeaking) {
        await stop();
        return;
      }

      if (langCode == 'am') {
        await _flutterTts.setLanguage('am-ET');
      } else if (langCode == 'om') {
        await _flutterTts.setLanguage('om-ET');
      } else {
        await _flutterTts.setLanguage('en-US');
      }

      await _flutterTts.speak(text);
    } catch (e) {
      print('TTS speak error: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await _flutterTts.stop();
      isSpeaking = false;
    } catch (e) {
      print('TTS stop error: $e');
    }
  }
}