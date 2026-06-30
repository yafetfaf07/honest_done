package dbmodels

import (
	"time"

	"github.com/google/uuid"
)

type TodoTaskDB struct {
	Title     string `gorm:"not null"`
	ScheduleTime time.Time `gorm:"not null; uniqueIndex"`
	CompletedTime time.Time
	GoalID uuid.UUID `gorm:"not null;"`
	Goal GoalDB `gorm:"foreignKey:GoalID"`
	// UserId   uuid.UUID `gorm:"not null"`
	Status string `gorm:"not null;default:'pending'"`
	GormModel
}

func (TodoTaskDB) TableName() string {
	return "todo_tasks"
}
