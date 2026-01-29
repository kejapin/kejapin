@echo off
start cmd /k "cd server && go run ./cmd/api/main.go"
start cmd /k "cd client && flutter run"
