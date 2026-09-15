package handlers

import (
	"database/sql"
	"net/http"
	"strconv"
	"sync"

	"farmayopin/backend/db"
	"farmayopin/backend/models"

	"github.com/gin-gonic/gin"
)

type cartState struct {
	items map[int]map[int]models.CartItem
	mu    sync.Mutex
}

var carts = &cartState{items: make(map[int]map[int]models.CartItem)}

func userIDFromContext(c *gin.Context) int {
	userID, _ := c.Get("user_id")
	idFloat, ok := userID.(float64)
	if !ok {
		return 0
	}
	return int(idFloat)
}

func GetCart(c *gin.Context) {
	userID := userIDFromContext(c)

	carts.mu.Lock()
	items := carts.items[userID]
	var result []models.CartItem
	for _, item := range items {
		result = append(result, item)
	}
	carts.mu.Unlock()

	c.JSON(http.StatusOK, gin.H{"items": result})
}

func AddToCart(c *gin.Context) {
	userID := userIDFromContext(c)

	var input models.CartInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Datos inválidos"})
		return
	}

	var p models.Product
	err := db.DB.QueryRow(
		"SELECT id, name, description, price, stock, image_url FROM products WHERE id = ?",
		input.ProductID,
	).Scan(&p.ID, &p.Name, &p.Description, &p.Price, &p.Stock, &p.ImageURL)

	if err == sql.ErrNoRows {
		c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
		return
	}
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener producto"})
		return
	}

	if input.Quantity > p.Stock {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Stock insuficiente"})
		return
	}

	carts.mu.Lock()
	if carts.items[userID] == nil {
		carts.items[userID] = make(map[int]models.CartItem)
	}

	existing, ok := carts.items[userID][input.ProductID]
	if ok {
		existing.Quantity += input.Quantity
		existing.Subtotal = existing.Price * float64(existing.Quantity)
		carts.items[userID][input.ProductID] = existing
	} else {
		carts.items[userID][input.ProductID] = models.CartItem{
			ID:        input.ProductID,
			ProductID: input.ProductID,
			Name:      p.Name,
			Price:     p.Price,
			Quantity:  input.Quantity,
			Subtotal:  p.Price * float64(input.Quantity),
			ImageURL:  p.ImageURL,
		}
	}
	carts.mu.Unlock()

	c.JSON(http.StatusOK, gin.H{"message": "Producto agregado al carrito"})
}

func UpdateCartItem(c *gin.Context) {
	userID := userIDFromContext(c)

	productID, err := strconv.Atoi(c.Param("product_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	var input models.CartUpdateInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Datos inválidos"})
		return
	}

	carts.mu.Lock()
	defer carts.mu.Unlock()

	item, ok := carts.items[userID][productID]
	if !ok {
		c.JSON(http.StatusNotFound, gin.H{"error": "El producto no está en el carrito"})
		return
	}

	var stock int
	if err := db.DB.QueryRow("SELECT stock FROM products WHERE id = ?", productID).Scan(&stock); err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
		return
	}
	if input.Quantity > stock {
		c.JSON(http.StatusBadRequest, gin.H{"error": "Stock insuficiente"})
		return
	}

	if input.Quantity == 0 {
		delete(carts.items[userID], productID)
		c.JSON(http.StatusOK, gin.H{"message": "Producto eliminado del carrito"})
		return
	}

	item.Quantity = input.Quantity
	item.Subtotal = item.Price * float64(input.Quantity)
	carts.items[userID][productID] = item

	c.JSON(http.StatusOK, gin.H{"message": "Carrito actualizado"})
}

func RemoveFromCart(c *gin.Context) {
	userID := userIDFromContext(c)

	productID, err := strconv.Atoi(c.Param("product_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "ID inválido"})
		return
	}

	carts.mu.Lock()
	delete(carts.items[userID], productID)
	carts.mu.Unlock()

	c.JSON(http.StatusOK, gin.H{"message": "Producto eliminado del carrito"})
}

type checkoutBody struct {
	Items []struct {
		ProductID int `json:"product_id"`
		Quantity  int `json:"quantity"`
	} `json:"items"`
}

type checkoutEntry struct {
	productID int
	quantity  int
	price     float64
}

func Checkout(c *gin.Context) {
	userID := userIDFromContext(c)

	var body checkoutBody
	hasBody := c.ShouldBindJSON(&body) == nil && len(body.Items) > 0

	var entries []checkoutEntry

	carts.mu.Lock()
	defer carts.mu.Unlock()

	if hasBody {
		for _, it := range body.Items {
			if it.Quantity <= 0 {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Cantidad inválida"})
				return
			}

			var p models.Product
			err := db.DB.QueryRow(
				"SELECT id, price, stock FROM products WHERE id = ?",
				it.ProductID,
			).Scan(&p.ID, &p.Price, &p.Stock)
			if err == sql.ErrNoRows {
				c.JSON(http.StatusNotFound, gin.H{"error": "Producto no encontrado"})
				return
			}
			if err != nil {
				c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al obtener producto"})
				return
			}
			if it.Quantity > p.Stock {
				c.JSON(http.StatusBadRequest, gin.H{"error": "Stock insuficiente"})
				return
			}

			entries = append(entries, checkoutEntry{
				productID: it.ProductID,
				quantity:  it.Quantity,
				price:     p.Price,
			})
		}
	} else {
		items := carts.items[userID]
		if len(items) == 0 {
			c.JSON(http.StatusBadRequest, gin.H{"error": "El carrito está vacío"})
			return
		}
		for productID, item := range items {
			entries = append(entries, checkoutEntry{
				productID: productID,
				quantity:  item.Quantity,
				price:     item.Price,
			})
		}
	}

	tx, err := db.DB.Begin()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error en la transacción"})
		return
	}

	var total float64
	for _, e := range entries {
		total += e.price * float64(e.quantity)
	}

	result, err := tx.Exec("INSERT INTO sales (user_id, total) VALUES (?, ?)", userID, total)
	if err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo crear la venta"})
		return
	}

	saleID, _ := result.LastInsertId()

	for _, e := range entries {
		var stock int
		if err := tx.QueryRow(
			"SELECT stock FROM products WHERE id = ? FOR UPDATE",
			e.productID,
		).Scan(&stock); err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo verificar el stock"})
			return
		}
		if stock < e.quantity {
			tx.Rollback()
			c.JSON(http.StatusBadRequest, gin.H{"error": "Stock insuficiente"})
			return
		}

		_, err := tx.Exec(
			"INSERT INTO sale_items (sale_id, product_id, quantity, unit_price) VALUES (?, ?, ?, ?)",
			saleID, e.productID, e.quantity, e.price,
		)
		if err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo guardar el detalle de la venta"})
			return
		}

		_, err = tx.Exec("UPDATE products SET stock = stock - ? WHERE id = ?", e.quantity, e.productID)
		if err != nil {
			tx.Rollback()
			c.JSON(http.StatusInternalServerError, gin.H{"error": "No se pudo actualizar el stock"})
			return
		}
	}

	if err := tx.Commit(); err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "Error al confirmar la compra"})
		return
	}

	delete(carts.items, userID)

	c.JSON(http.StatusOK, gin.H{"message": "Compra realizada", "sale_id": saleID, "total": total})
}