package services

import (
	"github.com/kejapin/server/internal/core/domain"
	"github.com/kejapin/server/internal/core/ports"
)

type marketplaceService struct {
	repo ports.PropertyRepository
}

func NewMarketplaceService(repo ports.PropertyRepository) ports.MarketplaceService {
	return &marketplaceService{repo: repo}
}

func (s *marketplaceService) GetListings(filters map[string]interface{}) ([]domain.Property, error) {
	return s.repo.FindAll(filters)
}
