# Image-to-Speech Flutter App - Implementation Plan

## Project Overview

This Flutter app replaces the ESP32-CAM based system with a mobile application that:

1. Captures images using the device camera
2. Extracts text from images using on-device OCR (Google ML Kit)
3. Converts extracted text to speech
4. Plays audio through the device speaker

**Key Benefits:**

- Works completely offline (no internet required after installation)
- Cross-platform (Android + iOS)
- Better camera quality than ESP32-CAM
- Built-in speaker, no external hardware needed

---

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                      Flutter App                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐             │
│   │  Camera  │───▶│   OCR    │───▶│   TTS    │──▶ Speaker  │
│   │ Capture  │    │ (ML Kit) │    │ Engine   │             │
│   └──────────┘    └──────────┘    └──────────┘             │
│        │                │               │                   │
│        └────────────────┴───────────────┘                   │
│                         │                                   │
│                    ┌────▼────┐                              │
│                    │   UI    │                              │
│                    │ Screens │                              │
│                    └─────────┘                              │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Technology Stack

| Component | Package/Technology | Version | Purpose |
|-----------|-------------------|---------|---------|
| Framework | Flutter | 3.38.5 | Cross-platform mobile development |
| Camera | `camera` | ^0.11.0 | Camera access and preview |
| OCR | `google_mlkit_text_recognition` | ^0.14.0 | On-device text extraction |
| TTS | `flutter_tts` | ^4.0.2 | Text-to-speech conversion |
| State Management | `provider` | ^6.1.2 | App state management |
| Permissions | `permission_handler` | ^11.3.1 | Runtime permissions |

---

## Part 1: Development Environment Setup

### 1.1 Verify Flutter Installation

Your current setup:

- ✅ Flutter 3.38.5 (stable)
- ✅ Android toolchain ready
- ✅ Dart 3.10.4
- ✅ 2 connected devices

### 1.2 VSCode Extensions (Recommended)

Make sure these extensions are installed in VSCode:

1. **Flutter** (Dart-Code.flutter) - Essential for Flutter development
2. **Dart** (Dart-Code.dart-code) - Dart language support
3. **Flutter Widget Snippets** - Helpful code snippets
4. **Error Lens** - Inline error display

To check/install:

```bash
code --list-extensions | grep -i flutter
code --list-extensions | grep -i dart
```

Install if missing:

```bash
code --install-extension Dart-Code.flutter
code --install-extension Dart-Code.dart-code
```

### 1.3 Android Device Setup

For testing on a physical Android device:

1. Enable **Developer Options** on your phone:
   - Go to Settings > About Phone
   - Tap "Build Number" 7 times

2. Enable **USB Debugging**:
   - Settings > Developer Options > USB Debugging

3. Connect phone via USB and verify:

   ```bash
   flutter devices
   ```

### 1.4 iOS Setup (if needed)

For iOS development, you need:

- macOS with Xcode installed
- Apple Developer account (for physical device testing)
- CocoaPods: `sudo gem install cocoapods`

---

## Part 2: Project Structure

```
iot_tts_app/
├── android/                    # Android-specific configuration
├── ios/                        # iOS-specific configuration
├── lib/
│   ├── main.dart              # App entry point
│   │
│   ├── config/
│   │   └── app_config.dart    # App configuration constants
│   │
│   ├── models/
│   │   └── scan_result.dart   # Data model for OCR results
│   │
│   ├── services/
│   │   ├── camera_service.dart    # Camera initialization & capture
│   │   ├── ocr_service.dart       # ML Kit text recognition
│   │   └── tts_service.dart       # Text-to-speech functionality
│   │
│   ├── providers/
│   │   └── app_provider.dart      # State management
│   │
│   ├── screens/
│   │   ├── home_screen.dart       # Main camera view
│   │   ├── result_screen.dart     # Text display & TTS controls
│   │   └── settings_screen.dart   # App settings
│   │
│   └── widgets/
│       ├── camera_preview.dart    # Camera preview widget
│       ├── capture_button.dart    # Capture button
│       └── tts_controls.dart      # Play/Pause/Stop controls
│
├── assets/                    # App assets (icons, etc.)
├── test/                      # Unit tests
├── pubspec.yaml              # Dependencies
└── README.md                 # Project documentation
```

---

## Part 3: Implementation Steps

### Step 3.1: Create Flutter Project

```bash
cd /home/mahmoud/workspaces/iot-tts-final-project
flutter create iot_tts_app --org com.iot.tts
cd iot_tts_app
```

### Step 3.2: Add Dependencies

Update `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Camera
  camera: ^0.11.0
  
  # OCR - Google ML Kit
  google_mlkit_text_recognition: ^0.14.0
  
  # Text-to-Speech
  flutter_tts: ^4.0.2
  
  # State Management
  provider: ^6.1.2
  
  # Permissions
  permission_handler: ^11.3.1
  
  # Image handling
  image_picker: ^1.1.2
  path_provider: ^2.1.4

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0
```

Install dependencies:

```bash
flutter pub get
```

### Step 3.3: Configure Android Permissions

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- Camera permission -->
    <uses-permission android:name="android.permission.CAMERA"/>
    <uses-feature android:name="android.hardware.camera" android:required="true"/>
    
    <!-- For TTS -->
    <uses-permission android:name="android.permission.INTERNET"/>
    
    <application
        android:label="IOT TTS"
        android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- ... rest of application config ... -->
    </application>
</manifest>
```

Set minimum SDK version in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdk = 21  // Required for ML Kit
        targetSdk = 34
    }
}
```

### Step 3.4: Configure iOS Permissions

Edit `ios/Runner/Info.plist`:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to capture images for text recognition</string>
<key>NSSpeechRecognitionUsageDescription</key>
<string>This app uses speech synthesis to read text aloud</string>
```

### Step 3.5: Implement Services

#### OCR Service (`lib/services/ocr_service.dart`)

- Initialize `TextRecognizer` from ML Kit
- Process image and extract `RecognizedText`
- Return plain text string

#### TTS Service (`lib/services/tts_service.dart`)

- Initialize `FlutterTts`
- Configure language, speech rate, pitch
- Implement `speak()`, `pause()`, `stop()` methods
- Handle completion callbacks

#### Camera Service (`lib/services/camera_service.dart`)

- Initialize available cameras
- Create `CameraController`
- Handle capture and return image path

### Step 3.6: Build UI Screens

#### Home Screen

- Full-screen camera preview
- Large circular capture button at bottom
- Settings icon in app bar
- Gallery picker option

#### Result Screen

- Display captured image (thumbnail)
- Show extracted text in scrollable container
- Edit text option (manual corrections)
- TTS Controls: Play, Pause, Stop buttons
- Speech progress indicator
- "Capture Another" button

#### Settings Screen

- Language selection dropdown
- Speech rate slider (0.5x - 2.0x)
- Pitch slider
- Test voice button

---

## Part 4: Key Code Components

### 4.1 OCR Service Implementation

```dart
import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _textRecognizer = TextRecognizer();

  Future<String> extractText(String imagePath) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return recognizedText.text;
  }

  void dispose() {
    _textRecognizer.close();
  }
}
```

### 4.2 TTS Service Implementation

```dart
import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _flutterTts = FlutterTts();
  
  Future<void> initialize() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setPitch(1.0);
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
```

### 4.3 Main App Structure

```dart
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider()),
      ],
      child: const MyApp(),
    ),
  );
}
```

---

## Part 5: Testing Plan

### 5.1 Unit Tests

- OCR service: Test text extraction with sample images
- TTS service: Test initialization and configuration

### 5.2 Manual Testing Checklist

- [ ] Camera preview displays correctly
- [ ] Image capture works
- [ ] OCR extracts text accurately from printed text
- [ ] TTS speaks extracted text clearly
- [ ] Play/Pause/Stop controls work
- [ ] Settings persist across app restarts
- [ ] App works offline (airplane mode)

### 5.3 Test Images

Prepare test images with:

- Clear printed text
- Different font sizes
- Multiple languages (if needed)
- Various lighting conditions

---

## Part 6: Timeline Estimate

| Task | Estimated Time |
|------|---------------|
| Project setup & dependencies | 30 minutes |
| Camera service implementation | 1-2 hours |
| OCR service implementation | 1 hour |
| TTS service implementation | 1 hour |
| Home screen UI | 2-3 hours |
| Result screen UI | 2-3 hours |
| Settings screen | 1-2 hours |
| Testing & bug fixes | 2-3 hours |
| **Total** | **10-15 hours** |

---

## Part 7: Future Enhancements (Optional)

These can be added later if time permits:

1. **Language Detection & Translation**
   - Auto-detect source language
   - Translate to target language before TTS

2. **History/Saved Scans**
   - Save captured images and extracted text
   - Browse previous scans

3. **Batch Processing**
   - Process multiple images
   - Combine text from multiple pages

4. **Accessibility Features**
   - Voice commands for hands-free operation
   - High contrast mode
   - Larger touch targets

---

## Commands Quick Reference

```bash
# Create project
flutter create iot_tts_app --org com.iot.tts

# Get dependencies
flutter pub get

# Run on connected device
flutter run

# Run on specific device
flutter run -d <device_id>

# List available devices
flutter devices

# Build APK
flutter build apk --release

# Build iOS
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze
```

---

## Resources

- [Flutter Camera Package](https://pub.dev/packages/camera)
- [Google ML Kit Text Recognition](https://pub.dev/packages/google_mlkit_text_recognition)
- [Flutter TTS](https://pub.dev/packages/flutter_tts)
- [Flutter Provider](https://pub.dev/packages/provider)
- [Flutter Documentation](https://docs.flutter.dev/)
