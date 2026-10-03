package config

import (
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
)

type Config struct {
	DatabaseURL string
	RedisAddr   string
	Port        string
	JWTSecret   string
}

func findEnvFile() string {
	wd, err := os.Getwd()
	if err != nil {
		return ""
	}

	for {
		candidate := filepath.Join(wd, ".env")
		if _, err := os.Stat(candidate); err == nil {
			return candidate
		}

		parent := filepath.Dir(wd)
		if parent == wd {
			break
		}
		wd = parent
	}

	return ""
}

// This is for loading Environment variables
func Load() (*Config, error) {
	if envFile := findEnvFile(); envFile != "" {
		if err := godotenv.Load(envFile); err != nil {
			return nil, err
		}
	} else {
		_ = godotenv.Load()
	}

	config := &Config{
		DatabaseURL: os.Getenv("DATABASE_URL"),
		Port:        os.Getenv("PORT"),
		RedisAddr:   os.Getenv("REDIS_ADDR"),
		JWTSecret:   os.Getenv("JWT_SECRET"),
	}

	return config, nil
}
