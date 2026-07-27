// Package tide predicts tides from a station's table.
package tide

import (
	"encoding/json"
	"errors"
	"os"
	"time"
)

// Reading is one predicted tide in a station's table.
type Reading struct {
	Time   time.Time `json:"time"`
	Type   string    `json:"type"`
	Height float64   `json:"height"`
}

// ErrNoUpcoming reports that the table holds no high tide after the given time.
var ErrNoUpcoming = errors.New("no upcoming high tide in data")

// LoadTides reads a tide table from a JSON file.
func LoadTides(path string) ([]Reading, error) {
	b, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var rs []Reading
	if err := json.Unmarshal(b, &rs); err != nil {
		return nil, err
	}
	return rs, nil
}

// NextHigh returns the first high tide strictly after after.
func NextHigh(rs []Reading, after time.Time) (Reading, error) {
	for _, r := range rs {
		if r.Type == "high" && r.Time.After(after) {
			return r, nil
		}
	}
	return Reading{}, ErrNoUpcoming
}
