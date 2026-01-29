@echo off
echo ====================================
echo   Stop All Kejapin Processes
echo ====================================
echo.

echo Stopping Flutter processes...
taskkill /F /FI "WINDOWTITLE eq Kejapin*" /T 2>nul

echo Stopping Go backend...
FOR /F "tokens=5" %%P IN ('netstat -a -n -o ^| findstr :8080') DO TaskKill /F /PID %%P 2>nul

echo Stopping Chrome on port 8082...
FOR /F "tokens=5" %%P IN ('netstat -a -n -o ^| findstr :8082') DO TaskKill /F /PID %%P 2>nul

echo.
echo All processes stopped.
echo.
pause
