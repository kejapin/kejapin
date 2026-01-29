package handlers

import (
	"github.com/gofiber/fiber/v2"
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
