@echo off
echo ====================================
echo    Kejapin Multi-Platform Launcher
echo ====================================
echo.
echo Starting all servers and building apps...
echo.

REM Start Go Backend Server
echo [1/4] Starting Go Backend Server...
start "Kejapin Backend (Go)" cmd /k "cd /d F:\kejapin\server && go run cmd/api/main.go"
timeout /t 3 /nobreak > nul

REM Start Flutter Web App (Chrome)
echo [2/4] Starting Web App in Chrome...
start "Kejapin Web (Chrome)" cmd /k "cd /d F:\kejapin\client && flutter run -d chrome --web-port=8082"
timeout /t 2 /nobreak > nul

REM Start Flutter Windows App
echo [3/4] Building and Running Windows App...
start "Kejapin Windows App" cmd /k "cd /d F:\kejapin\client && flutter run -d windows"
timeout /t 2 /nobreak > nul

REM Start Flutter Android App on Phone
echo [4/4] Building and Running Android App on Phone...
start "Kejapin Android (Phone)" cmd /k "cd /d F:\kejapin\client && flutter run -d 0N14B07I2310A045"

echo.
echo ====================================
echo All processes started successfully!
echo ====================================
echo.
echo Backend API: http://localhost:8080
echo Web App: http://localhost:8082
echo.
echo Press any key to exit this launcher...
pause > nul
