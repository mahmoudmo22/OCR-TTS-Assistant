import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/easyocr_service.dart';
import '../services/tts_service.dart';

class AppProvider extends ChangeNotifier {
  final TtsService _ttsService = TtsService();

  bool _isProcessing = false;
  bool _isSpeaking = false;
  bool _isTtsReady = false;
  String _lastText = '';
  String _easyOcrBaseUrl = 'http://192.168.1.10:8000';

  String _language = AppConfig.defaultLanguage;
  double _speechRate = AppConfig.defaultSpeechRate;
  double _pitch = AppConfig.defaultPitch;

  AppProvider() {
    _initializeTts();
    _loadEasyOcrBaseUrl();
  }

  bool get isProcessing => _isProcessing;
  bool get isSpeaking => _isSpeaking;
  bool get isTtsReady => _isTtsReady;
  String get lastText => _lastText;
  String get easyOcrBaseUrl => _easyOcrBaseUrl;
  String get language => _language;
  double get speechRate => _speechRate;
  double get pitch => _pitch;

  Future<String> recognizeText(String imagePath) async {
    _isProcessing = true;
    notifyListeners();

    try {
      final text = await _extractViaEasyOcr(imagePath);
      _lastText = text;
      return text;
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> speak(String text) async {
    if (!_isTtsReady) {
      return;
    }
    if (text.trim().isEmpty) {
      return;
    }
    await _ttsService.speak(text);
  }

  Future<void> stop() async {
    await _ttsService.stop();
  }

  Future<void> pause() async {
    await _ttsService.pause();
  }

  Future<void> updateLanguage(String language) async {
    _language = language;
    await _initializeTts();
  }

  Future<void> updateSpeechRate(double rate) async {
    _speechRate = rate;
    await _initializeTts();
  }

  Future<void> updatePitch(double pitch) async {
    _pitch = pitch;
    await _initializeTts();
  }

  Future<void> updateEasyOcrBaseUrl(String url) async {
    _easyOcrBaseUrl = url;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('easyocr_base_url', _easyOcrBaseUrl);
  }

  Future<void> _loadEasyOcrBaseUrl() async {
    final prefs = await SharedPreferences.getInstance();
    _easyOcrBaseUrl = prefs.getString('easyocr_base_url') ?? _easyOcrBaseUrl;
    notifyListeners();
  }

  Future<String> _extractViaEasyOcr(String imagePath) async {
    final service = EasyOcrService(baseUrl: _easyOcrBaseUrl);
    return service.extractText(imagePath);
  }

  Future<void> _initializeTts() async {
    _isTtsReady = false;
    notifyListeners();

    await _ttsService.initialize(
      language: _language,
      speechRate: _speechRate,
      pitch: _pitch,
      onSpeakingChanged: (isSpeaking) {
        _isSpeaking = isSpeaking;
        notifyListeners();
      },
    );
    _isTtsReady = _ttsService.isReady;
    notifyListeners();
  }

}
