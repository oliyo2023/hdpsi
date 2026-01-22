package utils

import (
	"encoding/json"
)

// ConvertStringSliceToJSON converts a slice of strings to a JSON string.
// If the slice is empty or nil, it returns an empty JSON array "[]" or an error if marshalling fails.
func ConvertStringSliceToJSON(slice []string) (string, error) {
	if slice == nil {
		return "[]", nil // Return empty JSON array for nil slice
	}
	jsonData, err := json.Marshal(slice)
	if err != nil {
		return "", err
	}
	return string(jsonData), nil
}

// ConvertJSONToStringSlice converts a JSON string (expected to be an array of strings) to a slice of strings.
func ConvertJSONToStringSlice(jsonStr string) ([]string, error) {
	var slice []string
	if jsonStr == "" || jsonStr == "[]" {
		return []string{}, nil // Return empty slice for empty or "[]" string
	}
	err := json.Unmarshal([]byte(jsonStr), &slice)
	if err != nil {
		return nil, err
	}
	return slice, nil
}
