package dbmodels

import (
	"time"

	"github.com/google/uuid"
)

type TodoTaskDB struct {
	Title     string `gorm:"not null"`
	ScheduleTime time.Time `gorm:"not null"`
	CompletedTime *time.Time
	UserId   uuid.UUID `gorm:"not null"`
	Status string `gorm:"not null;default:'pending'"`
	User    UserDB `gorm:"foreignKey:UserId"`
	GormModel
}

func (TodoTaskDB) TableName() string {
	return "todo_tasks"
}
