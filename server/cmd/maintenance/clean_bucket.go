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

	fmt.Printf("Cleaning bucket: %s\n", bucketName)

	// List all files
	iterator := bucket.List(ctx)
	for iterator.Next() {
		obj := iterator.Object()
		fmt.Printf("Deleting %s...\n", obj.Name())
		if err := obj.Delete(ctx); err != nil {
			log.Printf("Failed to delete %s: %v", obj.Name(), err)
		} else {
			fmt.Println("Deleted.")
		}
	}

	if err := iterator.Err(); err != nil {
		log.Fatalf("Error listing bucket: %v", err)
	}

	fmt.Println("Bucket cleaning completed.")
}
