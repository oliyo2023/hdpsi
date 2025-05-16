package utils

import (
	"github.com/gin-gonic/gin"
)

// RespondWithError sends a JSON error response with a specific status code and message.
func RespondWithError(c *gin.Context, code int, message string) {
	c.JSON(code, gin.H{"error": message})
}
