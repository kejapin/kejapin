package domain

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type VerificationStatus string

const (
	VStatusPending  VerificationStatus = "PENDING"
	VStatusVerified VerificationStatus = "VERIFIED"
	VStatusRejected VerificationStatus = "REJECTED"
	VStatusWarning  VerificationStatus = "WARNING"
)

type RoleApplication struct {
	ID         uuid.UUID          `gorm:"type:char(36);primary_key" json:"id"`
	UserID     uuid.UUID          `gorm:"type:char(36);not null" json:"user_id"`
	Documents  string             `gorm:"type:text" json:"documents"` // JSON string
	Status     VerificationStatus `gorm:"type:varchar(20);default:'PENDING'" json:"status"`
	AdminNotes string             `json:"admin_notes"`
	CreatedAt  time.Time          `json:"created_at"`
}

func (RoleApplication) TableName() string {
	return "role_applications"
}

func (r *RoleApplication) BeforeCreate(tx *gorm.DB) (err error) {
	if r.ID == uuid.Nil {
		r.ID = uuid.New()
	}
	return
}
