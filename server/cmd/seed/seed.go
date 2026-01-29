package main

import (
	"log"

	"time"

	"github.com/google/uuid"
	"github.com/joho/godotenv"
	"github.com/kejapin/server/config"
	"github.com/kejapin/server/internal/core/domain"
	"golang.org/x/crypto/bcrypt"
)

func main() {
	// Load environment variables
	godotenv.Load()

	// Load config and database
	cfg := config.LoadConfig()

	log.Println("Starting database seeding...")

	// Auto Migrate to ensure schema is up to date
	err := cfg.DB.AutoMigrate(&domain.User{}, &domain.Property{}, &domain.Message{}, &domain.Notification{})
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// Hash password for test users
	hashedPassword, _ := bcrypt.GenerateFromPassword([]byte("password123"), bcrypt.DefaultCost)

	// Create sample users (landlords and tenants)
	users := []domain.User{
		{
			ID:           uuid.New(),
			Email:        "landlord1@kejapin.com",
			PasswordHash: string(hashedPassword),
			Role:         domain.RoleLandlord,
			FirstName:    "John",
			LastName:     "Doe",
		},
		{
			ID:           uuid.New(),
			Email:        "landlord2@kejapin.com",
			PasswordHash: string(hashedPassword),
			Role:         domain.RoleLandlord,
			FirstName:    "Jane",
			LastName:     "Smith",
		},
		{
			ID:           uuid.New(),
			Email:        "tenant1@kejapin.com",
			PasswordHash: string(hashedPassword),
			Role:         domain.RoleTenant,
			FirstName:    "Alice",
			LastName:     "Johnson",
		},
	}

	for _, user := range users {
		cfg.DB.Create(&user)
	}
	log.Printf("✅ Created %d users (password: password123)", len(users))

	// Helper to join photos
	joinPhotos := func(photos []string) string {
		return photos[0] // For now, just the main photo to avoid parsing issues if backend isn't ready
	}

	// Create sample properties
	// Use backend proxy for images since bucket is private
	// Using 192.168.100.8 (Server IP)
	baseURL := "http://192.168.100.8:8080/api/uploads/images"

	properties := []domain.Property{
		{
			ID:           uuid.New(),
			Title:        "Luxury Penthouse in Westlands",
			Description:  "Stunning penthouse with panoramic city views, 3 bedrooms, 3 bathrooms, modern finishes, and premium amenities. Perfect for executives and families seeking upscale living.",
			PropertyType: domain.Type2BHK, // Approximate
			ListingType:  domain.ListingRent,
			PriceAmount:  250000.00,
			City:         "Nairobi",
			County:       "Nairobi",
			AddressLine1: "Westlands",
			Latitude:     -1.2667,
			Longitude:    36.8167,
			Photos:       joinPhotos([]string{baseURL + "/property_image_1.jpg"}),
			Bedrooms:     3,
			Bathrooms:    3,
			OwnerID:      users[0].ID,
		},
		{
			ID:           uuid.New(),
			Title:        "Cozy 1BR in Kilimani",
			Description:  "Warm and inviting one-bedroom apartment with modern kitchen, comfortable living space, and great natural lighting. Ideal for young professionals.",
			PropertyType: domain.Type1BHK,
			ListingType:  domain.ListingRent,
			PriceAmount:  45000.00,
			City:         "Nairobi",
			County:       "Nairobi",
			AddressLine1: "Kilimani",
			Latitude:     -1.2921,
			Longitude:    36.7858,
			Photos:       joinPhotos([]string{baseURL + "/property_image_2.jpg"}),
			Bedrooms:     1,
			Bathrooms:    1,
			OwnerID:      users[0].ID,
		},
		{
			ID:           uuid.New(),
			Title:        "Modern Studio in Parklands",
			Description:  "Efficient studio apartment with murphy bed, compact kitchen, and large windows. Perfect for students and young professionals on a budget.",
			PropertyType: domain.TypeBedsitter, // Studio/Bedsitter
			ListingType:  domain.ListingRent,
			PriceAmount:  35000.00,
			City:         "Nairobi",
			County:       "Nairobi",
			AddressLine1: "Parklands",
			Latitude:     -1.2633,
			Longitude:    36.8156,
			Photos:       joinPhotos([]string{baseURL + "/property_image_3.jpg"}),
			Bedrooms:     0,
			Bathrooms:    1,
			OwnerID:      users[1].ID,
		},
		{
			ID:           uuid.New(),
			Title:        "Spacious 2BR Family Home in Lavington",
			Description:  "Beautiful two-bedroom apartment with open plan living, modern fixtures, balcony with city views. Great for small families.",
			PropertyType: domain.Type2BHK,
			ListingType:  domain.ListingRent,
			PriceAmount:  85000.00,
			City:         "Nairobi",
			County:       "Nairobi",
			AddressLine1: "Lavington",
			Latitude:     -1.2780,
			Longitude:    36.7720,
			Photos:       joinPhotos([]string{baseURL + "/property_image_4.jpg"}),
			Bedrooms:     2,
			Bathrooms:    2,
			OwnerID:      users[1].ID,
		},
		{
			ID:           uuid.New(),
			Title:        "Affordable Bedsitter in Kasarani",
			Description:  "Clean and well-maintained bedsitter with kitchenette and private bathroom. Budget-friendly option for singles.",
			PropertyType: domain.TypeBedsitter,
			ListingType:  domain.ListingRent,
			PriceAmount:  15000.00,
			City:         "Nairobi",
			County:       "Nairobi",
			AddressLine1: "Kasarani",
			Latitude:     -1.2189,
			Longitude:    36.8989,
			Photos:       joinPhotos([]string{baseURL + "/property_image_5.jpg"}),
			Bedrooms:     0,
			Bathrooms:    1,
			OwnerID:      users[1].ID,
		},
		{
			ID:           uuid.New(),
			Title:        "Executive Apartment in Riverside",
			Description:  "Premium luxury apartment with floor-to-ceiling windows, hardwood floors, and contemporary furniture. High-end finishes throughout.",
			PropertyType: domain.Type2BHK,
			ListingType:  domain.ListingRent,
			PriceAmount:  120000.00,
			City:         "Nairobi",
			County:       "Nairobi",
			AddressLine1: "Riverside Drive",
			Latitude:     -1.2741,
			Longitude:    36.8070,
			Photos:       joinPhotos([]string{baseURL + "/property_image_6.jpg"}),
			Bedrooms:     2,
			Bathrooms:    2,
			OwnerID:      users[0].ID,
		},
	}

	for _, property := range properties {
		cfg.DB.Create(&property)
	}
	log.Printf("✅ Created %d properties", len(properties))

	// Create sample messages
	propID0 := properties[0].ID.String()
	messages := []domain.Message{
		{
			ID:          uuid.New().String(),
			SenderID:    users[2].ID.String(),
			RecipientID: users[0].ID.String(),
			PropertyID:  &propID0,
			Content:     "Hi, I'm interested in viewing the Luxury Penthouse. Is it still available?",
			IsRead:      false,
			CreatedAt:   time.Now().Add(-time.Hour * 2),
		},
		{
			ID:          uuid.New().String(),
			SenderID:    users[0].ID.String(),
			RecipientID: users[2].ID.String(),
			PropertyID:  &propID0,
			Content:     "Yes, it's available! Would tomorrow at 2 PM work for you?",
			IsRead:      true,
			CreatedAt:   time.Now().Add(-time.Hour * 1),
		},
	}

	for _, message := range messages {
		cfg.DB.Create(&message)
	}
	log.Printf("✅ Created %d messages", len(messages))

	// Create sample notifications
	notifications := []domain.Notification{
		{
			ID:        uuid.New().String(),
			UserID:    users[2].ID.String(),
			Title:     "New Property Match",
			Message:   "A new 2BR apartment in your preferred area was just listed!",
			Type:      domain.NotificationTypeSystem,
			IsRead:    false,
			CreatedAt: time.Now().Add(-time.Hour * 3),
		},
		{
			ID:        uuid.New().String(),
			UserID:    users[2].ID.String(),
			Title:     "Rent Payment Due",
			Message:   "Your rent payment is due in 5 days. Invoice #KJ-882",
			Type:      domain.NotificationTypeFinancial,
			IsRead:    false,
			CreatedAt: time.Now().Add(-time.Hour * 24),
		},
		{
			ID:        uuid.New().String(),
			UserID:    users[0].ID.String(),
			Title:     "New Inquiry",
			Message:   "You have a new inquiry about your Westlands property",
			Type:      domain.NotificationTypeMessage,
			IsRead:    true,
			CreatedAt: time.Now().Add(-time.Hour * 48),
		},
	}

	for _, notification := range notifications {
		cfg.DB.Create(&notification)
	}
	log.Printf("✅ Created %d notifications", len(notifications))

	log.Println("\n🎉 Database seeding completed successfully!")
	log.Println("\nTest Users:")
	log.Println("  - landlord1@kejapin.com (password: password123)")
	log.Println("  - landlord2@kejapin.com (password: password123)")
	log.Println("  - tenant1@kejapin.com (password: password123)")
}
