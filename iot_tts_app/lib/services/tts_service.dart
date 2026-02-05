import 'package:flutter_tts/flutter_tts.dart';

typedef SpeakingChanged = void Function(bool isSpeaking);

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  SpeakingChanged? _onSpeakingChanged;
  bool _isReady = false;

  Future<void> initialize({
    required String language,
    required double speechRate,
    required double pitch,
    SpeakingChanged? onSpeakingChanged,
  }) async {
    _onSpeakingChanged = onSpeakingChanged;

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

    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setPitch(pitch);
    _isReady = true;
  }

  Future<void> speak(String text) async {
    if (!_isReady) {
      return;
    }
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }

  Future<void> pause() async {
    await _flutterTts.pause();
  }

  bool get isReady => _isReady;
}
