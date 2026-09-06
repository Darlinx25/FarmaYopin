package handlers

import (
	"net/http"

	"farmayopin/backend/db"
	"farmayopin/backend/models"

	"github.com/gin-gonic/gin"
)

func GetPurchases(c *gin.Context) {
	userID := userIDFromContext(c)

	rows, err := db.DB.Query(
		"SELECT id, total, created_at FROM sales WHERE user_id = ? ORDER BY created_at DESC",
		userID,
	)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener compras"})
		return
	}
	defer rows.Close()

	var purchases []models.Purchase
	for rows.Next() {
		var pu models.Purchase
		if err := rows.Scan(&pu.ID, &pu.Total, &pu.CreatedAt); err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al leer compras"})
			return
		}
		purchases = append(purchases, pu)
	}

	for i := range purchases {
		itemRows, err := db.DB.Query(`
			SELECT si.product_id, p.name, si.quantity, si.unit_price
			FROM sale_items si
			JOIN products p ON p.id = si.product_id
			WHERE si.sale_id = ?`,
			purchases[i].ID,
		)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener detalle de compra"})
			return
		}
		defer itemRows.Close()

		var items []models.PurchaseItem
		for itemRows.Next() {
			var it models.PurchaseItem
			if err := itemRows.Scan(&it.ProductID, &it.Name, &it.Quantity, &it.UnitPrice); err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al leer detalle de compra"})
				return
			}
			it.Subtotal = it.UnitPrice * float64(it.Quantity)
			items = append(items, it)
		}
		purchases[i].Items = items
	}

	c.JSON(http.StatusOK, gin.H{"data": purchases})
}