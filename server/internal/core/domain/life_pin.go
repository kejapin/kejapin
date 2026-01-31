package domain

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type LifePin struct {
	ID            uuid.UUID `gorm:"type:char(36);primaryKey" json:"id"`
	UserID        uuid.UUID `gorm:"type:char(36);not null" json:"user_id"`
	Label         string    `gorm:"type:varchar(50);not null" json:"label"`
	Latitude      float64   `gorm:"not null" json:"latitude"`
	Longitude     float64   `gorm:"not null" json:"longitude"`
	TransportMode string    `gorm:"type:varchar(20);not null" json:"transport_mode"`
	IsPrimary     bool      `gorm:"default:false" json:"is_primary"`
	CreatedAt     time.Time `gorm:"autoCreateTime" json:"created_at"`
}

func (LifePin) TableName() string {
	return "life_pins"
}

func (l *LifePin) BeforeCreate(tx *gorm.DB) (err error) {
	if l.ID == uuid.Nil {
		l.ID = uuid.New()
	}
	return
}

type CommuteRequest struct {
	OriginLat      float64 `json:"origin_lat"`
	OriginLng      float64 `json:"origin_lng"`
	DestinationLat float64 `json:"dest_lat"`
	DestinationLng float64 `json:"dest_lng"`
	Mode           string  `json:"mode"` // driving, walking, cycling
}

type CommuteResponse struct {
	DurationSeconds float64 `json:"duration_seconds"`
	DistanceMeters  float64 `json:"distance_meters"`
	Polyline        string  `json:"polyline"`
}
