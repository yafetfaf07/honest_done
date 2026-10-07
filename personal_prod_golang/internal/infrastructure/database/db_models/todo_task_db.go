package dbmodels

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

// Define the UTC+3 timezone once (3 hours * 60 minutes * 60 seconds)
var utc3Location = time.FixedZone("UTC+3", 3*60*60)

type TodoTaskDB struct {
	Title         string    `gorm:"not null"`
	ScheduleTime  time.Time `gorm:"not null; index:idx_goal_schedule,unique,priority:2,where:deleted_at IS NULL"`
	CompletedTime time.Time
	GoalID        uuid.UUID `gorm:"not null;index:idx_goal_schedule,unique,priority:1,where:deleted_at IS NULL"`
	Goal          GoalDB    `gorm:"foreignKey:GoalID"`
	// UserId   uuid.UUID `gorm:"not null"`
	Status      string `gorm:"not null;default:'pending'"`
	GormModel
}

// BeforeSave ensures the time is explicitly set to UTC+3 before writing to the DB
func (t *TodoTaskDB) BeforeSave(tx *gorm.DB) error {
	if !t.ScheduleTime.IsZero() {
		t.ScheduleTime = t.ScheduleTime.In(utc3Location)
	}
	if !t.CompletedTime.IsZero() {
		t.CompletedTime = t.CompletedTime.In(utc3Location)
	}
	return nil
}

// AfterFind ensures the time is explicitly set to UTC+3 after reading from the DB
func (t *TodoTaskDB) AfterFind(tx *gorm.DB) error {
	if !t.ScheduleTime.IsZero() {
		t.ScheduleTime = t.ScheduleTime.In(utc3Location)
	}
	if !t.CompletedTime.IsZero() {
		t.CompletedTime = t.CompletedTime.In(utc3Location)
	}
	return nil
}