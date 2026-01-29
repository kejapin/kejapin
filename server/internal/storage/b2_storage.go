package storage

import (
	"context"
	"fmt"
	"io"
	"log"
	"os"
	"path/filepath"
	"time"

	"github.com/kurin/blazer/b2"
)

type B2Storage struct {
	client *b2.Client
	bucket *b2.Bucket
}

func NewB2Storage() (*B2Storage, error) {
	ctx := context.Background()

	keyID := os.Getenv("B2_APPLICATION_KEY_ID")
	appKey := os.Getenv("B2_APPLICATION_KEY")
	bucketName := os.Getenv("B2_BUCKET_NAME")

	if keyID == "" || appKey == "" || bucketName == "" {
		return nil, fmt.Errorf("B2 credentials not configured")
	}

	client, err := b2.NewClient(ctx, keyID, appKey)
	if err != nil {
		return nil, fmt.Errorf("failed to create B2 client: %w", err)
	}

	// Try to find the bucket by name or ID
	buckets, err := client.ListBuckets(ctx)
	if err != nil {
		return nil, fmt.Errorf("failed to list buckets: %w", err)
	}

	var targetBucket *b2.Bucket
	for _, b := range buckets {
		if b.Name() == bucketName {
			targetBucket = b
			break
		}
	}

	if targetBucket == nil {
		// Debug: Print available buckets
		var available []string
		for _, b := range buckets {
			available = append(available, b.Name())
		}
		log.Printf("Debug: Available buckets: %v", available)

		// If we couldn't find it by listing (maybe pagination?), try direct access again or error out
		// But let's try one more time with the name directly, maybe it's a permissions issue with listing
		b, err := client.Bucket(ctx, bucketName)
		if err != nil {
			return nil, fmt.Errorf("bucket '%s' not found (and listing failed to find it). Available: %v. Error: %w", bucketName, available, err)
		}
		targetBucket = b
	}

	return &B2Storage{
		client: client,
		bucket: targetBucket,
	}, nil
}

// UploadFile uploads a file to B2 without Gzip compression
func (s *B2Storage) UploadFile(ctx context.Context, data []byte, fileName string, contentType string) (string, error) {
	// Create the file object in B2
	obj := s.bucket.Object(fileName)

	// Write the data
	writer := obj.NewWriter(ctx)

	// Try to set content info if possible
	// In some versions: writer.ContentType = contentType

	if _, err := writer.Write(data); err != nil {
		writer.Close()
		return "", fmt.Errorf("failed to write to B2: %w", err)
	}

	if err := writer.Close(); err != nil {
		return "", fmt.Errorf("failed to close writer: %w", err)
	}

	// Return the file URL
	fileURL := fmt.Sprintf("https://f005.backblazeb2.com/file/%s/%s", s.bucket.Name(), fileName)
	return fileURL, nil
}

// DownloadFile downloads a file from B2
func (s *B2Storage) DownloadFile(ctx context.Context, fileName string) ([]byte, error) {
	obj := s.bucket.Object(fileName)
	reader := obj.NewReader(ctx)
	defer reader.Close()

	data, err := io.ReadAll(reader)
	if err != nil {
		return nil, fmt.Errorf("failed to read from B2: %w", err)
	}

	return data, nil
}

// DeleteFile deletes a file from B2
func (s *B2Storage) DeleteFile(ctx context.Context, fileName string) error {
	obj := s.bucket.Object(fileName)
	return obj.Delete(ctx)
}

// GenerateFileName generates a unique filename with extension
func GenerateFileName(originalName string) string {
	ext := filepath.Ext(originalName)
	name := fmt.Sprintf("%d%s", time.Now().UnixNano(), ext)
	return name
}
