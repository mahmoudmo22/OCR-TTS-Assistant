import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final Map<TextRecognitionScript, TextRecognizer> _recognizers = {};

  TextRecognizer _getRecognizer(TextRecognitionScript script) {
    return _recognizers.putIfAbsent(
      script,
      () => TextRecognizer(script: script),
    );
  }

  Future<String> extractText(
    String imagePath, {
    required String languageCode,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final script = _scriptForLanguage(languageCode);
    final recognizer = _getRecognizer(script);
    final recognizedText = await recognizer.processImage(inputImage);
    final lines = <TextLine>[];

    for (final block in recognizedText.blocks) {
      lines.addAll(block.lines);
    }

    if (lines.isEmpty) {
      return recognizedText.text.trim();
    }

    final isRtl = _isRtlLanguage(languageCode);
    final averageHeight = lines
            .map((line) => line.boundingBox.height)
            .fold<double>(0, (sum, height) => sum + height) /
        lines.length;
    final rowThreshold = averageHeight > 0 ? averageHeight * 0.3 : 8.0;

    lines.sort((a, b) {
      final aRect = a.boundingBox;
      final bRect = b.boundingBox;
      final aCenterY = aRect.top + aRect.height / 2;
      final bCenterY = bRect.top + bRect.height / 2;
      final verticalDelta = (aCenterY - bCenterY).abs();
      if (verticalDelta > rowThreshold) {
        return aCenterY.compareTo(bCenterY);
      }
      if (isRtl) {
        return bRect.right.compareTo(aRect.right);
      }
      return aRect.left.compareTo(bRect.left);
    });

    return lines.map((line) => line.text).join('\n').trim();
  }

  bool _isRtlLanguage(String languageCode) {
    return languageCode.toLowerCase().startsWith('ar');
  }

  TextRecognitionScript _scriptForLanguage(String languageCode) {
    return TextRecognitionScript.latin;
  }

  Future<void> dispose() async {
    for (final recognizer in _recognizers.values) {
      await recognizer.close();
    }
    _recognizers.clear();
  }
}
