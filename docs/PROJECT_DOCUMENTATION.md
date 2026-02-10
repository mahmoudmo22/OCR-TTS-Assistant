# IoT Image-to-Speech Application - Technical Documentation

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Technology Stack](#technology-stack)
4. [Project Structure](#project-structure)
5. [Main Components](#main-components)
6. [Services Layer](#services-layer)
7. [State Management](#state-management)
8. [UI/Screens](#uiscreens)
9. [Data Flow](#data-flow)
10. [Key Implementation Details](#key-implementation-details)

---

## Project Overview

This is a **Flutter mobile application** that captures images, extracts text using OCR (Optical Character Recognition), and converts the text to speech (TTS). It's designed as an accessibility tool to help users read printed text aloud.

### Core Features
| Feature | Description |
|---------|-------------|
| **Image Capture** | Uses device camera to take photos |
| **OCR Processing** | Extracts text from images via EasyOCR server |
| **Text-to-Speech** | Reads extracted text aloud with configurable voice |
| **Multi-language** | Supports English, Arabic, and French |
| **Settings** | Customizable speech rate, pitch, and server URL |

---

## Architecture

```
┌──────────────────────────────────────────────────────────────────────────────┐
│                           Flutter Mobile App                                  │
├──────────────────────────────────────────────────────────────────────────────┤
│  ┌──────────────┐      ┌──────────────┐      ┌──────────────┐                │
│  │   Camera     │─────▶│   EasyOCR    │─────▶│     TTS      │───▶ Speaker   │
│  │   Capture    │      │   Service    │      │   Engine     │                │
│  └──────────────┘      └──────────────┘      └──────────────┘                │
│         │                     │                    │                          │
│         └─────────────────────┼────────────────────┘                          │
│                               │                                               │
│                      ┌────────▼────────┐                                      │
│                      │   AppProvider   │  (State Management)                  │
│                      └────────┬────────┘                                      │
│                               │                                               │
│    ┌──────────────────────────┼──────────────────────────┐                   │
│    │                          │                          │                    │
│    ▼                          ▼                          ▼                    │
│ HomeScreen               ResultScreen             SettingsScreen              │
│                                                                               │
└──────────────────────────────────────────────────────────────────────────────┘
                                    │
                                    │ HTTP POST /ocr
                                    ▼
┌──────────────────────────────────────────────────────────────────────────────┐
│                        EasyOCR Python Server (FastAPI)                        │
│   - Receives image via multipart form                                         │
│   - Uses EasyOCR library for Arabic + English text recognition               │
│   - Returns extracted text as JSON                                            │
└──────────────────────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

| Component | Technology | Version | Purpose |
|-----------|------------|---------|---------|
| **Framework** | Flutter | 3.38.5 | Cross-platform mobile development |
| **Language** | Dart | 3.10.4 | Programming language |
| **Camera** | `camera` | ^0.11.0 | Device camera access and preview |
| **OCR (Server)** | EasyOCR + FastAPI | - | Arabic + English text recognition |
| **OCR (On-device)** | `google_mlkit_text_recognition` | ^0.14.0 | Backup OCR option |
| **TTS** | `flutter_tts` | ^4.0.2 | Text-to-speech synthesis |
| **State** | `provider` | ^6.1.2 | Reactive state management |
| **Permissions** | `permission_handler` | ^11.3.1 | Runtime permission handling |
| **Storage** | `shared_preferences` | ^2.3.2 | Persisting settings (server URL) |
| **HTTP** | `http` | ^1.6.0 | Network requests to OCR server |

---

## Project Structure

```
iot_tts_app/
├── lib/
│   ├── main.dart                    # App entry point
│   │
│   ├── config/
│   │   └── app_config.dart          # Default settings & constants
│   │
│   ├── providers/
│   │   └── app_provider.dart        # Central state management
│   │
│   ├── services/
│   │   ├── camera_service.dart      # Camera initialization
│   │   ├── easyocr_service.dart     # Remote OCR via HTTP
│   │   ├── ocr_service.dart         # On-device OCR (ML Kit)
│   │   └── tts_service.dart         # Text-to-speech wrapper
│   │
│   └── screens/
│       ├── home_screen.dart         # Camera preview + capture
│       ├── result_screen.dart       # Text display + TTS controls
│       └── settings_screen.dart     # App configuration
│
├── easyocr_server.py                # Python FastAPI OCR server
└── pubspec.yaml                     # Dependencies
```

---

## Main Components

### 1. Entry Point (`main.dart`)

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(),
      child: const MyApp(),
    ),
  );
}
```

**Key Points:**
- `WidgetsFlutterBinding.ensureInitialized()` - Required before using platform channels (camera, TTS)
- Uses `ChangeNotifierProvider` from the `provider` package to inject `AppProvider` into the widget tree
- `MyApp` sets up Material Design with a blueGrey color scheme and Material3

### 2. App Configuration (`app_config.dart`)

```dart
class AppConfig {
  static const String defaultLanguage = 'en-US';
  static const double defaultSpeechRate = 0.5;
  static const double defaultPitch = 1.0;
  static const List<String> supportedLanguages = ['en-US', 'ar-SA', 'fr-FR'];
}
```

**Purpose:** Centralized configuration constants for TTS settings.

---

## Services Layer

### 1. Camera Service (`camera_service.dart`)

**Purpose:** Initializes and manages the device camera.

```dart
class CameraService {
  Future<CameraController> initializeController() async {
    final cameras = await availableCameras();        // Get list of cameras
    final camera = cameras.first;                     // Use back camera
    final controller = CameraController(
      camera,
      ResolutionPreset.medium,                        // Balance quality/speed
      enableAudio: false,                             // No audio needed
    );
    return controller;
  }
}
```

**Key Functions:**
| Function | Description |
|----------|-------------|
| `initializeController()` | Creates and returns a `CameraController` ready for use |

---

### 2. EasyOCR Service (`easyocr_service.dart`)

**Purpose:** Sends captured images to the EasyOCR Python server for text extraction.

```dart
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

**Key Implementation Details:**
1. Uses `http.MultipartRequest` to send the image file
2. Image is sent as `file` parameter to `/ocr` endpoint
3. Server returns JSON: `{"text": "extracted text here"}`
4. Handles errors with status code checking

---

### 3. On-Device OCR Service (`ocr_service.dart`)

**Purpose:** Backup OCR using Google ML Kit (works offline).

```dart
class OcrService {
  final Map<TextRecognitionScript, TextRecognizer> _recognizers = {};

  Future<String> extractText(String imagePath, {required String languageCode}) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final script = _scriptForLanguage(languageCode);
    final recognizer = _getRecognizer(script);
    final recognizedText = await recognizer.processImage(inputImage);
    
    // Sort lines by position...
    return lines.map((line) => line.text).join('\n').trim();
  }
}
```

**Key Features:**
| Feature | Implementation |
|---------|---------------|
| **Caching recognizers** | Uses a Map to avoid recreating TextRecognizer objects |
| **RTL support** | Detects Arabic (`ar`) and sorts text right-to-left |
| **Line ordering** | Sorts text blocks by vertical then horizontal position |

---

### 4. TTS Service (`tts_service.dart`)

**Purpose:** Wraps `flutter_tts` for text-to-speech functionality.

```dart
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

    // Set up callbacks
    _flutterTts.setStartHandler(() => _onSpeakingChanged?.call(true));
    _flutterTts.setCompletionHandler(() => _onSpeakingChanged?.call(false));
    _flutterTts.setCancelHandler(() => _onSpeakingChanged?.call(false));
    _flutterTts.setErrorHandler((_) => _onSpeakingChanged?.call(false));

    await _flutterTts.awaitSpeakCompletion(true);
    await _flutterTts.setLanguage(language);
    await _flutterTts.setSpeechRate(speechRate);
    await _flutterTts.setPitch(pitch);
    _isReady = true;
  }

  Future<void> speak(String text) async { await _flutterTts.speak(text); }
  Future<void> stop() async { await _flutterTts.stop(); }
  Future<void> pause() async { await _flutterTts.pause(); }
}
```

**Key Functions:**
| Function | Description |
|----------|-------------|
| `initialize()` | Configures TTS with language, rate, pitch + sets up callbacks |
| `speak(text)` | Speaks the provided text |
| `stop()` | Stops speech immediately |
| `pause()` | Pauses speech (can be resumed) |

**Callback Pattern:** Uses `SpeakingChanged` typedef to notify the app when speech starts/stops.

---

## State Management

### AppProvider (`app_provider.dart`)

**Purpose:** Central state manager using `ChangeNotifier` pattern.

```dart
class AppProvider extends ChangeNotifier {
  final TtsService _ttsService = TtsService();

  // State variables
  bool _isProcessing = false;     // True during OCR
  bool _isSpeaking = false;       // True during TTS
  bool _isTtsReady = false;       // True when TTS initialized
  String _lastText = '';          // Last extracted text
  String _easyOcrBaseUrl = 'http://192.168.1.10:8000';

  // Settings
  String _language = AppConfig.defaultLanguage;
  double _speechRate = AppConfig.defaultSpeechRate;
  double _pitch = AppConfig.defaultPitch;
}
```

**Key Methods:**

| Method | Description | Notifies Listeners? |
|--------|-------------|---------------------|
| `recognizeText(imagePath)` | Sends image to EasyOCR server | ✅ Yes |
| `speak(text)` | Speaks provided text | No |
| `stop()` | Stops TTS | Via callback |
| `pause()` | Pauses TTS | Via callback |
| `updateLanguage(lang)` | Changes TTS language | ✅ Yes |
| `updateSpeechRate(rate)` | Changes speech speed | ✅ Yes |
| `updatePitch(pitch)` | Changes voice pitch | ✅ Yes |
| `updateEasyOcrBaseUrl(url)` | Saves server URL to SharedPreferences | ✅ Yes |

**OCR Flow:**
```dart
Future<String> recognizeText(String imagePath) async {
  _isProcessing = true;
  notifyListeners();              // UI shows loading spinner

  try {
    final text = await _extractViaEasyOcr(imagePath);
    _lastText = text;
    return text;
  } finally {
    _isProcessing = false;
    notifyListeners();            // UI hides loading spinner
  }
}
```

**Persistence:**
- Uses `SharedPreferences` to save/load `easyocr_base_url`
- Settings persist across app restarts

---

## UI/Screens

### 1. HomeScreen (`home_screen.dart`)

**Purpose:** Camera preview with capture functionality.

**Widget Lifecycle:**
```dart
@override
void initState() {
  super.initState();
  _initializeCamera();  // Request permission + initialize camera
}

@override
void dispose() {
  _controller?.dispose();  // Clean up camera resources
  super.dispose();
}
```

**Key UI Elements:**
```
┌─────────────────────────────────────────────┐
│ AppBar: "Image-to-Speech"     [⚙️ Settings] │
├─────────────────────────────────────────────┤
│                                             │
│                                             │
│           Camera Preview Widget             │
│           (Full screen)                     │
│                                             │
│                                             │
├─────────────────────────────────────────────┤
│        [📷 Capture FAB Button]              │
└─────────────────────────────────────────────┘
```

**Capture Flow:**
```dart
Future<void> _captureAndProcess(AppProvider provider) async {
  if (_controller == null || !_controller!.value.isInitialized) return;
  if (_controller!.value.isTakingPicture) return;

  final image = await _controller!.takePicture();    // 1. Capture image
  final text = await provider.recognizeText(image.path);  // 2. OCR

  await Navigator.of(context).push(
    MaterialPageRoute(
      builder: (_) => ResultScreen(
        imagePath: image.path,
        extractedText: text,                          // 3. Navigate to result
      ),
    ),
  );
}
```

**Permission Handling:**
- Requests camera permission using `permission_handler`
- Shows "Open Settings" button if permission denied

---

### 2. ResultScreen (`result_screen.dart`)

**Purpose:** Displays extracted text with TTS controls.

**UI Layout:**
```
┌─────────────────────────────────────────────┐
│ AppBar: "Result"                [← Back]    │
├─────────────────────────────────────────────┤
│     ┌───────────────────────────────┐       │
│     │     Captured Image            │       │
│     │     (height: 220, rounded)    │       │
│     └───────────────────────────────┘       │
│                                             │
│  "Extracted Text"                           │
│  ┌───────────────────────────────────────┐  │
│  │                                       │  │
│  │   Editable TextField                  │  │
│  │   (maxLines: 8)                       │  │
│  │                                       │  │
│  └───────────────────────────────────────┘  │
│                                             │
│    [▶️ Play]   [⏸️ Pause]   [⏹️ Stop]       │
│                                             │
└─────────────────────────────────────────────┘
```

**Features:**
- **Editable text field**: User can correct OCR mistakes before speaking
- **TTS Controls**: Play, Pause, Stop buttons
- **State-aware buttons**: Disabled/enabled based on `isSpeaking` and `isTtsReady`

---

### 3. SettingsScreen (`settings_screen.dart`)

**Purpose:** Configure app settings.

**Settings Available:**
| Setting | Widget | Range/Values |
|---------|--------|--------------|
| **EasyOCR Server URL** | TextField | HTTP/HTTPS URL |
| **Language** | DropdownButton | en-US, ar-SA, fr-FR |
| **Speech Rate** | Slider | 0.2 - 1.0 |
| **Pitch** | Slider | 0.5 - 2.0 |
| **Test Voice** | Button | Speaks "This is a test of the voice." |

**URL Validation:**
```dart
Future<void> _saveServerUrl(AppProvider provider) async {
  final value = _serverController.text.trim();
  if (!value.startsWith('http://') && !value.startsWith('https://')) {
    setState(() {
      _serverError = 'Server URL must start with http:// or https://';
    });
    return;
  }
  await provider.updateEasyOcrBaseUrl(value);
}
```

---

## Data Flow

### Complete Image-to-Speech Flow

```
User taps "Capture"
        │
        ▼
┌───────────────────────────────────────────────────────────────────────┐
│ 1. HomeScreen._captureAndProcess()                                    │
│    - controller.takePicture() → Returns XFile with image.path        │
└───────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────────────────┐
│ 2. AppProvider.recognizeText(imagePath)                               │
│    - Sets isProcessing = true, notifyListeners()                     │
│    - Calls EasyOcrService.extractText(imagePath)                     │
└───────────────────────────────────────────────────────────────────────┘
        │
        ▼ HTTP POST
┌───────────────────────────────────────────────────────────────────────┐
│ 3. EasyOCR Python Server                                              │
│    - Receives image via multipart form                                │
│    - Runs EasyOCR with Arabic + English readers                       │
│    - Sorts detected text blocks by position                           │
│    - Returns {"text": "..."} JSON                                     │
└───────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────────────────┐
│ 4. Navigate to ResultScreen with extractedText                        │
│    - Displays image and text                                          │
│    - User can edit text if needed                                     │
└───────────────────────────────────────────────────────────────────────┘
        │
        ▼
┌───────────────────────────────────────────────────────────────────────┐
│ 5. User taps "Play" → AppProvider.speak(text)                         │
│    - TtsService.speak(text) → flutter_tts.speak()                    │
│    - Callbacks update isSpeaking state                                │
│    - Audio plays through device speaker                               │
└───────────────────────────────────────────────────────────────────────┘
```

---

## Key Implementation Details

### 1. Why EasyOCR Server Instead of On-Device ML Kit?

| Aspect | EasyOCR (Server) | ML Kit (On-Device) |
|--------|------------------|-------------------|
| **Arabic Support** | ✅ Excellent | ⚠️ Limited script support |
| **Accuracy** | Higher for Arabic | Better for Latin scripts |
| **Speed** | Network dependent | Faster (no network) |
| **Offline** | ❌ Requires server | ✅ Works offline |

**Decision:** EasyOCR was chosen for superior Arabic text recognition.

### 2. Text Sorting Algorithm (OCR)

The EasyOCR server sorts text blocks to maintain reading order:

```python
def sort_key(item):
    bbox = item[0]
    y_center = sum([p[1] for p in bbox]) / 4.0  # Average Y coordinate
    x_center = sum([p[0] for p in bbox]) / 4.0  # Average X coordinate
    return (y_center, x_center)  # Sort by Y first, then X

results.sort(key=sort_key)
```

### 3. RTL Language Handling

On-device OCR handles RTL (Right-to-Left) languages:

```dart
bool _isRtlLanguage(String languageCode) {
  return languageCode.toLowerCase().startsWith('ar');
}

// In sorting logic:
if (isRtl) {
  return bRect.right.compareTo(aRect.right);  // Sort right-to-left
}
return aRect.left.compareTo(bRect.left);      // Sort left-to-right
```

### 4. TTS State Callbacks

The TTS service uses callbacks to track speaking state:

```dart
_flutterTts.setStartHandler(() => _onSpeakingChanged?.call(true));
_flutterTts.setCompletionHandler(() => _onSpeakingChanged?.call(false));
_flutterTts.setCancelHandler(() => _onSpeakingChanged?.call(false));
_flutterTts.setErrorHandler((_) => _onSpeakingChanged?.call(false));
```

This pattern allows UI buttons to enable/disable based on speech state.

### 5. Persisting Server URL

```dart
// Save
final prefs = await SharedPreferences.getInstance();
await prefs.setString('easyocr_base_url', _easyOcrBaseUrl);

// Load
_easyOcrBaseUrl = prefs.getString('easyocr_base_url') ?? _easyOcrBaseUrl;
```

---

## EasyOCR Python Server

**File:** `easyocr_server.py`

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
    # 1. Read image bytes
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_np = np.array(image)

    # 2. Run OCR
    results = reader.readtext(image_np, detail=1)

    # 3. Sort by position (Y then X)
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

**Running the Server:**
```bash
# Activate virtual environment
source easyocr-env/bin/activate

# Install dependencies
pip install -r easyocr_requirements.txt

# Run server
uvicorn easyocr_server:app --host 0.0.0.0 --port 8000
```

---

## Quick Reference: Key Classes & Functions

| Class | File | Key Methods |
|-------|------|-------------|
| `MyApp` | main.dart | Entry point widget |
| `AppConfig` | app_config.dart | Static constants |
| `AppProvider` | app_provider.dart | `recognizeText()`, `speak()`, `stop()` |
| `CameraService` | camera_service.dart | `initializeController()` |
| `EasyOcrService` | easyocr_service.dart | `extractText(imagePath)` |
| `OcrService` | ocr_service.dart | `extractText(imagePath, languageCode)` |
| `TtsService` | tts_service.dart | `initialize()`, `speak()`, `stop()`, `pause()` |
| `HomeScreen` | home_screen.dart | Camera preview + capture |
| `ResultScreen` | result_screen.dart | Text display + TTS controls |
| `SettingsScreen` | settings_screen.dart | App configuration |

---

## Common Interview Questions

1. **How does the OCR work?**
   > Images are sent to a Python server running EasyOCR via HTTP POST. EasyOCR processes Arabic and English text, returns JSON.

2. **Why not use on-device OCR?**
   > Arabic text recognition is better with EasyOCR. We kept ML Kit as a backup for offline use.

3. **How is state managed?**
   > Using `provider` package with `ChangeNotifier`. `AppProvider` is the central state holder.

4. **How do TTS controls work?**
   > Buttons are enabled/disabled based on `isSpeaking` and `isTtsReady` state variables updated via callbacks.

5. **How is the camera handled?**
   > `CameraService` creates a `CameraController`. `HomeScreen` manages its lifecycle (init in `initState`, dispose in `dispose`).

6. **How are settings persisted?**
   > Server URL is saved in `SharedPreferences`. Other settings (language, rate, pitch) stay in memory.
