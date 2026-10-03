package dtos

import "time"

const (
	TaskStatusPending   = "pending"
	TaskStatusCompleted = "completed"
)

type CreateTask struct {
	Title        string    `json:"title" binding:"required"`
	ScheduleTime time.Time `json:"schedule_time" binding:"required"`
	CompleteTime time.Time `json:"complete_time"`
}

type GetTasks struct {
	Id           string    `json:"id"`
	Title        string    `json:"title"`
	ScheduleTime time.Time `json:"schedule_time"`
	CompleteTime time.Time `json:"complete_time"`
	Status       string    `json:"status"`
	GoalId       string    `json:"goal_id"`
}
