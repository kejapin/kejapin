# kejapin

## Project Structure
- `server`: Go backend (Fiber + GORM)
- `client`: Flutter frontend

## Running the Project

### Backend
1. Navigate to `server` directory.
2. Run `go mod tidy` to install dependencies.
3. Run `go run ./cmd/api/main.go` to start the server.
   - The server will run on `http://localhost:8080`.
   - It uses SQLite (`kejapin.db`) by default.

### Frontend
1. Navigate to `client` directory.
2. Run `flutter pub get` to install dependencies.
3. Run `flutter run` to start the app.

## Features Implemented
- **Backend**:
  - User Domain & Repository
  - Auth Service (Register/Login with JWT)
  - SQLite Database Support
- **Frontend**:
  - Splash Screen
  - Onboarding Screen
  - Login & Register Screens
  - Theme & Routing
