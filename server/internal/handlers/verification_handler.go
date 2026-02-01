package handlers

import (
	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"github.com/kejapin/server/internal/core/domain"
	"github.com/kejapin/server/internal/core/ports"
)

type VerificationHandler struct {
	userRepo ports.UserRepository
}

func NewVerificationHandler(userRepo ports.UserRepository) *VerificationHandler {
	return &VerificationHandler{userRepo: userRepo}
}

func (h *VerificationHandler) SubmitApplication(c *fiber.Ctx) error {
	userIDStr := c.Locals("user_id").(string)
	userID, err := uuid.Parse(userIDStr)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid user ID"})
	}

	var req struct {
		Documents   string `json:"documents"`
		CompanyName string `json:"company_name"`
		CompanyBio  string `json:"company_bio"`
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request body"})
	}

	// 1. Create Application
	app := &domain.RoleApplication{
		UserID:    userID,
		Documents: req.Documents,
		Status:    domain.VStatusPending,
	}

	if err := h.userRepo.CreateApplication(app); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to create application"})
	}

	// 2. Fetch User and Update Role (Auto-Approve for now as requested)
	user, err := h.userRepo.FindByID(userIDStr)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": "User not found"})
	}

	user.Role = domain.RoleLandlord
	user.VStatus = string(domain.VStatusPending)
	user.CompanyName = req.CompanyName
	user.CompanyBio = req.CompanyBio

	if err := h.userRepo.Update(user); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to update user role"})
	}

	return c.JSON(fiber.Map{"message": "Application submitted and role updated successfully"})
}
