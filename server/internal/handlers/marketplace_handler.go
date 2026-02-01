package handlers

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/kejapin/server/internal/core/domain"
	"github.com/kejapin/server/internal/core/ports"
)

type MarketplaceHandler struct {
	service ports.MarketplaceService
}

func NewMarketplaceHandler(service ports.MarketplaceService) *MarketplaceHandler {
	return &MarketplaceHandler{service: service}
}

func (h *MarketplaceHandler) GetListings(c *fiber.Ctx) error {
	filters := make(map[string]interface{})

	if val := c.Query("listing_type"); val != "" {
		filters["listing_type"] = val
	}
	if val := c.Query("property_type"); val != "" {
		filters["property_type"] = val
	}

	listings, err := h.service.GetListings(filters)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"status":  "error",
			"message": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"status": "success",
		"data":   listings,
	})
}

func (h *MarketplaceHandler) CreateListing(c *fiber.Ctx) error {
	userIDStr := c.Locals("user_id").(string)
	ownerID, _ := uuid.Parse(userIDStr)

	var property domain.Property
	if err := c.BodyParser(&property); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	property.OwnerID = ownerID
	if err := h.service.CreateListing(&property); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create listing"})
	}

	return c.JSON(fiber.Map{"status": "success", "data": property})
}

func (h *MarketplaceHandler) SubmitReview(c *fiber.Ctx) error {
	userIDStr := c.Locals("user_id").(string)
	userID, _ := uuid.Parse(userIDStr)

	var review domain.Review
	if err := c.BodyParser(&review); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	review.UserID = userID
	if err := h.service.SubmitReview(&review); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to submit review"})
	}

	return c.JSON(fiber.Map{"status": "success", "message": "Review submitted"})
}
