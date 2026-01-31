package domain

type GeoFeature struct {
	ID       int64   `json:"id"`
	Type     string  `json:"type"` // node, way, relation
	Name     string  `json:"name"`
	Category string  `json:"category"`
	Lat      float64 `json:"lat"`
	Lon      float64 `json:"lon"`
	Tags     string  `json:"tags"` // JSON string
}

type SearchLocationsRequest struct {
	Query string `json:"query"`
	Limit int    `json:"limit"`
}
