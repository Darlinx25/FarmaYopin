package handlers

import (
	"database/sql"
	"net/http"
	"strconv"

	"farmayopin/backend/db"
	"farmayopin/backend/models"

	"github.com/gin-gonic/gin"
)

func GetProducts(c *gin.Context) {
	rows, err := db.DB.Query(
		"SELECT id, name, description, price, stock, image_url, created_at, updated_at FROM products ORDER BY name",
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al listar productos"})
		return
	}
	defer rows.Close()

	var products []models.Product
	for rows.Next() {
		var p models.Product
		if err := rows.Scan(&p.ID, &p.Name, &p.Description, &p.Price, &p.Stock, &p.ImageURL, &p.CreatedAt, &p.UpdatedAt); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al leer productos"})
			return
		}
		products = append(products, p)
	}

	c.JSON(http.StatusOK, gin.H{"data": products})
}

func GetProduct(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	var p models.Product
	err = db.DB.QueryRow(
		"SELECT id, name, description, price, stock, image_url, created_at, updated_at FROM products WHERE id = ?",
		id,
	).Scan(&p.ID, &p.Name, &p.Description, &p.Price, &p.Stock, &p.ImageURL, &p.CreatedAt, &p.UpdatedAt)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener producto"})
		return
	}

	c.JSON(http.StatusOK, p)
}

func CreateProduct(c *gin.Context) {
	var input models.CreateProductInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Datos inválidos"})
		return
	}

	result, err := db.DB.Exec(
		"INSERT INTO products (name, description, price, stock, image_url) VALUES (?, ?, ?, ?, ?)",
		input.Name, input.Description, input.Price, input.Stock, input.ImageURL,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo crear el producto"})
		return
	}

	id, _ := result.LastInsertId()
	c.JSON(http.StatusCreated, gin.H{"id": id, "message": "Producto creado"})
}

func UpdateProduct(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	var input models.CreateProductInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Datos inválidos"})
		return
	}

	result, err := db.DB.Exec(
		"UPDATE products SET name = ?, description = ?, price = ?, stock = ?, image_url = ? WHERE id = ?",
		input.Name, input.Description, input.Price, input.Stock, input.ImageURL, id,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo actualizar el producto"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Producto actualizado"})
}

func DeleteProduct(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	result, err := db.DB.Exec("DELETE FROM products WHERE id = ?", id)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo eliminar el producto"})
		return
	}

	rowsAffected, _ := result.RowsAffected()
	if rowsAffected == 0 {
		c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "Producto eliminado"})
}

func GetProductHistory(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	rows, err := db.DB.Query(`
		SELECT s.created_at, si.quantity, u.name
		FROM sale_items si
		JOIN sales s ON s.id = si.sale_id
		JOIN users u ON u.id = s.user_id
		WHERE si.product_id = ?
		ORDER BY s.created_at DESC`,
		id,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener historial"})
		return
	}
	defer rows.Close()

	var history []models.ProductHistoryItem
	for rows.Next() {
		var h models.ProductHistoryItem
		if err := rows.Scan(&h.Date, &h.Quantity, &h.Client); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al leer historial"})
			return
		}
		history = append(history, h)
	}

	c.JSON(http.StatusOK, gin.H{"data": history})
}