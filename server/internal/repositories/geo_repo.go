package repositories

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"strconv"
	"time"

	"github.com/kejapin/server/internal/core/domain"
)

type GeoRepository struct {
	db     *sql.DB
	client *http.Client
}

func NewGeoRepository(db *sql.DB) *GeoRepository {
	return &GeoRepository{
		db:     db,
		client: &http.Client{Timeout: 10 * time.Second},
	}
}

// Nominatim Response Struct
type nominatimResult struct {
	PlaceID     int64  `json:"place_id"`
	Lat         string `json:"lat"`
	Lon         string `json:"lon"`
	DisplayName string `json:"display_name"`
	Type        string `json:"type"`
	Class       string `json:"class"`
	OsmType     string `json:"osm_type"`
	OsmID       int64  `json:"osm_id"`
}

func (r *GeoRepository) SearchLocations(query string, limit int) ([]domain.GeoFeature, error) {
	// 1. Try Turso first
	if r.db != nil {
		rows, err := r.db.Query(`
			SELECT id, type, name, category, lat, lon, tags 
			FROM osm_features 
			WHERE name LIKE ? 
			LIMIT ?`,
			"%"+query+"%", limit)
		if err == nil {
			defer rows.Close()
			var features []domain.GeoFeature
			for rows.Next() {
				var f domain.GeoFeature
				if err := rows.Scan(&f.ID, &f.Type, &f.Name, &f.Category, &f.Lat, &f.Lon, &f.Tags); err == nil {
					features = append(features, f)
				}
			}
			if len(features) > 0 {
				log.Printf("Found %d locations in local Turso DB", len(features))
				return features, nil
			}
		} else {
			log.Printf("Turso search error: %v, falling back to Nominatim", err)
		}
	}

	// 2. Fallback to Nominatim Search
	endpoint := fmt.Sprintf("https://nominatim.openstreetmap.org/search?q=%s&format=json&limit=%d&addressdetails=1", url.QueryEscape(query), limit)

	req, _ := http.NewRequest("GET", endpoint, nil)
	req.Header.Set("User-Agent", "KejapinApp/1.0 (dev@kejapin.com)")

	resp, err := r.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var results []nominatimResult
	if err := json.NewDecoder(resp.Body).Decode(&results); err != nil {
		return nil, err
	}

	var features []domain.GeoFeature
	for _, res := range results {
		lat, _ := strconv.ParseFloat(res.Lat, 64)
		lon, _ := strconv.ParseFloat(res.Lon, 64)

		features = append(features, domain.GeoFeature{
			ID:       res.OsmID,
			Type:     res.OsmType,
			Name:     res.DisplayName,
			Category: res.Type,
			Lat:      lat,
			Lon:      lon,
			Tags:     fmt.Sprintf(`{"class":"%s"}`, res.Class),
		})
	}
	return features, nil
}

func (r *GeoRepository) GetNearbyAmenities(lat, lon float64, radiusMeters float64, limit int) ([]domain.GeoFeature, error) {
	// 1. Try Turso first (using a bounding box for performance)
	if r.db != nil {
		// ~111,111 meters per degree of latitude
		delta := radiusMeters / 111111.0
		rows, err := r.db.Query(`
			SELECT id, type, name, category, lat, lon, tags 
			FROM osm_features 
			WHERE lat BETWEEN ? AND ? 
			AND lon BETWEEN ? AND ?
			LIMIT ?`,
			lat-delta, lat+delta, lon-delta, lon+delta, limit)
		if err == nil {
			defer rows.Close()
			var features []domain.GeoFeature
			for rows.Next() {
				var f domain.GeoFeature
				if err := rows.Scan(&f.ID, &f.Type, &f.Name, &f.Category, &f.Lat, &f.Lon, &f.Tags); err == nil {
					features = append(features, f)
				}
			}
			if len(features) > 0 {
				log.Printf("Found %d amenities in local Turso DB", len(features))
				return features, nil
			}
		} else {
			log.Printf("Turso nearby error: %v, falling back to Overpass", err)
		}
	}

	// 2. Fallback to Overpass API
	ql := fmt.Sprintf(`[out:json];(node(around:%.0f,%.6f,%.6f)["amenity"];way(around:%.0f,%.6f,%.6f)["amenity"];);out center %d;`,
		radiusMeters, lat, lon, radiusMeters, lat, lon, limit)

	u, _ := url.Parse("https://overpass-api.de/api/interpreter")
	q := u.Query()
	q.Set("data", ql)
	u.RawQuery = q.Encode()

	req, _ := http.NewRequest("GET", u.String(), nil)
	req.Header.Set("User-Agent", "KejapinApp/1.0")

	resp, err := r.client.Do(req)
	if err != nil {
		return nil, err
	}
	defer resp.Body.Close()

	var ov struct {
		Elements []struct {
			Type string            `json:"type"`
			ID   int64             `json:"id"`
			Lat  float64           `json:"lat"`
			Lon  float64           `json:"lon"`
			Tags map[string]string `json:"tags"`
		} `json:"elements"`
	}
	if err := json.NewDecoder(resp.Body).Decode(&ov); err != nil {
		return nil, err
	}

	var features []domain.GeoFeature
	for _, el := range ov.Elements {
		if el.Tags == nil {
			continue
		}
		name := el.Tags["name"]
		cat := el.Tags["amenity"]
		if name == "" {
			name = cat
		}

		tagsJson, _ := json.Marshal(el.Tags)

		features = append(features, domain.GeoFeature{
			ID:       el.ID,
			Type:     el.Type,
			Name:     name,
			Category: cat,
			Lat:      el.Lat,
			Lon:      el.Lon,
			Tags:     string(tagsJson),
		})
	}

	return features, nil
}
