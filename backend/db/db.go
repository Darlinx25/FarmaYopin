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
}
