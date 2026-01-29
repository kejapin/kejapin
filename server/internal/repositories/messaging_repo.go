package repositories

import (
	"github.com/kejapin/server/internal/core/domain"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type MessageRepository struct {
	db *gorm.DB
}

func NewMessageRepository(db *gorm.DB) *MessageRepository {
	return &MessageRepository{db: db}
}

func (r *MessageRepository) CreateMessage(msg *domain.Message) error {
	if msg.ID == "" {
		msg.ID = uuid.New().String()
	}
	return r.db.Create(msg).Error
}

func (r *MessageRepository) GetMessagesForUser(userID string) ([]domain.Message, error) {
	var messages []domain.Message
	// Get messages where user is sender or recipient
	// This is a simplified chat history fetch. In a real app, you'd group by conversation.
	err := r.db.Where("sender_id = ? OR recipient_id = ?", userID, userID).
		Order("created_at desc").
		Find(&messages).Error
	return messages, err
}

type NotificationRepository struct {
	db *gorm.DB
}

func NewNotificationRepository(db *gorm.DB) *NotificationRepository {
	return &NotificationRepository{db: db}
}

func (r *NotificationRepository) CreateNotification(notif *domain.Notification) error {
	if notif.ID == "" {
		notif.ID = uuid.New().String()
	}
	return r.db.Create(notif).Error
}

func (r *NotificationRepository) GetNotificationsForUser(userID string) ([]domain.Notification, error) {
	var notifications []domain.Notification
	err := r.db.Where("user_id = ?", userID).
		Order("created_at desc").
		Find(&notifications).Error
	return notifications, err
}
