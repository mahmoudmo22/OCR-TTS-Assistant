import 'package:flutter_tts/flutter_tts.dart';

typedef SpeakingChanged = void Function(bool isSpeaking);

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  SpeakingChanged? _onSpeakingChanged;

  Future<void> initialize({
    required String language,
    required double speechRate,
    required double pitch,
    SpeakingChanged? onSpeakingChanged,
  }) async {
    _onSpeakingChanged = onSpeakingChanged;

    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setPitch(pitch);

    _flutterTts.setStartHandler(() {
      _onSpeakingChanged?.call(true);
    });
    _flutterTts.setCompletionHandler(() {
      _onSpeakingChanged?.call(false);
    });
    _flutterTts.setCancelHandler(() {
      _onSpeakingChanged?.call(false);
    });
    _flutterTts.setErrorHandler((_) {
      _onSpeakingChanged?.call(false);
    });
  }

  Future<void> speak(String text) async {
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }
}
