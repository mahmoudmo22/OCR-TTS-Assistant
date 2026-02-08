# IoT Image-to-Speech Application

## Final Project Presentation Guide

---

## 📋 Table of Contents

1. [Team Contributions](#team-contributions)
2. [Project Overview](#1-project-overview)
3. [Problem Statement](#2-problem-statement)
4. [Solution Architecture](#3-solution-architecture)
5. [Technology Stack](#4-technology-stack)
6. [System Components](#5-system-components)
7. [Key Code Snippets](#6-key-code-snippets)
8. [Data Flow](#7-data-flow)
9. [Demo Script](#8-demo-script)
10. [Challenges & Solutions](#9-challenges--solutions)
11. [Future Improvements](#10-future-improvements)

---

## 👥 Team Contributions

### Team Member 1: Mobile App UI/UX (Flutter Frontend)

**What I worked on:**

- Designed and implemented all **user interface screens**
- Built the **Home Screen** with real-time camera preview
- Created the **Result Screen** to display OCR text and TTS controls
- Developed the **Settings Screen** for app configuration
- Implemented **permission handling** for camera access

**Files I created/modified:**

| File | Description |
|------|-------------|
| `lib/screens/home_screen.dart` | Camera preview & capture button |
| `lib/screens/result_screen.dart` | Text display & playback controls |
| `lib/screens/settings_screen.dart` | TTS & server configuration |
| `lib/main.dart` | App entry point & theme |

**Key code to show:**

```dart
// home_screen.dart - Camera capture flow
Future<void> _captureAndProcess(AppProvider provider) async {
  final image = await _controller!.takePicture();
  final text = await provider.recognizeText(image.path);
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ResultScreen(imagePath: image.path, extractedText: text),
    ),
  );
}
```

---

### Team Member 2: Mobile App Logic (Flutter Backend Services)

**What I worked on:**

- Implemented **state management** using Provider pattern
- Built the **Text-to-Speech service** with configurable settings
- Created the **Camera service** for device camera handling
- Developed the **EasyOCR client service** for server communication
- Managed **persistent storage** for user settings

**Files I created/modified:**

| File | Description |
|------|-------------|
| `lib/providers/app_provider.dart` | Central state management |
| `lib/services/tts_service.dart` | Text-to-Speech engine wrapper |
| `lib/services/camera_service.dart` | Camera initialization & control |
| `lib/services/easyocr_service.dart` | HTTP client for OCR server |
| `lib/config/app_config.dart` | Default configuration values |

**Key code to show:**

```dart
// tts_service.dart - Text-to-Speech initialization
Future<void> initialize({
  required String language,
  required double speechRate,
  required double pitch,
}) async {
  await _flutterTts.setLanguage(language);
  await _flutterTts.setSpeechRate(speechRate);
  await _flutterTts.setPitch(pitch);
  _isReady = true;
}

// easyocr_service.dart - Server communication
Future<String> extractText(String imagePath) async {
  final request = http.MultipartRequest('POST', Uri.parse('$baseUrl/ocr'))
    ..files.add(await http.MultipartFile.fromPath('file', imagePath));
  final response = await request.send();
  final body = await response.stream.bytesToString();
  return jsonDecode(body)['text'];
}
```

---

### Team Member 3: OCR Server (Python Backend)

**What I worked on:**

- Set up the **Python virtual environment** and dependencies
- Implemented the **FastAPI REST server** for OCR processing
- Integrated **EasyOCR library** for Arabic + English text recognition
- Developed **text sorting algorithm** for correct reading order
- Handled **image preprocessing** and format conversion

**Files I created/modified:**

| File | Description |
|------|-------------|
| `easyocr_server.py` | FastAPI server with OCR endpoint |
| `easyocr_requirements.txt` | Python package dependencies |
| `EASYOCR_PLAN.md` | Server setup documentation |

**Key code to show:**

```python
# easyocr_server.py - OCR processing
from fastapi import FastAPI, File, UploadFile
import easyocr

app = FastAPI()
reader = easyocr.Reader(["ar", "en"], gpu=False)  # Arabic + English

@app.post("/ocr")
async def ocr(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_np = np.array(image)
    
    results = reader.readtext(image_np, detail=1)
    
    # Sort by position (top-to-bottom, left-to-right)
    results.sort(key=lambda item: (
        sum([p[1] for p in item[0]]) / 4,  # Y center
        sum([p[0] for p in item[0]]) / 4   # X center
    ))
    
    text = "\n".join([r[1] for r in results])
    return {"text": text}
```

**Technologies I used:**

- FastAPI (web framework)
- EasyOCR (OCR engine)
- Pillow & NumPy (image processing)
- Uvicorn (ASGI server)

---

### Team Member 4: System Architecture & Integration

**What I worked on:**

- Designed the overall **system architecture** (client-server model)
- Researched and compared **OCR solutions** (ML Kit vs PaddleOCR vs EasyOCR)
- Set up **network communication** between mobile app and server
- Configured **Android build** settings (permissions, ProGuard rules)
- Created **project documentation** and presentation materials
- Conducted **end-to-end testing** on physical devices

**Files I created/modified:**

| File | Description |
|------|-------------|
| `IMPLEMENTATION_PLAN.md` | Project roadmap & milestones |
| `PRESENTATION.md` | This presentation guide |
| `android/app/build.gradle.kts` | Android build configuration |
| `android/app/src/main/AndroidManifest.xml` | App permissions |
| `pubspec.yaml` | Flutter dependencies |

**Key contributions to explain:**

**1. Architecture Decision:**

```
Mobile App ──HTTP POST──▶ Python Server
    │                         │
    │ (image.jpg)            │ (EasyOCR)
    │                         │
    ◀───JSON {"text":...}────┘
```

**2. Why EasyOCR over alternatives:**

| Solution | Arabic Support | Offline | Ease of Use |
|----------|---------------|---------|-------------|
| Google ML Kit | ❌ No | ✅ Yes | ✅ Easy |
| PaddleOCR | ✅ Yes | ✅ Yes | ❌ Complex |
| **EasyOCR** | ✅ Yes | ✅ Yes | ✅ Easy |

**3. Android Configuration:**

```xml
<!-- AndroidManifest.xml - Permissions -->
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## 📊 Work Distribution Summary

| Member | Role | Files | % of Project |
|--------|------|-------|--------------|
| Member 1 | Flutter UI | 4 files | 25% |
| Member 2 | Flutter Services | 5 files | 25% |
| Member 3 | Python Server | 3 files | 25% |
| Member 4 | Architecture & Docs | 5 files | 25% |

---

## 🎤 Presentation Order (Suggested)

| Order | Member | Topic | Duration |
|-------|--------|-------|----------|
| 1 | Member 4 | Intro, Architecture, Problem | 5 min |
| 2 | Member 3 | Python Server & OCR | 5 min |
| 3 | Member 2 | Flutter Services & Logic | 5 min |
| 4 | Member 1 | UI Demo & Walkthrough | 5 min |
| All | Everyone | Q&A | 5 min |

---

## 1. Project Overview

### What is this project?

A **mobile application** that captures images of text (in **English** or **Arabic**), extracts the text using **OCR (Optical Character Recognition)**, and reads it aloud using **Text-to-Speech (TTS)**.

### Key Features

- 📷 **Real-time camera preview** with image capture
- 🔤 **Multilingual OCR** supporting English and Arabic
- 🔊 **Text-to-Speech** with adjustable speed and pitch
- 🌐 **Client-Server Architecture** for powerful OCR processing
- ⚙️ **Configurable settings** for TTS and server connection

### Use Cases

- **Accessibility**: Helping visually impaired users read printed text
- **Language Learning**: Reading foreign text aloud
- **Document Processing**: Quick text extraction from physical documents

---

## 2. Problem Statement

### Original Plan: ESP32-CAM

Initially, the project was designed to use **ESP32-CAM** microcontroller for image capture.

### Challenges with ESP32-CAM

| Issue | Impact |
|-------|--------|
| Low camera quality | Poor OCR accuracy |
| Limited processing power | Cannot run OCR locally |
| No audio output | Requires external speaker module |
| Complex wiring | Difficult to prototype |

### Solution: Flutter Mobile App

We pivoted to a **Flutter mobile application** that leverages:

- High-quality smartphone cameras
- Powerful mobile processors
- Built-in speakers for TTS
- Easy deployment via APK

---

## 3. Solution Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        MOBILE DEVICE                            │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   Camera    │───▶│  Flutter    │───▶│    TTS      │         │
│  │   Service   │    │    App      │    │   Engine    │         │
│  └─────────────┘    └──────┬──────┘    └─────────────┘         │
│                            │                                    │
└────────────────────────────┼────────────────────────────────────┘
                             │ HTTP POST
                             │ (Image)
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│                      PC SERVER (Same Network)                   │
│  ┌─────────────┐    ┌─────────────┐    ┌─────────────┐         │
│  │   FastAPI   │───▶│   EasyOCR   │───▶│   Response  │         │
│  │   Server    │    │   Engine    │    │   (JSON)    │         │
│  └─────────────┘    └─────────────┘    └─────────────┘         │
└─────────────────────────────────────────────────────────────────┘
```

### Communication Protocol

- **Protocol**: HTTP REST API
- **Endpoint**: `POST /ocr`
- **Request**: Multipart form data with image file
- **Response**: JSON with extracted text

---

## 4. Technology Stack

### Mobile App (Flutter)

| Component | Technology | Purpose |
|-----------|------------|---------|
| Framework | Flutter 3.x | Cross-platform UI |
| Language | Dart | App logic |
| State Management | Provider | Reactive state |
| Camera | `camera` package | Image capture |
| HTTP Client | `http` package | Server communication |
| TTS | `flutter_tts` | Speech synthesis |
| Storage | `shared_preferences` | Settings persistence |

### Backend Server (Python)

| Component | Technology | Purpose |
|-----------|------------|---------|
| Framework | FastAPI | REST API server |
| OCR Engine | EasyOCR | Text recognition |
| Server | Uvicorn | ASGI server |
| Image Processing | Pillow, NumPy | Image handling |

### Supported Languages

- **English** (Latin script)
- **Arabic** (RTL script)

---

## 5. System Components

### 5.1 Flutter App Structure

```
iot_tts_app/
├── lib/
│   ├── main.dart                 # App entry point
│   ├── config/
│   │   └── app_config.dart       # Default settings
│   ├── providers/
│   │   └── app_provider.dart     # State management
│   ├── services/
│   │   ├── camera_service.dart   # Camera handling
│   │   ├── easyocr_service.dart  # Server communication
│   │   ├── ocr_service.dart      # ML Kit OCR (backup)
│   │   └── tts_service.dart      # Text-to-Speech
│   └── screens/
│       ├── home_screen.dart      # Camera preview
│       ├── result_screen.dart    # OCR results + TTS
│       └── settings_screen.dart  # App configuration
```

### 5.2 Python Server Structure

```
iot-tts-final-project/
├── easyocr_server.py       # FastAPI server
├── easyocr_requirements.txt # Python dependencies
└── easyocr-env/            # Virtual environment
```

---

## 6. Key Code Snippets

### 6.1 EasyOCR Server (Python)

**File: `easyocr_server.py`**

```python
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import easyocr
import numpy as np
from PIL import Image
import io

app = FastAPI()
reader = easyocr.Reader(["ar", "en"], gpu=False)  # Arabic + English

@app.post("/ocr")
async def ocr(file: UploadFile = File(...)):
    # Read and convert image
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_np = np.array(image)

    # Perform OCR
    results = reader.readtext(image_np, detail=1)

    # Sort results by position (top-to-bottom, left-to-right)
    def sort_key(item):
        bbox = item[0]
        y_center = sum([p[1] for p in bbox]) / 4.0
        x_center = sum([p[0] for p in bbox]) / 4.0
        return (y_center, x_center)

    results.sort(key=sort_key)
    lines = [r[1] for r in results]
    text = "\n".join(lines)

    return JSONResponse({"text": text})
```

**Key Points to Explain:**

- `easyocr.Reader(["ar", "en"])` - Initializes OCR for Arabic and English
- `reader.readtext()` - Extracts text with bounding box coordinates
- Sorting ensures correct reading order (top→bottom, left→right)

---

### 6.2 EasyOCR Service (Flutter)

**File: `lib/services/easyocr_service.dart`**

```dart
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
```

**Key Points to Explain:**

- `MultipartRequest` - Sends image as form data
- Async/await pattern for non-blocking network calls
- JSON parsing for server response

---

### 6.3 Text-to-Speech Service

**File: `lib/services/tts_service.dart`**

```dart
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isReady = false;

  Future<void> initialize({
    required String language,
    required double speechRate,
    required double pitch,
    SpeakingChanged? onSpeakingChanged,
  }) async {
    // Set up event handlers
    _flutterTts.setStartHandler(() => onSpeakingChanged?.call(true));
    _flutterTts.setCompletionHandler(() => onSpeakingChanged?.call(false));

    // Configure TTS
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setPitch(pitch);
    _isReady = true;
  }

  Future<void> speak(String text) async {
    if (!_isReady) return;
    await _flutterTts.speak(text);
  }
}
```

**Key Points to Explain:**

- Uses device's native TTS engine
- Configurable language, speed, and pitch
- Event handlers for UI state updates

---

### 6.4 App State Management (Provider)

**File: `lib/providers/app_provider.dart`**

```dart
class AppProvider extends ChangeNotifier {
  final TtsService _ttsService = TtsService();
  
  bool _isProcessing = false;
  String _easyOcrBaseUrl = 'http://192.168.1.10:8000';

  Future<String> recognizeText(String imagePath) async {
    _isProcessing = true;
    notifyListeners();  // Update UI

    try {
      final service = EasyOcrService(baseUrl: _easyOcrBaseUrl);
      final text = await service.extractText(imagePath);
      return text;
    } finally {
      _isProcessing = false;
      notifyListeners();  // Update UI
    }
  }
}
```

**Key Points to Explain:**

- `ChangeNotifier` pattern for reactive UI updates
- `notifyListeners()` triggers UI rebuild
- Centralized state management

---

### 6.5 Camera Capture Flow

**File: `lib/screens/home_screen.dart`**

```dart
Future<void> _captureAndProcess(AppProvider provider) async {
  // Take picture
  final image = await _controller!.takePicture();
  
  // Send to OCR server and get text
  final text = await provider.recognizeText(image.path);

  // Navigate to results screen
  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ResultScreen(
        imagePath: image.path,
        extractedText: text,
      ),
    ),
  );
}
```

---

## 7. Data Flow

```
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  User    │────▶│  Camera  │────▶│  Image   │────▶│  Server  │
│  Taps    │     │  Capture │     │  File    │     │  Request │
│  Button  │     │          │     │  (.jpg)  │     │  (HTTP)  │
└──────────┘     └──────────┘     └──────────┘     └────┬─────┘
                                                        │
     ┌──────────────────────────────────────────────────┘
     │
     ▼
┌──────────┐     ┌──────────┐     ┌──────────┐     ┌──────────┐
│  EasyOCR │────▶│  Text    │────▶│  JSON    │────▶│  Flutter │
│  Process │     │  Extract │     │  Response│     │  Parse   │
│          │     │          │     │          │     │          │
└──────────┘     └──────────┘     └──────────┘     └────┬─────┘
                                                        │
     ┌──────────────────────────────────────────────────┘
     │
     ▼
┌──────────┐     ┌──────────┐     ┌──────────┐
│  Display │────▶│  User    │────▶│  TTS     │
│  Text    │     │  Taps    │     │  Speaks  │
│          │     │  Play    │     │  Text    │
└──────────┘     └──────────┘     └──────────┘
```

### Timing (Approximate)

| Step | Duration |
|------|----------|
| Image capture | ~100ms |
| Network transfer | ~200-500ms |
| OCR processing | ~1-3 seconds |
| TTS synthesis | ~100ms |
| **Total** | **~2-4 seconds** |

---

## 8. Demo Script

### Setup Before Demo

1. ✅ Start EasyOCR server on PC:

   ```bash
   cd /home/mahmoud/workspaces/iot-tts-final-project
   ./easyocr-env/bin/uvicorn easyocr_server:app --host 0.0.0.0 --port 8000
   ```

2. ✅ Connect phone to same WiFi as PC

3. ✅ Configure server URL in app settings: `http://192.168.1.9:8000`

### Demo Flow (5-7 minutes)

#### Part 1: Show the App (2 min)

1. Open app → Show camera preview
2. Go to Settings → Show configurable options
3. Explain server URL configuration

#### Part 2: English OCR Demo (2 min)

1. Point camera at English text (printed paper/book)
2. Tap "Capture" button
3. Show extracted text on result screen
4. Tap "Speak" to hear TTS output
5. Show server log receiving the request

#### Part 3: Arabic OCR Demo (2 min)

1. Point camera at Arabic text
2. Capture and show extraction
3. Play Arabic TTS (if device supports it)
4. Highlight RTL text handling

#### Part 4: Show Code (optional, 2-3 min)

1. Show `easyocr_server.py` - Server side OCR
2. Show `easyocr_service.dart` - Client communication
3. Show `tts_service.dart` - TTS integration

---

## 9. Challenges & Solutions

### Challenge 1: ESP32-CAM Limitations

| Problem | Solution |
|---------|----------|
| Low camera quality | Used smartphone camera via Flutter |
| No processing power | Offloaded OCR to PC server |
| No audio output | Used phone's built-in TTS |

### Challenge 2: Arabic OCR Support

| Problem | Solution |
|---------|----------|
| Google ML Kit doesn't support Arabic | Switched to EasyOCR |
| Need RTL text handling | Implemented coordinate-based sorting |

### Challenge 3: Text Reading Order

| Problem | Solution |
|---------|----------|
| OCR returns text in random order | Sort by Y-coordinate (top→bottom), then X |
| Multi-column layouts | Use center-point calculation |

### Challenge 4: Network Communication

| Problem | Solution |
|---------|----------|
| Phone and PC need to connect | Use same WiFi network |
| Server URL changes | Made URL configurable in settings |

---

## 10. Future Improvements

### Short-term

- [ ] Add offline OCR fallback (ML Kit for Latin)
- [ ] Support more languages (Chinese, Japanese, etc.)
- [ ] Add image preprocessing (contrast, rotation)

### Long-term

- [ ] Deploy OCR server to cloud (always available)
- [ ] Add batch processing for multiple images
- [ ] Implement document scanning mode
- [ ] Add translation feature

### Hardware Integration (Original IoT Vision)

- [ ] Raspberry Pi server for dedicated OCR processing
- [ ] Bluetooth speaker integration
- [ ] Physical button trigger via IoT device

---

## 📊 Project Summary

| Aspect | Details |
|--------|---------|
| **Platform** | Android (Flutter) |
| **OCR Engine** | EasyOCR (Python) |
| **Languages** | English, Arabic |
| **Architecture** | Client-Server (REST API) |
| **TTS** | Native Android TTS |
| **State Management** | Provider pattern |

### Lines of Code

| Component | LOC |
|-----------|-----|
| Flutter App | ~500 |
| Python Server | ~30 |
| **Total** | ~530 |

---

## 🎯 Key Takeaways

1. **Flexibility in Design**: Pivoting from ESP32-CAM to Flutter improved quality significantly
2. **Client-Server Architecture**: Offloading heavy processing to server enables better results
3. **Multi-language Support**: EasyOCR provides excellent Arabic/English recognition
4. **User Experience**: Real-time camera preview and instant TTS feedback

---

## Questions?

Thank you for your attention! 🙏
