package main

import (
	"errors"
	"os"

	"github.com/joho/godotenv"
)

func GetPort() (string, error) {
	envErr := godotenv.Load()
	if envErr != nil {
		return "", envErr
	}

	port := os.Getenv("PORT")
	if port == "" {
		return "", errors.New("port not set")
	}

	return port, nil
}
