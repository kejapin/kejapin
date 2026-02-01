package handlers

import (
	"github.com/gofiber/fiber/v2"
	"github.com/kejapin/server/internal/core/ports"
)

type AuthHandler struct {
	service ports.AuthService
}

func NewAuthHandler(service ports.AuthService) *AuthHandler {
	return &AuthHandler{service: service}
}

func (h *AuthHandler) Register(c *fiber.Ctx) error {
	type Request struct {
		Email    string `json:"email"`
		Password string `json:"password"`
		Role     string `json:"role"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid request"})
	}

	user, err := h.service.Register(req.Email, req.Password, req.Role)
	if err != nil {
		return c.Status(400).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(user)
}

func (h *AuthHandler) Login(c *fiber.Ctx) error {
	type Request struct {
		Email    string `json:"email"`
		Password string `json:"password"`
	}
	var req Request
	if err := c.BodyParser(&req); err != nil {
		return c.Status(400).JSON(fiber.Map{"error": "invalid request"})
	}

	token, user, err := h.service.Login(req.Email, req.Password)
	if err != nil {
		return c.Status(401).JSON(fiber.Map{"error": err.Error()})
	}

	return c.JSON(fiber.Map{
		"token": token,
		"user":  user,
	})
}

// GetProfile returns the current user profile from the database
func (h *AuthHandler) GetProfile(c *fiber.Ctx) error {
	// This uses the userRepo directly for now since it's just a fetch
	// We'll pass the repo to the handler in main.go
	return nil // To be implemented in main.go if we don't want to change AuthService
}
