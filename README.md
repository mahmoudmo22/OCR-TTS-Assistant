# OCR-TTS-Assistant 📱👁️🔊

**IoT Image-to-Speech Application**

A powerful Flutter-based mobile application that captures images, extracts text using a dedicated Python/EasyOCR server, and converts specific text to speech. This project is designed as an accessibility tool to assist users in reading printed text aloud, supporting multiple languages including **Arabic**, **English**, and **French**.

## 🚀 Features

*   **📸 Image Capture**: Use the device camera to take photos of documents or signs.
*   **📝 Advanced OCR**: Extracts text using the `EasyOCR` library (running on a Python backend) for high accuracy, especially with Arabic script.
*   **🗣️ Text-to-Speech**: Configurable voice, speech rate, and pitch.
*   **🌍 Multi-language Support**: Seamlessly switch between English, Arabic, and French.
*   **🔧 Customizable**: Configure the backend server URL and audio settings dynamically.

---

## 🛠️ Tech Stack

*   **Frontend (Mobile)**: Flutter (Dart)
*   **Backend (OCR Engine)**: Python, FastAPI, EasyOCR, PyTorch
*   **Communication**: HTTP (REST API)

---

## 💻 Installation & Setup Guide (Windows)

Follow these steps to set up the project on a Windows machine.

### Prerequisites

1.  **Python 3.8+**: [Download Here](https://www.python.org/downloads/windows/) (Ensure you check "Add Python to PATH" during installation).
2.  **Flutter SDK**: [Installation Guide](https://docs.flutter.dev/get-started/install/windows).
3.  **Git**: [Download Git](https://git-scm.com/download/win).
4.  **Android Studio** (for Android Emulator) or a physical Android device.

---

### Step 1: Clone the Repository

Open **Command Prompt (cmd)** or **PowerShell** and run:

```powershell
git clone https://github.com/mahmoudmo22/OCR-TTS-Assistant.git
cd OCR-TTS-Assistant
```

---

### Step 2: Backend Server Setup (Python)

The backend processes images and creates the text. It must be running on your PC.

1.  **Create a Virtual Environment** (Recommended):
    ```powershell
    python -m venv venv
    ```

2.  **Activate the Environment**:
    ```powershell
    .\venv\Scripts\activate
    ```
    *(You will see `(venv)` appear at the start of your command line)*

3.  **Install Dependencies**:
    ```powershell
    pip install -r easyocr_requirements.txt
    ```
    *(Note: This installs FastAPI, Uvicorn, EasyOCR, and PyTorch. It may take a few minutes).*

4.  **Start the Server**:
    ```powershell
    uvicorn easyocr_server:app --host 0.0.0.0 --port 8000
    ```

5.  **Get Your Local IP Address**:
    *   Open a new terminal window.
    *   Run: `ipconfig`
    *   Look for **IPv4 Address** under your Wi-Fi or Ethernet adapter (e.g., `192.168.1.5`).
    *   **Write this down!** You will need it to connect the mobile app.

---

### Step 3: Mobile App Setup (Flutter)

1.  **Navigate to the App Directory**:
    (In a new terminal window, inside the project folder)
    ```powershell
    cd iot_tts_app
    ```

2.  **Install Flutter Packages**:
    ```powershell
    flutter pub get
    ```

3.  **Run the App**:
    *   Connect your Android phone via USB (ensure USB Debugging is on) OR launch an Android Emulator.
    *   Run:
    ```powershell
    flutter run
    ```

---

### Step 4: Connecting the App

1.  When the app opens, tap the **Settings** icon (⚙️) in the top-right corner.
2.  In the **Server URL** field, enter your PC's IP address formatted like this:
    ```
    http://<YOUR_IP_ADDRESS>:8000
    ```
    *Example:* `http://192.168.1.5:8000`
3.  Tap the **Save** icon or go back.
4.  You are ready! Capture an image to hear it read aloud.

---

## 📂 Project Structure

```
OCR-TTS-Assistant/
├── easyocr_server.py        # Python FastAPI Server (OCR Engine)
├── easyocr_requirements.txt # Python dependencies
├── iot_tts_app/             # Flutter Mobile Application
│   ├── lib/
│   │   ├── main.dart        # Entry point
│   │   ├── screens/         # UI Screens (Home, Result, Settings)
│   │   ├── services/        # Logic (Camera, OCR, TTS)
│   │   └── providers/       # State Management
│   └── pubspec.yaml         # Flutter dependencies
└── PROJECT_DOCUMENTATION.md # Technical documentation
```

## ⚠️ Troubleshooting

*   **"Connection Refused" Error**:
    *   Ensure your Phone and PC are on the **same Wi-Fi network**.
    *   Ensure the Python server is running (`uvicorn ...`).
    *   Check your Windows Firewall settings (allow Python/Uvicorn through public/private networks).
*   **Flutter "No devices found"**:
    *   Run `flutter devices` to check connectivity.
    *   Ensure USB Debugging is enabled on your phone.

---

**Developed by Mahmoud Mohamed**
