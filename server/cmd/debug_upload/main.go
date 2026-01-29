package main

import (
	"bytes"
	"compress/gzip"
	"context"
	"fmt"
	"io"
	"log"
	"net/http"
	"os"
	"path/filepath"

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

	// 1. Get a fresh image (simulating "generation")
	// Using a reliable Unsplash source for a "Modern Apartment"
	imageUrl := "https://images.unsplash.com/photo-1502672260266-1c1ef2d93688"
	fmt.Println("⬇️ Downloading fresh image...")

	resp, err := http.Get(imageUrl)
	if err != nil {
		log.Fatalf("Failed to download image: %v", err)
	}
	defer resp.Body.Close()

	imageData, err := io.ReadAll(resp.Body)
	if err != nil {
		log.Fatalf("Failed to read image data: %v", err)
	}

	// 2. Save locally to assets folder
	localPath := filepath.Join("..", "client", "assets", "images", "debug_test.jpg")
	// Ensure directory exists (relative to where we run this, which will be server root)
	// Actually we are running from server root, so path is ../client...
	// Let's use absolute path logic or just relative to CWD

	// If running from f:\kejapin\server:
	localPath = "../client/assets/images/debug_test.jpg"

	err = os.WriteFile(localPath, imageData, 0644)
	if err != nil {
		log.Printf("Failed to save local file (check path): %v", err)
		// Try absolute path fallback if relative fails
		err = os.WriteFile("debug_test.jpg", imageData, 0644)
		if err == nil {
			fmt.Println("✅ Saved local copy to server/debug_test.jpg (could not save to client assets)")
		}
	} else {
		fmt.Printf("✅ Saved local copy to %s\n", localPath)
	}

	ctx := context.Background()

	// 3. Upload UNCOMPRESSED (Bypassing compression)
	// This uses the current B2Storage implementation which we stripped of compression
	fmt.Println("📤 Uploading UNCOMPRESSED version...")
	uncompressedName := "debug_uncompressed.jpg"
	urlUncompressed, err := b2Storage.UploadFile(ctx, imageData, uncompressedName, "image/jpeg")
	if err != nil {
		log.Fatalf("Failed to upload uncompressed: %v", err)
	}
	fmt.Printf("✅ Uncompressed URL: %s\n", urlUncompressed)

	// 4. Upload COMPRESSED (Simulating the issue)
	fmt.Println("📦 Compressing and uploading version...")
	var buf bytes.Buffer
	gzipWriter := gzip.NewWriter(&buf)
	if _, err := gzipWriter.Write(imageData); err != nil {
		log.Fatalf("Failed to compress: %v", err)
	}
	if err := gzipWriter.Close(); err != nil {
		log.Fatalf("Failed to close gzip writer: %v", err)
	}
	compressedData := buf.Bytes()

	compressedName := "debug_compressed.jpg"
	// We pass "image/jpeg" but the content is actually gzipped
	urlCompressed, err := b2Storage.UploadFile(ctx, compressedData, compressedName, "image/jpeg")
	if err != nil {
		log.Fatalf("Failed to upload compressed: %v", err)
	}
	fmt.Printf("✅ Compressed URL: %s\n", urlCompressed)

	fmt.Println("\n--- SUMMARY ---")
	fmt.Println("1. Local File: Check client/assets/images/debug_test.jpg")
	fmt.Println("2. Uncompressed (Should Work):", urlUncompressed)
	fmt.Println("3. Compressed (Should Fail):", urlCompressed)
}
