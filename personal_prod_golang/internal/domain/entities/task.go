package entities

import "time"

type Task struct {
	ID string
	Title string
	ScheduleTime time.Time
	CompletedTime time.Time
	Status string
	GoalID string
}