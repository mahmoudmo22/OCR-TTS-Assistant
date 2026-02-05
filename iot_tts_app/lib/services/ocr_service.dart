import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    final lines = <TextLine>[];

    for (final block in recognizedText.blocks) {
      lines.addAll(block.lines);
    }

    if (lines.isEmpty) {
      return recognizedText.text.trim();
    }

    lines.sort((a, b) {
      final aRect = a.boundingBox;
      final bRect = b.boundingBox;
      final verticalDelta = (aRect.top - bRect.top).abs();
      if (verticalDelta > 8) {
        return aRect.top.compareTo(bRect.top);
      }
      return aRect.left.compareTo(bRect.left);
    });

    return lines.map((line) => line.text).join('\n').trim();
  }

  Future<void> dispose() async {
    await _textRecognizer.close();
  }
}
