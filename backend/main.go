package main

import (
	"log"
	"os"

	"farmayopin/backend/db"
	"farmayopin/backend/handlers"
	"farmayopin/backend/middleware"

	"github.com/gin-gonic/gin"
	"github.com/joho/godotenv"
)

func main() {
	if err := godotenv.Load(); err != nil {
		log.Println("No se encontró archivo .env")
	}

	db.Connect()

	r := gin.Default()

	r.GET("/health", func(c *gin.Context) {
		c.JSON(200, gin.H{"status": "ok"})
	})

	r.POST("/register", handlers.Register)
	r.POST("/login", handlers.Login)

	api := r.Group("/api")
	api.Use(middleware.AuthRequired())
	{
		api.GET("/products", handlers.GetProducts)
		api.GET("/products/:id", handlers.GetProduct)
		api.GET("/products/:id/history", middleware.AdminRequired(), handlers.GetProductHistory)

		admin := api.Group("")
		admin.Use(middleware.AdminRequired())
		{
			admin.POST("/products", handlers.CreateProduct)
			admin.PUT("/products/:id", handlers.UpdateProduct)
			admin.DELETE("/products/:id", handlers.DeleteProduct)
		}

		api.GET("/cart", handlers.GetCart)
		api.POST("/cart", handlers.AddToCart)
		api.PUT("/cart/:product_id", handlers.UpdateCartItem)
		api.DELETE("/cart/:product_id", handlers.RemoveFromCart)
		api.POST("/cart/checkout", handlers.Checkout)

		api.GET("/purchases", handlers.GetPurchases)
	}

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}
	r.Run(":" + port)
}