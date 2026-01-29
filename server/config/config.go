package config

import (
	"log"
	"os"

	"github.com/glebarez/sqlite"
	"github.com/joho/godotenv"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Config struct {
	DB *gorm.DB
}

func LoadConfig() *Config {
	err := godotenv.Load()
	if err != nil {
		log.Println("Warning: .env file not found")
	}

	dbType := os.Getenv("DB_TYPE")
	var db *gorm.DB

	if dbType == "postgres" {
		dsn := os.Getenv("DB_DSN")
		db, err = gorm.Open(postgres.Open(dsn), &gorm.Config{})
	} else {
		// Default to SQLite
		db, err = gorm.Open(sqlite.Open("kejapin.db"), &gorm.Config{})
	}

	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	return &Config{
		DB: db,
	}
}
