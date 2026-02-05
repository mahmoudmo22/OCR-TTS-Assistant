import 'dart:convert';

import 'package:http/http.dart' as http;

class EasyOcrService {
  final String baseUrl;

  EasyOcrService({required this.baseUrl});

  Future<String> extractText(String imagePath) async {
    final uri = Uri.parse('$baseUrl/ocr');
    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imagePath));

    final response = await request.send();
    if (response.statusCode != 200) {
      throw Exception('OCR failed: ${response.statusCode}');
    }

    final body = await response.stream.bytesToString();
    final decoded = jsonDecode(body) as Map<String, dynamic>;
    return (decoded['text'] as String?)?.trim() ?? '';
  }
}
