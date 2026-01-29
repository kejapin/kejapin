package services

import (
	"encoding/json"
	"fmt"
	"net/http"
	"time"

	"github.com/kejapin/server/internal/core/domain"
)

type GeoService struct {
	OSRMBaseURL string
}

func NewGeoService(osrmBaseURL string) *GeoService {
	if osrmBaseURL == "" {
		osrmBaseURL = "http://localhost:5000" // Default OSRM local container
	}
	return &GeoService{OSRMBaseURL: osrmBaseURL}
}

type OSRMResponse struct {
	Routes []struct {
		Duration float64 `json:"duration"`
		Distance float64 `json:"distance"`
	} `json:"routes"`
	Code string `json:"code"`
}

func (s *GeoService) CalculateCommute(req domain.CommuteRequest) (*domain.CommuteResponse, error) {
	// OSRM URL format: /route/v1/{profile}/{coordinates}?overview=false
	// Profile: driving, walking, cycling
	profile := "driving"
	if req.Mode != "" {
		profile = req.Mode
	}

	// Coordinates: {lon},{lat};{lon},{lat}
	coords := fmt.Sprintf("%f,%f;%f,%f", req.OriginLng, req.OriginLat, req.DestinationLng, req.DestinationLat)
	url := fmt.Sprintf("%s/route/v1/%s/%s?overview=false", s.OSRMBaseURL, profile, coords)

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
	}, nil
}
