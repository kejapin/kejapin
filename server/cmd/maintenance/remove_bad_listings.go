package main

import (
	"log"

	"github.com/joho/godotenv"
	"github.com/kejapin/server/config"
	"github.com/kejapin/server/internal/core/domain"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: Error loading .env file: %v", err)
	}

	// Load config and database
	cfg := config.LoadConfig()

	log.Println("Starting cleanup of bad listings...")

	// Delete properties with the incorrect IP address in photos
	// The bad IP was 192.168.100.9
	result := cfg.DB.Where("photos LIKE ?", "%192.168.100.9%").Delete(&domain.Property{})

	if result.Error != nil {
		log.Fatalf("Failed to delete bad listings: %v", result.Error)
	}

	log.Printf("✅ Successfully removed %d bad listings (containing 192.168.100.9)", result.RowsAffected)

	// Delete properties with direct Backblaze URLs (Private bucket, so client can't access)
	resultB2 := cfg.DB.Where("photos LIKE ?", "%backblazeb2.com%").Delete(&domain.Property{})
	if resultB2.Error != nil {
		log.Fatalf("Failed to delete B2 listings: %v", resultB2.Error)
	}
	log.Printf("✅ Successfully removed %d bad listings (containing backblazeb2.com)", resultB2.RowsAffected)

	// Verify remaining listings
	var count int64
	cfg.DB.Model(&domain.Property{}).Count(&count)
	log.Printf("ℹ️ Remaining listings in database: %d", count)

	var properties []domain.Property
	cfg.DB.Find(&properties)

	log.Println("\n--- Remaining Listings ---")
	for _, p := range properties {
		log.Printf("ID: %s, Photos: %s", p.ID, p.Photos)
	}
}
