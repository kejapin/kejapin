package handlers

import (
	"time"

	"github.com/kejapin/server/internal/core/domain"
	"github.com/kejapin/server/internal/repositories"

	"github.com/gofiber/fiber/v2"
)

type MessagingHandler struct {
	MsgRepo   *repositories.MessageRepository
	NotifRepo *repositories.NotificationRepository
}

func NewMessagingHandler(msgRepo *repositories.MessageRepository, notifRepo *repositories.NotificationRepository) *MessagingHandler {
	return &MessagingHandler{
		MsgRepo:   msgRepo,
		NotifRepo: notifRepo,
	}
}

func (h *MessagingHandler) GetMessages(c *fiber.Ctx) error {
	userID := c.Locals("userID").(string)
	messages, err := h.MsgRepo.GetMessagesForUser(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch messages"})
	}
	return c.JSON(fiber.Map{"status": "success", "data": messages})
}

func (h *MessagingHandler) SendMessage(c *fiber.Ctx) error {
	userID := c.Locals("userID").(string)
	var req struct {
		RecipientID string  `json:"recipient_id"`
		Content     string  `json:"content"`
		PropertyID  *string `json:"property_id"`
	}

	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": "Invalid request"})
	}

	msg := &domain.Message{
		SenderID:    userID,
		RecipientID: req.RecipientID,
		Content:     req.Content,
		PropertyID:  req.PropertyID,
		CreatedAt:   time.Now(),
	}

	if err := h.MsgRepo.CreateMessage(msg); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to send message"})
	}

	// Create a notification for the recipient
	notif := &domain.Notification{
		UserID:    req.RecipientID,
		Title:     "New Message",
		Message:   "You have a new message",
		Type:      domain.NotificationTypeMessage,
		CreatedAt: time.Now(),
	}
	h.NotifRepo.CreateNotification(notif)

	// TODO: Publish to Centrifugo here

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{"status": "success", "data": msg})
}

func (h *MessagingHandler) GetNotifications(c *fiber.Ctx) error {
	userID := c.Locals("userID").(string)
	notifications, err := h.NotifRepo.GetNotificationsForUser(userID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": "Failed to fetch notifications"})
	}
	return c.JSON(fiber.Map{"status": "success", "data": notifications})
}
