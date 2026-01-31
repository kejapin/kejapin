package config

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	"github.com/glebarez/sqlite"
	"github.com/joho/godotenv"
	_ "github.com/tursodatabase/libsql-client-go/libsql"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Config struct {
	DB    *gorm.DB
	GeoDB *sql.DB
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
		log.Fatal("Failed to connect to primary database:", err)
	}

	// Initialize Turso (Geo Data)
	tursoURL := os.Getenv("TURSO_DATABASE_URL")
	tursoToken := os.Getenv("TURSO_AUTH_TOKEN")
	var geoDB *sql.DB

	if tursoURL != "" && tursoToken != "" && tursoToken != "PASTE_NEW_TOKEN_HERE" {
		connStr := fmt.Sprintf("%s?authToken=%s", tursoURL, tursoToken)
		geoDB, err = sql.Open("libsql", connStr)
		if err != nil {
			log.Printf("Warning: Failed to connect to Turso: %v", err)
		} else {
			// Optional: test connection
			err = geoDB.Ping()
			if err != nil {
				log.Printf("Warning: Turso ping failed: %v", err)
			} else {
				log.Println("Successfully connected to Turso Geo database")
			}
		}
	} else {
		log.Println("Warning: Turso credentials missing or invalid in .env. Geo features will rely on APIs.")
	}

	return &Config{
		DB:    db,
		GeoDB: geoDB,
	}
}
