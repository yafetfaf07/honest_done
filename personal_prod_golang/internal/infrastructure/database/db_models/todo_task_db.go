package dbmodels

import (
	"time"

	"github.com/google/uuid"
)

type TodoTaskDB struct {
	Title string `gorm:"not null"`
	// Scoped per goal, not globally: a global unique index on schedule_time means
	// one user booking 09:00 blocks every other user from booking 09:00.
	//
	// The index is partial (WHERE deleted_at IS NULL) because deletion is a soft
	// delete. A plain unique index still counts tombstoned rows, so deleting a
	// task and then rebooking the same slot would fail at the database even
	// though the application's clash check ignores deleted rows.
	ScheduleTime  time.Time `gorm:"not null; index:idx_goal_schedule,unique,priority:2,where:deleted_at IS NULL"`
	CompletedTime time.Time
	GoalID        uuid.UUID `gorm:"not null;index:idx_goal_schedule,unique,priority:1,where:deleted_at IS NULL"`
	Goal          GoalDB    `gorm:"foreignKey:GoalID"`
	// UserId   uuid.UUID `gorm:"not null"`
	Status string `gorm:"not null;default:'pending'"`
	GormModel
}

func (TodoTaskDB) TableName() string {
	return "todo_tasks"
}
