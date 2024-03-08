package storage

import (
	"database/sql"
	"errors"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func InitDB() (*sql.DB, error) {

	// initialize database

	// make db connection
	dbUrl := os.Getenv("DB_URL")
	if dbUrl == "" {
		return nil, errors.New("database connection url not found")
	}

	db, err := sql.Open("postgres", dbUrl)
	if err != nil {
		log.Fatalln("Couldnot connect to database")
	}
	defer db.Close()

	if err := db.Ping(); err != nil {
		return nil, err
	}

	return db, nil
}
