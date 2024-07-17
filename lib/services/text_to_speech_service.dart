import 'package:flutter_tts/flutter_tts.dart';

class TextToSpeech {
  late FlutterTts _flutterTts;
  bool _isResponding = false;

  TextToSpeech() {
    _flutterTts = FlutterTts();
    initTTS();
  }

  Future<void> initTTS() async {
    try {
      await _flutterTts.setPitch(1);
    } catch (e) {
      print("Error initializing TTS: $e");
    }
  }

  Future<void> speak(String text) async {
    try {
      await _flutterTts.speak(text);
      _isResponding = true;
      _flutterTts.setCompletionHandler(() {
        _isResponding = false;
      });
    } catch (e) {
      print("Error speaking text: $e");
    }
  }

  void stopSpeaking() {
    _flutterTts.stop();
    // _isResponding = false;
  }

  bool get isResponding => _isResponding;
}