package domain

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type Role string

const (
	RoleTenant   Role = "TENANT"
	RoleLandlord Role = "LANDLORD"
	RoleAdmin    Role = "ADMIN"
	RoleAgent    Role = "AGENT"
)

type User struct {
	ID             uuid.UUID  `gorm:"type:char(36);primary_key" json:"id"`
	Email          string     `gorm:"uniqueIndex;not null" json:"email"`
	PhoneNumber    string     `gorm:"uniqueIndex" json:"phone_number"`
	FirstName      string     `json:"first_name"`
	LastName       string     `json:"last_name"`
	PasswordHash   string     `gorm:"not null" json:"-"` // Don't return password hash
	Role           Role       `gorm:"type:varchar(20);not null" json:"role"`
	ProfilePicture string     `json:"profile_picture"`
	IsPremium      bool       `gorm:"default:false" json:"is_premium"`
	IsVerified     bool       `gorm:"default:false" json:"is_verified"`
	LastLogin      *time.Time `json:"last_login"`
	CreatedAt      time.Time  `json:"created_at"`
	UpdatedAt      time.Time  `json:"updated_at"`
}

// TableName explicitly sets the table name
func (User) TableName() string {
	return "users"
}

func (u *User) BeforeCreate(tx *gorm.DB) (err error) {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}
	return
}
