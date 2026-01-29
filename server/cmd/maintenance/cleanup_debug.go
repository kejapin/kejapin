package main

import (
	"context"
	"fmt"
	"log"
	"os"

	"github.com/joho/godotenv"
	"github.com/kurin/blazer/b2"
)

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Printf("Warning: Error loading .env file: %v", err)
	}

	ctx := context.Background()

	keyID := os.Getenv("B2_APPLICATION_KEY_ID")
	appKey := os.Getenv("B2_APPLICATION_KEY")
	bucketName := os.Getenv("B2_BUCKET_NAME")

	if keyID == "" || appKey == "" || bucketName == "" {
		log.Fatal("B2 credentials not configured")
	}

	client, err := b2.NewClient(ctx, keyID, appKey)
	if err != nil {
		log.Fatalf("failed to create B2 client: %v", err)
	}

	bucket, err := client.Bucket(ctx, bucketName)
	if err != nil {
		log.Fatalf("failed to get bucket: %v", err)
	}

	filesToDelete := []string{
		"debug_compressed.jpg",
		"debug_uncompressed.jpg",
	}

	fmt.Printf("Cleaning up debug files from bucket: %s\n", bucketName)

	for _, filename := range filesToDelete {
		obj := bucket.Object(filename)
		fmt.Printf("Deleting %s... ", filename)
		if err := obj.Delete(ctx); err != nil {
			log.Printf("Failed: %v\n", err)
		} else {
			fmt.Println("Done.")
		}
	}

	fmt.Println("Cleanup completed.")
}
