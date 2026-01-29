package domain

import (
	"time"

	"github.com/google/uuid"
)

type LifePin struct {
	ID            uuid.UUID `gorm:"type:uuid;primaryKey;default:gen_random_uuid()" json:"id"`
	UserID        uuid.UUID `gorm:"type:uuid;not null" json:"user_id"`
	Label         string    `gorm:"type:varchar(50);not null" json:"label"`
	Latitude      float64   `gorm:"not null" json:"latitude"`
	Longitude     float64   `gorm:"not null" json:"longitude"`
	TransportMode string    `gorm:"type:varchar(20);not null;check:transport_mode IN ('WALK', 'DRIVE', 'CYCLE', 'PUBLIC_TRANSPORT')" json:"transport_mode"`
	IsPrimary     bool      `gorm:"default:false" json:"is_primary"`
	CreatedAt     time.Time `gorm:"autoCreateTime" json:"created_at"`
}

// TableName overrides the table name used by User to `life_pins`
func (LifePin) TableName() string {
	return "life_pins"
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
}
