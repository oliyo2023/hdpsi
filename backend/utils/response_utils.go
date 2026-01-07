package utils

import (
	"github.com/kataras/iris/v12"
)

// RespondWithError sends a JSON error response with a specific status code and message.
func RespondWithError(c iris.Context, code int, message string) {
	c.StatusCode(code)
	c.JSON(map[string]interface{}{"error": message})
}
