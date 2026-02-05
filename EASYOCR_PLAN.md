# EasyOCR Integration Plan (PC Server + Flutter Client)

This plan documents how to use EasyOCR on a PC (server) and have the Flutter app send images for OCR. This avoids Google billing and works well for Arabic + English.

---

## 1) High-Level Architecture

1. Flutter app captures an image.
2. App sends the image to a local EasyOCR server over Wi‑Fi.
3. Server returns extracted text (ordered lines).
4. App reads it with TTS as before.

---

## 2) EasyOCR Server Setup (Friend’s PC)

These steps are for Windows / Linux / macOS. Choose the correct OS section.

### 2.1 Requirements

- Python 3.9+ (recommended 3.10 or 3.11)
- Internet to install packages (first time only)

### 2.2 Create a virtual environment (recommended)

**Windows (PowerShell):**

```
python -m venv easyocr-env
easyocr-env\Scripts\Activate.ps1
```

**Linux/macOS:**

```
python3 -m venv easyocr-env
source easyocr-env/bin/activate
```

### 2.3 Install dependencies

```
pip install easyocr fastapi uvicorn pillow python-multipart
```

> Note: EasyOCR will download its models on first run.

### 2.4 Create the server

Create a file named `easyocr_server.py` with this content:

```python
from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
import easyocr
import numpy as np
from PIL import Image
import io

app = FastAPI()
reader = easyocr.Reader(['ar', 'en'], gpu=False)  # set gpu=True if you have CUDA

@app.post("/ocr")
async def ocr(file: UploadFile = File(...)):
    image_bytes = await file.read()
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_np = np.array(image)

    # EasyOCR returns list of (bbox, text, confidence)
    results = reader.readtext(image_np, detail=1)

    # Sort by vertical position (top->bottom), then horizontal (left->right)
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

### 2.5 Run the server

```
uvicorn easyocr_server:app --host 0.0.0.0 --port 8000
```

### 2.6 Find your PC IP address

**Windows:**

```
ipconfig
```

Look for `IPv4 Address`, e.g. `192.168.1.25`

**Linux/macOS:**

```
ip a
```

or

```
ifconfig
```

### 2.7 Test the server (optional)

From another device on the same Wi‑Fi:

```
curl -X POST -F "file=@sample.jpg" http://PC_IP:8000/ocr
```

---

## 3) Flutter App Changes (Client Side)

### 3.1 Add HTTP dependency

Add to `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.6.0
```

### 3.2 Add an OCR service for EasyOCR

Create `lib/services/easyocr_service.dart`:

```dart
import 'dart:io';
import 'package:http/http.dart' as http;

class EasyOcrService {
  final String baseUrl; // example: http://192.168.1.25:8000

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
    final text = RegExp(r'"text"\s*:\s*"([^"]*)"')
        .firstMatch(body)
        ?.group(1)
        ?.replaceAll('\\n', '\n') ?? '';
    return text;
  }
}
```

### 3.3 Replace the current OCR call

In your `AppProvider`, replace the current OCR call to use `EasyOcrService` instead of ML Kit.

---

## 4) Network Requirements

- **Phone and PC must be on the same Wi‑Fi**.
- Use the PC’s LAN IP (not `localhost`).
- Keep the server running while testing.

---

## 5) How Your Friend Tests It

1. Run the EasyOCR server on his PC (`uvicorn ...`).
2. Send you his PC IP address.
3. You put that IP in the Flutter app (base URL).
4. Build the APK and send it to him.
5. He runs the app on Android; OCR results come from his PC server.

---

## 6) Next Step (If You Want Me to Implement)

If you want me to wire this into the Flutter app:

- tell me the desired **server base URL** (or if it should be a setting screen)
- I’ll add the HTTP dependency + new service + hook it into the existing flow
