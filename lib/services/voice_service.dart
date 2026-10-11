import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

enum VoiceState { idle, listening, processing, speaking, error }

class VoiceService extends ChangeNotifier {
  final stt.SpeechToText _speech = stt.SpeechToText();

  VoiceState _state = VoiceState.idle;
  String _recognizedText = '';
  String _errorMessage = '';
  bool _isAvailable = false;

  VoiceState get state => _state;
  String get recognizedText => _recognizedText;
  String get errorMessage => _errorMessage;
  bool get isAvailable => _isAvailable;

  VoiceService() {
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      _isAvailable = await _speech.initialize(
        onError: (val) {
          _state = VoiceState.error;
          _errorMessage = val.errorMsg;
          notifyListeners();
        },
        onStatus: (val) {
          if (val == 'done') {
            if (_state == VoiceState.listening) {
              _state = VoiceState.idle;
              notifyListeners();
            }
          }
        },
      );
    } catch (e) {
      _isAvailable = false;
      if (kDebugMode) {
        debugPrint('Error initializing speech recognition: $e');
      }
    }
  }

  Future<bool> requestMicrophonePermission() async {
    final status = await Permission.microphone.request();
    return status.isGranted;
  }

  Future<void> startListening({required Function(String text) onResult}) async {
    final hasPermission = await requestMicrophonePermission();
    if (!hasPermission) {
      _state = VoiceState.error;
      _errorMessage = 'Microphone permission denied';
      notifyListeners();
      return;
    }

    if (!_isAvailable) {
      await _initSpeech();
    }

    if (_isAvailable) {
      _state = VoiceState.listening;
      _recognizedText = '';
      _errorMessage = '';
      notifyListeners();

      await _speech.listen(
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 4),
        onResult: (result) {
          _recognizedText = result.recognizedWords;
          notifyListeners();
          if (result.finalResult) {
            _state = VoiceState.processing;
            notifyListeners();
            onResult(_recognizedText);
            _state = VoiceState.idle;
            notifyListeners();
          }
        },
      );
    } else {
      _state = VoiceState.error;
      _errorMessage = 'Speech recognition unavailable on this device';
      notifyListeners();
    }
  }

  Future<void> stopListening() async {
    await _speech.stop();
    _state = VoiceState.idle;
    notifyListeners();
  }
}
