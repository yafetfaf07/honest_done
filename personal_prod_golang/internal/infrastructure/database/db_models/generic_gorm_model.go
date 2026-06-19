package dbmodels

import (
	"time"

	uuid "github.com/jackc/pgx/pgtype/ext/gofrs-uuid"
	"gorm.io/gorm"
)

type gormModel struct {
	ID uuid.UUID `gorm:"primaryKey"`

	CreatedAt time.Time

	UpdatedAt time.Time

	DeletedAt gorm.DeletedAt `gorm:"index"`
}

