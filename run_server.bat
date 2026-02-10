@echo off
TITLE EasyOCR Server Runner

echo ===================================================
echo      Setting up Python Environment...
echo ===================================================

:: Check if Python is installed
python --version >nul 2>&1
IF %ERRORLEVEL% NEQ 0 (
    echo Python is not installed or not in PATH.
    echo Please install Python from https://www.python.org/downloads/windows/
    echo ensuring you check "Add Python to PATH" during installation.
    pause
    exit /b
)

:: Create virtual environment if it doesn't exist
IF NOT EXIST "venv" (
    echo Creating virtual environment (venv)...
    python -m venv venv
)

:: Activate virtual environment
call venv\Scripts\activate

echo.
echo ===================================================
echo      Installing Dependencies...
echo ===================================================
pip install -r easyocr_requirements.txt

echo.
echo ===================================================
echo      Starting Server...
echo ===================================================
echo.
echo YOUR IP ADDRESS (Look for IPv4 Address):
ipconfig | findstr "IPv4"
echo.
echo ---------------------------------------------------
echo Server will run on Port 8000.
echo Enter http://<YOUR_IP>:8000 in the App Settings.
echo Press CTRL+C to stop.
echo ---------------------------------------------------

uvicorn easyocr_server:app --host 0.0.0.0 --port 8000

pause
