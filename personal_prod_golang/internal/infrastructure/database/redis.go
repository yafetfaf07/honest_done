package database

import (
	"context"
	"github.com/redis/go-redis/v9"
)

// InitRedis initializes and returns a redis client
func InitRedis(addr string) (*redis.Client, error) {
	rdb := redis.NewClient(&redis.Options{
		Addr: addr, // e.g., "localhost:6379"
	})

	// Optional: Ping to check connection
	if err := rdb.Ping(context.Background()).Err(); err != nil {
		return nil, err
	}
	return rdb, nil
}
