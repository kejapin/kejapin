package domain

import (
	"time"

	"gorm.io/datatypes"
)

type Message struct {
	ID          string         `gorm:"type:char(36);primaryKey" json:"id"`
	SenderID    string         `gorm:"type:char(36);not null" json:"sender_id"`
	RecipientID string         `gorm:"type:char(36);not null" json:"recipient_id"`
	PropertyID  *string        `gorm:"type:char(36)" json:"property_id,omitempty"`
	Content     string         `gorm:"type:text;not null" json:"content"`
	Type        string         `gorm:"type:text;default:'text'" json:"type"`
	Metadata    datatypes.JSON `gorm:"type:jsonb;default:'{}'" json:"metadata"`
	IsRead      bool           `gorm:"default:false" json:"is_read"`
	CreatedAt   time.Time      `json:"created_at"`
}

func (Message) TableName() string {
	return "messages"
}

type NotificationType string

const (
	NotificationTypeMessage   NotificationType = "MESSAGE"
	NotificationTypeFinancial NotificationType = "FINANCIAL"
	NotificationTypeSystem    NotificationType = "SYSTEM"
)

type Notification struct {
	ID        string           `gorm:"type:char(36);primaryKey" json:"id"`
	UserID    string           `gorm:"type:char(36);not null" json:"user_id"`
	Title     string           `gorm:"type:varchar(255);not null" json:"title"`
	Message   string           `gorm:"type:text;not null" json:"message"`
	Type      NotificationType `gorm:"type:varchar(50);not null" json:"type"`
	Metadata  datatypes.JSON   `gorm:"type:jsonb" json:"metadata,omitempty"`
	IsRead    bool             `gorm:"default:false" json:"is_read"`
	CreatedAt time.Time        `json:"created_at"`
}

func (Notification) TableName() string {
	return "notifications"
}
