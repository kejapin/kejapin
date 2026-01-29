@echo off
echo ====================================
echo   Kejapin Quick Start (Web Only)
echo ====================================
echo.

REM Start Go Backend Server
echo Starting Backend Server...
start "Kejapin Backend" cmd /k "cd /d F:\kejapin\server && go run cmd/api/main.go"
timeout /t 3 /nobreak > nul

REM Start Flutter Web App
echo Starting Web App...
start "Kejapin Web" cmd /k "cd /d F:\kejapin\client && flutter run -d chrome --web-port=8082"

echo.
echo Backend: http://localhost:8080
echo Web App: http://localhost:8082
echo.
pause
