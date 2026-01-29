package main

import (
	"fmt"

	"github.com/joho/godotenv"
	"github.com/kejapin/server/config"
	"github.com/kejapin/server/internal/core/domain"
)

func main() {
	godotenv.Load()
	cfg := config.LoadConfig()

	var count int64
	cfg.DB.Model(&domain.Property{}).Count(&count)
	fmt.Printf("Total properties in DB: %d\n", count)

	var properties []domain.Property
	cfg.DB.Find(&properties)
	for _, p := range properties {
		fmt.Printf("- %s (Type: %s, Listing: %s)\n", p.Title, p.PropertyType, p.ListingType)
	}
}
