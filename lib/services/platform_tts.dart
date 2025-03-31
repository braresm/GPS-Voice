import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class PlatformTts {
  static const platform = MethodChannel('com.example.gps_voice/tts');
  static bool _isInitialized = false;

  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      await platform.invokeMethod('initializeTts');
      _isInitialized = true;
    } catch (e) {
      debugPrint('Failed to initialize TTS: $e');
    }
  }

  static Future<void> speak(String text) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      await platform.invokeMethod('speak', {'text': text});
    } catch (e) {
      debugPrint('Failed to speak: $e');
    }
  }

  static Future<void> stop() async {
    try {
      await platform.invokeMethod('stop', {});
    } catch (e) {
      debugPrint('Failed to stop TTS: $e');
    }
  }
} 