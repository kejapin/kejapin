package services

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/kejapin/server/internal/core/domain"
	"github.com/kejapin/server/internal/repositories"
)

type GeoService struct {
	OSRMBaseURL string
	repo        *repositories.GeoRepository
}

func NewGeoService(osrmBaseURL string, repo *repositories.GeoRepository) *GeoService {
	if osrmBaseURL == "" {
		osrmBaseURL = "http://localhost:5000" // Default OSRM local container
	}
	return &GeoService{
		OSRMBaseURL: osrmBaseURL,
		repo:        repo,
	}
}

func (s *GeoService) SearchLocations(query string, limit int) ([]domain.GeoFeature, error) {
	return s.repo.SearchLocations(query, limit)
}

func (s *GeoService) GetNearbyAmenities(lat, lon float64, radius float64) ([]domain.GeoFeature, error) {
	return s.repo.GetNearbyAmenities(lat, lon, radius, 20)
}

type OSRMResponse struct {
	Routes []struct {
		Duration float64 `json:"duration"`
		Distance float64 `json:"distance"`
		Geometry string  `json:"geometry"`
	} `json:"routes"`
	Code string `json:"code"`
}

func (s *GeoService) CalculateCommute(req domain.CommuteRequest) (*domain.CommuteResponse, error) {
	// OSRM URL format: /route/v1/{profile}/{coordinates}?overview=full&geometries=polyline
	// Profile: driving, walking, cycling
	profile := "driving"
	if req.Mode != "" {
		profile = req.Mode
	}

	// Coordinates: {lon},{lat};{lon},{lat}
	coords := fmt.Sprintf("%f,%f;%f,%f", req.OriginLng, req.OriginLat, req.DestinationLng, req.DestinationLat)
	url := fmt.Sprintf("%s/route/v1/%s/%s?overview=full&geometries=polyline", s.OSRMBaseURL, profile, coords)

	client := http.Client{Timeout: 5 * time.Second}
	resp, err := client.Get(url)
	if err != nil {
		return nil, fmt.Errorf("failed to call OSRM: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return nil, fmt.Errorf("OSRM returned status: %d", resp.StatusCode)
	}

	var osrmResp OSRMResponse
	if err := json.NewDecoder(resp.Body).Decode(&osrmResp); err != nil {
		return nil, fmt.Errorf("failed to decode OSRM response: %w", err)
	}

	if osrmResp.Code != "Ok" || len(osrmResp.Routes) == 0 {
		return nil, fmt.Errorf("no route found")
	}

	return &domain.CommuteResponse{
		DurationSeconds: osrmResp.Routes[0].Duration,
		DistanceMeters:  osrmResp.Routes[0].Distance,
		Polyline:        osrmResp.Routes[0].Geometry,
	}, nil
}
