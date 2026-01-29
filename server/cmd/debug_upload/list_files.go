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

	fmt.Printf("Checking Bucket: %s\n", bucketName)
	fmt.Printf("Key ID: %s\n", keyID)

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

	fmt.Println("\n--- Files in Bucket ---")
	count := 0
	iterator := bucket.List(ctx)
	for iterator.Next() {
		obj := iterator.Object()
		attrs, err := obj.Attrs(ctx)
		if err != nil {
			fmt.Printf("- %s (Error getting attrs: %v)\n", obj.Name(), err)
		} else {
			fmt.Printf("- %s (Size: %d bytes)\n", obj.Name(), attrs.Size)
		}
		count++
	}

	if err := iterator.Err(); err != nil {
		log.Fatalf("Error listing bucket: %v", err)
	}

	if count == 0 {
		fmt.Println("No files found in the bucket.")
	} else {
		fmt.Printf("\nTotal files: %d\n", count)
	}
}
