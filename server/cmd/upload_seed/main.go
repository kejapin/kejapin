package main

import (
	"context"
	"fmt"
	"io"
	"log"
	"net/http"

	"github.com/joho/godotenv"
	"github.com/kejapin/server/internal/storage"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: Error loading .env file: %v", err)
	}

	// Initialize B2 storage
	b2Storage, err := storage.NewB2Storage()
	if err != nil {
		log.Fatalf("Failed to initialize B2 storage: %v", err)
	}

	// Sample images to download and upload
	imageUrls := []string{
		"https://images.unsplash.com/photo-1560448204-e02f11c3d0e2",    // Luxury Penthouse
		"https://images.unsplash.com/photo-1522708323590-d24dbb6b0267", // Cozy 1BR
		"https://images.unsplash.com/photo-1502672260266-1c1ef2d93688", // Studio
		"https://images.unsplash.com/photo-1600596542815-ffad4c1539a9", // 2BR Family
		"https://images.unsplash.com/photo-1556912173-3bb406ef7e77",    // Bedsitter
		"https://images.unsplash.com/photo-1600607687939-ce8a6c25118c", // Executive
	}

	var uploadedUrls []string

	fmt.Println("🚀 Starting image upload process...")

	for i, url := range imageUrls {
		fmt.Printf("Processing image %d/%d...\n", i+1, len(imageUrls))

		// 1. Download image
		resp, err := http.Get(url)
		if err != nil {
			log.Printf("Failed to download image %s: %v", url, err)
			continue
		}
		defer resp.Body.Close()

		data, err := io.ReadAll(resp.Body)
		if err != nil {
			log.Printf("Failed to read image body: %v", err)
			continue
		}

		// 2. Upload to B2
		fileName := fmt.Sprintf("property_image_%d.jpg", i+1)
		contentType := "image/jpeg"

		uploadedUrl, err := b2Storage.UploadFile(context.Background(), data, fileName, contentType)
		if err != nil {
			log.Printf("Failed to upload to B2: %v", err)
			continue
		}

		fmt.Printf("✅ Uploaded: %s\n", uploadedUrl)
		uploadedUrls = append(uploadedUrls, uploadedUrl)
	}

	fmt.Println("\n🎉 All images uploaded successfully!")
	fmt.Println("Copy these URLs to your seed script:")
	for _, url := range uploadedUrls {
		fmt.Println(url)
	}
}
