package main

import (
	"log"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/kejapin/server/config"
	"github.com/kejapin/server/internal/core/domain"
	"github.com/kejapin/server/internal/handlers"
	"github.com/kejapin/server/internal/repositories"
	"github.com/kejapin/server/internal/services"
	"github.com/kejapin/server/internal/storage"
)

func main() {
	// Load Config & DB
	cfg := config.LoadConfig()

	// Auto Migrate with logging
	log.Println("Starting database migrations...")
	err := cfg.DB.AutoMigrate(&domain.User{}, &domain.Property{}, &domain.Message{}, &domain.Notification{}, &domain.LifePin{}, &domain.RoleApplication{}, &domain.Review{})
	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// Verify tables exist
	var tableCount int64
	cfg.DB.Raw("SELECT COUNT(*) FROM sqlite_master WHERE type='table' AND name='users'").Scan(&tableCount)
	log.Printf("Users table exists: %v\n", tableCount > 0)

	log.Println("Database migrations completed successfully")

	// Initialize Repos & Services
	userRepo := repositories.NewUserRepository(cfg.DB)
	propertyRepo := repositories.NewPropertyRepository(cfg.DB)
	msgRepo := repositories.NewMessageRepository(cfg.DB)
	notifRepo := repositories.NewNotificationRepository(cfg.DB)
	lifePinRepo := repositories.NewLifePinRepository(cfg.DB)
	geoRepo := repositories.NewGeoRepository(cfg.GeoDB)

	authService := services.NewAuthService(userRepo)
	marketplaceService := services.NewMarketplaceService(propertyRepo)
	geoService := services.NewGeoService("", geoRepo) // Use default OSRM URL

	authHandler := handlers.NewAuthHandler(authService)
	marketplaceHandler := handlers.NewMarketplaceHandler(marketplaceService)
	messagingHandler := handlers.NewMessagingHandler(msgRepo, notifRepo)
	geoHandler := handlers.NewGeoHandler(lifePinRepo, geoService)
	verificationHandler := handlers.NewVerificationHandler(userRepo)

	// Initialize Storage
	b2Storage, err := storage.NewB2Storage()
	if err != nil {
		log.Printf("Warning: Failed to initialize B2 storage: %v", err)
	}
	uploadHandler := handlers.NewUploadHandler(b2Storage)

	// Setup Fiber
	app := fiber.New()
	app.Use(logger.New())
	app.Use(cors.New())

	// Routes
	authMiddleware := func(c *fiber.Ctx) error {
		userID := c.Get("X-User-ID")
		if userID == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{"error": "Unauthorized"})
		}
		c.Locals("user_id", userID)
		return c.Next()
	}

	api := app.Group("/api")

	api.Get("/health", func(c *fiber.Ctx) error {
		return c.JSON(fiber.Map{"status": "ok"})
	})

	auth := api.Group("/auth")
	auth.Post("/register", authHandler.Register)
	auth.Post("/login", authHandler.Login)
	auth.Get("/profile", authMiddleware, func(c *fiber.Ctx) error {
		userID := c.Locals("user_id").(string)
		user, err := userRepo.FindByID(userID)
		if err != nil {
			return c.Status(404).JSON(fiber.Map{"error": "user not found"})
		}
		return c.JSON(user)
	})

	marketplace := api.Group("/marketplace")
	marketplace.Get("/listings", marketplaceHandler.GetListings)
	marketplace.Post("/listings", authMiddleware, marketplaceHandler.CreateListing)
	marketplace.Post("/reviews", authMiddleware, marketplaceHandler.SubmitReview)

	// Uploads & Images
	uploads := api.Group("/uploads")
	uploads.Post("/image", uploadHandler.UploadImage)
	uploads.Post("/images", uploadHandler.UploadMultipleImages)
	uploads.Get("/images/:filename", uploadHandler.ServeImage)

	messaging := api.Group("/messaging")
	messaging.Use(authMiddleware)
	messaging.Get("/messages", messagingHandler.GetMessages)
	messaging.Post("/messages", messagingHandler.SendMessage)
	messaging.Get("/notifications", messagingHandler.GetNotifications)

	// Geo & Life Pins
	geo := api.Group("/geo")
	geo.Post("/commute", geoHandler.CalculateCommute)
	geo.Get("/search", geoHandler.SearchLocations)
	geo.Post("/nearby", geoHandler.GetNearbyAmenities)

	lifePins := api.Group("/lifepins")
	lifePins.Use(authMiddleware)
	lifePins.Post("/", geoHandler.CreateLifePin)
	lifePins.Get("/", geoHandler.GetLifePins)
	lifePins.Delete("/:id", geoHandler.DeleteLifePin)

	verification := api.Group("/verification")
	verification.Use(authMiddleware)
	verification.Post("/apply", verificationHandler.SubmitApplication)

	log.Fatal(app.Listen(":8080"))
}
