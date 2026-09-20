package handlers

import (
	"crypto/rand"
	"encoding/hex"
	"fmt"
	"net/http"
	"path/filepath"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
)

var allowedImageExts = map[string]bool{
	".jpg":  true,
	".jpeg": true,
	".png":  true,
	".webp": true,
	".gif":  true,
}

const maxImageSize = 5 << 20

func UploadProductImage(c *gin.Context) {
	file, err := c.FormFile("image")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "No se recibió la imagen"})
		return
	}

	if file.Size > maxImageSize {
		c.JSON(http.StatusBadRequest, gin.H{"error": "La imagen supera los 5 MB"})
		return
	}

	ext := strings.ToLower(filepath.Ext(file.Filename))
	if !allowedImageExts[ext] {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Formato de imagen no soportado"})
		return
	}

	name := fmt.Sprintf("upl_%d_%s%s", time.Now().UnixNano(), randomHex(4), ext)
	if err := c.SaveUploadedFile(file, filepath.Join("uploads", name)); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo guardar la imagen"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"image_url": "/uploads/" + name})
}

func randomHex(n int) string {
	b := make([]byte, n)
	rand.Read(b)
	return hex.EncodeToString(b)
}