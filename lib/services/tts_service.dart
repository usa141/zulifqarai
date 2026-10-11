import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TtsService extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  bool _isMuted = false;

  bool get isSpeaking => _isSpeaking;
  bool get isMuted => _isMuted;

  TtsService() {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage('en-US');
      await _flutterTts.setSpeechRate(0.5);
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);

      _flutterTts.setStartHandler(() {
        _isSpeaking = true;
        notifyListeners();
      });

      _flutterTts.setCompletionHandler(() {
        _isSpeaking = false;
        notifyListeners();
      });

      _flutterTts.setErrorHandler((msg) {
        _isSpeaking = false;
        notifyListeners();
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing TTS: $e');
      }
    }
  }

  Future<void> speak(String text) async {
    if (_isMuted || text.trim().isEmpty) return;
    try {
      await _flutterTts.stop();
      await _flutterTts.speak(text);
    } catch (e) {
      if (kDebugMode) {
        print('Error speaking text: $e');
      }
    }
  }

  Future<void> stop() async {
    try {
      await _flutterTts.stop();
      _isSpeaking = false;
      notifyListeners();
    } catch (e) {
      // Ignored
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
    if (_isMuted && _isSpeaking) {
      stop();
    }
    notifyListeners();
  }
}
