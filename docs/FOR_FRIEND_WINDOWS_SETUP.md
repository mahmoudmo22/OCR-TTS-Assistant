# EasyOCR Server Setup for Windows (Simplified)

Follow these steps to run the OCR server for the Image-to-Speech app on your PC.

### 1. Download & Install Python
*   Go to: [python.org/downloads/windows](https://www.python.org/downloads/windows/)
*   Run the installer.
*   **CRITICAL STEP**: Check the box **"Add Python to PATH"** at the bottom of the installation window before clicking install.

### 2. Download Project Files
*   Get the project ZIP from the repository (or copy it from your friend).
*   Right-click the ZIP -> **Extract All** -> Extract.
*   Open the extracted folder.

### 3. Run the Server
*   Inside the folder, double-click the file named **`run_server.bat`**.
*   A black window will open. It might take a few minutes the first time to install dependencies.
*   Once ready, it will show:
    ```
    YOUR IP ADDRESS:
    IPv4 Address. . . . . . . . . . . : 192.168.1.5
    Server is running on Port 8000.
    ```
*   **Keep this window open.**

### 4. Give the IP to App User
*   Look for the number next to **IPv4 Address** (e.g., `192.168.1.5`).
*   Open the mobile app -> Settings (⚙️).
*   Enter `http://YOUR_IP:8000` (e.g., `http://192.168.1.5:8000`).
*   Save and try capturing an image!

---
**Note:** If the app says "Connection Failed", ensure:
1.  Phone and PC are on the same Wi-Fi.
2.  Windows Firewall allows Python to communicate (click "Allow Access" if prompted).
