package embed

import (
	"embed"
	"net/http"
)

//go:embed public/index.html public/assets/css/style.css
var publicFiles embed.FS

// GetPublicFS 返回嵌入的静态文件系统
func GetPublicFS() http.FileSystem {
	return http.FS(publicFiles)
}
