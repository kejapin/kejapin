@echo off
echo ====================================
echo   Kejapin Phone Development
echo ====================================
echo.

REM Start Go Backend Server
echo Starting Backend Server...
start "Kejapin Backend" cmd /k "cd /d F:\kejapin\server && go run cmd/api/main.go"
timeout /t 3 /nobreak > nul

REM Start Flutter Android App
echo Starting Android App on Phone...
start "Kejapin Android" cmd /k "cd /d F:\kejapin\client && flutter run -d 0N14B07I2310A045"

echo.
echo Backend: http://192.168.100.8:8080 (for phone)
echo.
pause
