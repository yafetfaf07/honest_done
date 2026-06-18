package dbmodels
import (
	"time"

	"gorm.io/gorm"
)

type GormModel struct {
	ID uint `gorm:"primaryKey"`

	CreatedAt time.Time

	UpdatedAt time.Time

	DeletedAt gorm.DeletedAt `gorm:"index"`
}