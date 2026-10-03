package dbmodels

import (
	"time"

	"github.com/google/uuid"
)

type GoalDB struct {
	GormModel
	Name        string `gorm:"not null"`
	Description string
	UserID      uuid.UUID    `gorm:"not null"`
	User        UserDB       `gorm:"foreignKey:UserID"`
	Tasks       []TodoTaskDB `gorm:"foreignKey:GoalID"`
	Progress    int          `gorm:"not null; default:0"`
	TargetDate  time.Time
	Streak      int `gorm:"not null; default:0"`
}

func (GoalDB) TableName() string {
	return "goals"
}
