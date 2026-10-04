import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter/foundation.dart';

class VoiceService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();
  bool _isSpeaking = false;

  VoiceService() {
    _initTts();
  }

  void _initTts() async {
    await _tts.setLanguage("en-US");
    await _tts.setPitch(1.0);
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    
    _tts.setStartHandler(() => _isSpeaking = true);
    _tts.setCompletionHandler(() => _isSpeaking = false);
    _tts.setErrorHandler((msg) => _isSpeaking = false);
  }

  Future<void> speak(String text) async {
    if (text.isEmpty) return;
    _isSpeaking = true;
    await _tts.speak(text);
  }

  Future<void> waitUntilSilent() async {
    int timeout = 0;
    while (_isSpeaking && timeout < 50) {
      await Future.delayed(const Duration(milliseconds: 200));
      timeout++;
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    _isSpeaking = false;
  }

  Future<bool> initSpeech() async {
    try {
      return await _stt.initialize(
        onError: (error) => print("STT Error: ${error.toString()}"),
        onStatus: (status) => print("STT Status: $status"),
      );
    } catch (e) {
      return false;
    }
  }

  void startListening({required Function(String) onResult, required VoidCallback onDone}) async {
    try {
      if (!_stt.isAvailable) {
        final available = await initSpeech();
        if (!available) return;
      }
      await _stt.listen(
        onResult: (result) {
          onResult(result.recognizedWords);
          if (result.finalResult) {
            if (result.recognizedWords.trim().length > 2) {
              onDone();
            }
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 15),
        partialResults: true,
      );
    } catch (e) {
      debugPrint("STT Listening exception handled: $e");
    }
  }

  void stopListening() async {
    await _stt.stop();
  }

  bool get isListening => _stt.isListening;
  bool get isSpeaking => _isSpeaking;
}
