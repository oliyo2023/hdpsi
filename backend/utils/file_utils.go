package utils

import "strings"

// IsAllowedImageType 检查文件类型是否为允许的图片类型
func IsAllowedImageType(contentType string) bool {
	allowedTypes := []string{
		"image/jpeg",
		"image/png",
		"image/gif",
		"image/webp",
	}

	for _, t := range allowedTypes {
		if strings.EqualFold(contentType, t) {
			return true
		}
	}

	return false
}