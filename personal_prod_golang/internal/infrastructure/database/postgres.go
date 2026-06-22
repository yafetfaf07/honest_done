package database

import (
	"fmt"
	"time"

	dbmodels "github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database/db_models"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
	"gorm.io/gorm/logger"
)

// GORM database connect
func Connect(databaseUrl string) (*gorm.DB, error) {

	gormConnection, err := gorm.Open(postgres.Open(databaseUrl), &gorm.Config{
		Logger: logger.Default.LogMode(logger.Info),
	})
	if err != nil {
		return nil, fmt.Errorf("database connection failed: %w", err)
	}
	sqlDb, err := gormConnection.DB()

	if err != nil {
		return nil, fmt.Errorf("Failed to get underlying sql.DB: %w", err)

	}
	if err := sqlDb.Ping(); err != nil {
		return nil, fmt.Errorf("unable to ping database: %w", err)
	}
	gormConnection.AutoMigrate(&dbmodels.UserDB{})
	gormConnection.AutoMigrate(&dbmodels.TodoTaskDB{})
	// gormConnection.Migrator().AlterColumn(&dbmodels.TodoTaskDB{}, "Title")
	// gormConnection.Migrator().AlterColumn(&dbmodels.TodoTaskDB{}, "ScheduleTime")
	gormConnection.Migrator().AlterColumn(&dbmodels.UserDB{}, "Password")
	gormConnection.Migrator().AlterColumn(&dbmodels.UserDB{}, "Name")

	gormConnection.Migrator().AlterColumn(&dbmodels.TodoTaskDB{}, "Status")

	sqlDb.SetMaxIdleConns(10)
	sqlDb.SetMaxOpenConns(100)
	sqlDb.SetConnMaxLifetime(time.Hour)

	return gormConnection, nil
}
