package handlers

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/kejapin/server/internal/core/domain"
	"github.com/kejapin/server/internal/repositories"
	"github.com/kejapin/server/internal/services"
)

type GeoHandler struct {
	Repo       *repositories.LifePinRepository
	GeoService *services.GeoService
}

func NewGeoHandler(repo *repositories.LifePinRepository, geoService *services.GeoService) *GeoHandler {
	return &GeoHandler{Repo: repo, GeoService: geoService}
}

func (h *GeoHandler) CreateLifePin(c *fiber.Ctx) error {
	var pin domain.LifePin
	if err := c.BodyParser(&pin); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid input"})
	}

	// Get UserID from context (assuming auth middleware sets it)
	userIDStr := c.Locals("user_id").(string)
	userID, _ := uuid.Parse(userIDStr)
	pin.UserID = userID

	if err := h.Repo.Create(&pin); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create pin"})
	}

	return c.Status(fiber.StatusCreated).JSON(pin)
}

func (h *GeoHandler) GetLifePins(c *fiber.Ctx) error {
	userIDStr := c.Locals("user_id").(string)
	userID, _ := uuid.Parse(userIDStr)

	pins, err := h.Repo.GetByUserID(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch pins"})
	}

	return c.JSON(pins)
}

func (h *GeoHandler) DeleteLifePin(c *fiber.Ctx) error {
	idStr := c.Params("id")
	id, err := uuid.Parse(idStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid ID"})
	}

	userIDStr := c.Locals("user_id").(string)
	userID, _ := uuid.Parse(userIDStr)

	if err := h.Repo.Delete(id, userID); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to delete pin"})
	}

	return c.SendStatus(fiber.StatusNoContent)
}

func (h *GeoHandler) CalculateCommute(c *fiber.Ctx) error {
	var req domain.CommuteRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid input"})
	}

	resp, err := h.GeoService.CalculateCommute(req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(resp)
}

func (h *GeoHandler) SearchLocations(c *fiber.Ctx) error {
	query := c.Query("query")
	if query == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Query is required"})
	}

	results, err := h.GeoService.SearchLocations(query, 10)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(results)
}

func (h *GeoHandler) GetNearbyAmenities(c *fiber.Ctx) error {
	var req struct {
		Lat    float64 `json:"lat"`
		Lon    float64 `json:"lon"`
		Radius float64 `json:"radius"`
	}
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid input"})
	}

	results, err := h.GeoService.GetNearbyAmenities(req.Lat, req.Lon, req.Radius)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(results)
}
