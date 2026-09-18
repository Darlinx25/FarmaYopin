package db

import (
	"database/sql"
	"fmt"
	"log"
	"os"
	"time"

	_ "github.com/go-sql-driver/mysql"
)

var DB *sql.DB

func Connect() {
	dsn := fmt.Sprintf("%s:%s@tcp(%s:%s)/%s?parseTime=true",
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_HOST"),
		os.Getenv("DB_PORT"),
		os.Getenv("DB_NAME"),
	)

	var err error
	for i := 0; i < 10; i++ {
		DB, err = sql.Open("mysql", dsn)
		if err == nil {
			err = DB.Ping()
		}
		if err == nil {
			break
		}
		log.Println("Esperando base de datos...")
		time.Sleep(3 * time.Second)
	}

	if err != nil {
		log.Fatal("No se pudo conectar a la base de datos:", err)
	}

	DB.SetMaxOpenConns(10)
	DB.SetMaxIdleConns(5)
	log.Println("Base de datos conectada")

	migrate()
}

func migrate() {
	var count int
	err := DB.QueryRow(`
		SELECT COUNT(*) FROM information_schema.columns
		WHERE table_schema = DATABASE() AND table_name = 'sales' AND column_name = 'payment_method'
	`).Scan(&count)
	if err != nil {
		log.Println("No se pudo verificar migraciones:", err)
		return
	}

	if count == 0 {
		if _, err := DB.Exec(
			"ALTER TABLE sales ADD COLUMN payment_method VARCHAR(20) NOT NULL DEFAULT 'cash' AFTER total",
		); err != nil {
			log.Fatal("No se pudo agregar payment_method:", err)
		}
		if _, err := DB.Exec(
			"ALTER TABLE sales ADD COLUMN card_last4 VARCHAR(4) NOT NULL DEFAULT '' AFTER payment_method",
		); err != nil {
			log.Fatal("No se pudo agregar card_last4:", err)
		}
		log.Println("Migración sales (payment_method, card_last4) aplicada")
	}
}
