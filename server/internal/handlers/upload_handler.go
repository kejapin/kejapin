package handlers

import (
	"bytes"
	"context"
	"fmt"
	"image"
	"image/jpeg"
	"image/png"
	"io"
	"path/filepath"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/kejapin/server/internal/storage"
	"github.com/nfnt/resize"
	"golang.org/x/image/webp"
)

type UploadHandler struct {
	storage *storage.B2Storage
}

func NewUploadHandler(storage *storage.B2Storage) *UploadHandler {
	return &UploadHandler{storage: storage}
}

// compressImage compresses and resizes images to optimize storage and bandwidth
func compressImage(data []byte, contentType string) ([]byte, error) {
	// Decode image based on content type
	var img image.Image
	var err error

	reader := bytes.NewReader(data)
	switch contentType {
	case "image/jpeg":
		img, err = jpeg.Decode(reader)
	case "image/png":
		img, err = png.Decode(reader)
	case "image/webp":
		img, err = webp.Decode(reader)
	default:
		return data, nil // Return original if unknown type
	}

	if err != nil {
		return nil, fmt.Errorf("failed to decode image: %w", err)
	}

	// Get original dimensions
	bounds := img.Bounds()
	width := bounds.Max.X
	height := bounds.Max.Y

	// Resize if image is too large (max 1920px width)
	maxWidth := uint(1920)
	if width > int(maxWidth) {
		// Calculate proportional height
		ratio := float64(maxWidth) / float64(width)
		newHeight := uint(float64(height) * ratio)
		img = resize.Resize(maxWidth, newHeight, img, resize.Lanczos3)
	}

	// Encode to JPEG with quality 85 (good balance between quality and size)
	var buf bytes.Buffer
	err = jpeg.Encode(&buf, img, &jpeg.Options{Quality: 85})
	if err != nil {
		return nil, fmt.Errorf("failed to encode compressed image: %w", err)
	}

	return buf.Bytes(), nil
}

// UploadImage handles image upload with compression
func (h *UploadHandler) UploadImage(c *fiber.Ctx) error {
	// Get the file from multipart form
	file, err := c.FormFile("file")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "No file uploaded",
		})
	}

	// Validate file type
	contentType := file.Header.Get("Content-Type")

	if contentType != "image/jpeg" && contentType != "image/png" && contentType != "image/webp" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Only JPEG, PNG, and WebP images are allowed",
		})
	}

	// Open the file
	fileHandle, err := file.Open()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to open file",
		})
	}
	defer fileHandle.Close()

	// Read file data
	fileData, err := io.ReadAll(fileHandle)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to read file",
		})
	}

	originalSize := len(fileData)

	// Compress the image
	compressedData, err := compressImage(fileData, contentType)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to compress image: " + err.Error(),
		})
	}

	compressedSize := len(compressedData)
	compressionRatio := float64(originalSize-compressedSize) / float64(originalSize) * 100

	// Generate unique filename (always save as .jpg after compression)
	fileName := fmt.Sprintf("properties/%d.jpg", time.Now().UnixNano())

	// Upload to B2
	ctx := context.Background()
	fileURL, err := h.storage.UploadFile(ctx, compressedData, fileName, "image/jpeg")
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to upload file: " + err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"file_url":          fileURL,
			"file_name":         fileName,
			"original_size":     originalSize,
			"compressed_size":   compressedSize,
			"compression_ratio": fmt.Sprintf("%.1f%%", compressionRatio),
		},
	})
}

// UploadMultipleImages handles multiple image uploads with compression
func (h *UploadHandler) UploadMultipleImages(c *fiber.Ctx) error {
	form, err := c.MultipartForm()
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid multipart form",
		})
	}

	files := form.File["files"]
	if len(files) == 0 {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "No files uploaded",
		})
	}

	var uploadedFiles []fiber.Map
	ctx := context.Background()

	for _, file := range files {
		// Validate file type
		contentType := file.Header.Get("Content-Type")
		if contentType != "image/jpeg" && contentType != "image/png" && contentType != "image/webp" {
			continue // Skip non-image files
		}

		// Open file
		fileHandle, err := file.Open()
		if err != nil {
			continue
		}

		// Read data
		fileData, err := io.ReadAll(fileHandle)
		fileHandle.Close()
		if err != nil {
			continue
		}

		// Compress
		compressedData, err := compressImage(fileData, contentType)
		if err != nil {
			continue
		}

		// Generate filename
		fileName := fmt.Sprintf("properties/%d.jpg", time.Now().UnixNano())

		// Upload
		fileURL, err := h.storage.UploadFile(ctx, compressedData, fileName, "image/jpeg")
		if err != nil {
			continue
		}

		uploadedFiles = append(uploadedFiles, fiber.Map{
			"file_url":  fileURL,
			"file_name": fileName,
		})

		// Small delay to ensure unique filenames
		time.Sleep(time.Millisecond * 10)
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"status": "success",
		"data": fiber.Map{
			"files": uploadedFiles,
			"count": len(uploadedFiles),
		},
	})
}

// ServeImage serves an image from B2
func (h *UploadHandler) ServeImage(c *fiber.Ctx) error {
	filename := c.Params("filename")
	if filename == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Filename is required",
		})
	}

	ctx := context.Background()
	data, err := h.storage.DownloadFile(ctx, filename)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "File not found",
		})
	}

	// Determine content type based on extension
	ext := filepath.Ext(filename)
	contentType := "application/octet-stream"
	switch ext {
	case ".jpg", ".jpeg":
		contentType = "image/jpeg"
	case ".png":
		contentType = "image/png"
	case ".webp":
		contentType = "image/webp"
	}

	c.Set("Content-Type", contentType)
	return c.Send(data)
}
