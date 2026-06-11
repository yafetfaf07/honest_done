package database

import (
	"context"
	"fmt"

	"github.com/jackc/pgx/v5/pgxpool"
)

func Connect(databaseUrl string) (*pgxpool.Pool, error) {
	ctx := context.Background()
	config, err := pgxpool.ParseConfig(databaseUrl)
	if err != nil {
		return nil, fmt.Errorf("database connection failed: %w", err)
	}
	pool, err := pgxpool.NewWithConfig(ctx, config)
	if err != nil {
		return nil, fmt.Errorf("database connection failed: %w", err)

	}
	err = pool.Ping(ctx)
	if err != nil {
		fmt.Printf("Unable to ping to database %v", err)
		pool.Close()
		return nil, err
	}
	return pool, nil
}
