package ports

import "github.com/kejapin/server/internal/core/domain"

type UserRepository interface {
	Create(user *domain.User) error
	FindByEmail(email string) (*domain.User, error)
	FindByID(id string) (*domain.User, error)
	Update(user *domain.User) error
	CreateApplication(app *domain.RoleApplication) error
}

type AuthService interface {
	Register(email, password, role string) (*domain.User, error)
	Login(email, password string) (string, *domain.User, error)
}

type PropertyRepository interface {
	FindAll(filters map[string]interface{}) ([]domain.Property, error)
	Create(property *domain.Property) error
	FindInRadius(lat, lng, radiusMeters float64) ([]domain.Property, error)
}

type MarketplaceService interface {
	GetListings(filters map[string]interface{}) ([]domain.Property, error)
	CreateListing(listing *domain.Property) error
	SubmitReview(review *domain.Review) error
}
