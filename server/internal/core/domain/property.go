package domain

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type PropertyType string
type ListingType string
type PropertyStatus string

const (
	TypeBedsitter PropertyType = "BEDSITTER"
	Type1BHK      PropertyType = "1BHK"
	Type2BHK      PropertyType = "2BHK"
	TypeSQ        PropertyType = "SQ"
	TypeBungalow  PropertyType = "BUNGALOW"

	ListingRent ListingType = "RENT"
	ListingSale ListingType = "SALE"

	StatusAvailable PropertyStatus = "AVAILABLE"
	StatusOccupied  PropertyStatus = "OCCUPIED"
	StatusSold      PropertyStatus = "SOLD"
)

type Property struct {
	ID              uuid.UUID      `gorm:"type:char(36);primary_key" json:"id"`
	OwnerID         uuid.UUID      `gorm:"type:char(36);not null" json:"owner_id"`
	Title           string         `gorm:"not null" json:"title"`
	Description     string         `json:"description"`
	ListingType     ListingType    `gorm:"type:varchar(20);default:'RENT'" json:"listing_type"`
	PropertyType    PropertyType   `gorm:"type:varchar(50);not null" json:"property_type"`
	PriceAmount     float64        `gorm:"not null" json:"price_amount"`
	Latitude        float64        `gorm:"not null" json:"latitude"`
	Longitude       float64        `gorm:"not null" json:"longitude"`
	AddressLine1    string         `json:"address_line_1"`
	City            string         `gorm:"not null" json:"city"`
	County          string         `gorm:"not null" json:"county"`
	Amenities       string         `gorm:"type:text" json:"amenities"` // Changed from pq.StringArray
	Photos          string         `gorm:"type:text" json:"photos"`    // Changed from pq.StringArray
	Bedrooms        int            `gorm:"default:0" json:"bedrooms"`
	Bathrooms       int            `gorm:"default:0" json:"bathrooms"`
	Status          PropertyStatus `gorm:"type:varchar(20);default:'AVAILABLE'" json:"status"`
	EfficiencyStats string         `gorm:"type:text" json:"efficiency_stats"`
	Rating          float64        `gorm:"default:0" json:"rating"`
	ReviewCount     int            `gorm:"default:0" json:"review_count"`
	IsVerified      bool           `gorm:"default:false" json:"is_verified"`
	RentPeriod      string         `gorm:"default:'MONTHLY'" json:"rent_period"`
	CreatedAt       time.Time      `json:"created_at"`
	UpdatedAt       time.Time      `json:"updated_at"`
}

// TableName explicitly sets the table name
func (Property) TableName() string {
	return "properties"
}

func (p *Property) BeforeCreate(tx *gorm.DB) (err error) {
	if p.ID == uuid.Nil {
		p.ID = uuid.New()
	}
	return
}
