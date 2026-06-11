package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)
// Configs for Postgres and redis database
type Config struct {
	DatabaseURL string
	RedisAddr string
	Port string
}

// This is for loading Environment variables
func Load() (*Config,error) {
	err:=godotenv.Load()

	if err!=nil {
	fmt.Printf("An error occured on env variable %v", err)
	return nil,err
	}
	var config *Config = &Config{
		DatabaseURL: os.Getenv("DATABASE_URL"),
		Port: os.Getenv("PORT"),
		RedisAddr: os.Getenv("REDIS_ADDR"),
	}

	return config,nil

}