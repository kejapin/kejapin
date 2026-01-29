# Kejapin Launcher Scripts

This directory contains several batch scripts to quickly start the kejapin application in different configurations.

## Available Scripts

### 🚀 `start-all.bat` - Full Multi-Platform Launch
**What it does:**
- Starts Go backend server (port 8080)
- Launches web app in Chrome (port 8082)
- Builds and runs Windows desktop app
- Builds and runs Android app on connected phone (device: 0N14B07I2310A045)

**When to use:**
- Full testing across all platforms
- Demonstrating the app
- Comprehensive development session

**Usage:**
```batch
start-all.bat
```

---

### 🌐 `start-web.bat` - Web Development (Recommended)
**What it does:**
- Starts Go backend server
- Launches web app in Chrome only

**When to use:**
- Quick development iterations
- Web-focused development
- Fastest startup time

**Usage:**
```batch
start-web.bat
```

---

### 📱 `start-phone.bat` - Mobile Development
**What it does:**
- Starts Go backend server
- Builds and runs Android app on phone

**When to use:**
- Mobile-specific features
- Testing on real device
- Android debugging

**Usage:**
```batch
start-phone.bat
```

**Note:** Ensure your phone is connected via USB and has USB debugging enabled.

---

### 🛑 `stop-all.bat` - Stop All Processes
**What it does:**
- Stops all Flutter processes
- Kills Go backend server
- Closes Chrome web app

**When to use:**
- Clean shutdown of all services
- Before starting fresh
- Cleanup after testing

**Usage:**
```batch
stop-all.bat
```

---

## Quick Start Guide

### First Time Setup
1. Ensure you have:
   - Go installed and in PATH
   - Flutter installed and in PATH
   - Phone connected (for mobile development)
   - Chrome installed (for web development)

2. Double-click your preferred script
3. Wait for all services to start (check console windows)
4. Access the app:
   - **Web**: http://localhost:8082
   - **API**: http://localhost:8080
   - **Phone**: App automatically launches
   - **Windows**: App window opens

### Development Workflow

**For Web Development (Fastest):**
```batch
1. Run: start-web.bat
2. Edit code in VS Code
3. Hot reload automatically applies changes
4. When done: stop-all.bat
```

**For Full Platform Testing:**
```batch
1. Run: start-all.bat
2. Test across all platforms simultaneously
3. When done: stop-all.bat
```

**For Mobile Debugging:**
```batch
1. Connect phone via USB
2. Run: start-phone.bat
3. Debug with Chrome DevTools
4. When done: stop-all.bat
```

---

## Troubleshooting

### Port Already in Use
If you get "port already in use" errors:
```batch
stop-all.bat
```
Then try starting again.

### Phone Not Detected
```batch
# Check connected devices
flutter devices

# If not showing, enable USB debugging on phone
# Settings > Developer Options > USB Debugging
```

### Go Module Errors
```batch
cd server
go mod tidy
go run cmd/api/main.go
```

### Flutter Build Errors
```batch
cd client
flutter clean
flutter pub get
```

---

## Console Windows

Each script opens separate console windows:
- **Kejapin Backend (Go)** - Backend server logs
- **Kejapin Web (Chrome)** - Web app build/run logs
- **Kejapin Windows App** - Desktop app logs
- **Kejapin Android (Phone)** - Mobile app logs

**Tip:** Keep these windows open to see real-time logs and errors.

---

## Environment Variables

### Backend API URL
The client automatically detects platform:
- **Web**: http://localhost:8080/api
- **Mobile**: http://192.168.100.8:8080/api (WiFi IP)

Edit `client/lib/core/constants/api_endpoints.dart` to change.

### Ports
- Backend: `:8080`
- Web: `:8082`

Edit scripts to change ports if needed.

---

## Performance Tips

1. **For fastest iteration:** Use `start-web.bat`
2. **Close unused apps:** Better CPU/memory usage
3. **Use hot reload:** Don't restart unless necessary
4. **Monitor logs:** Watch console windows for errors

---

## Safety

All scripts use `/k` flag to keep windows open after completion.
This allows you to see errors and logs.

To run silently (auto-close on success), change `/k` to `/c` in the scripts.

---

**Created for kejapin development** 
Version: 1.0.0
