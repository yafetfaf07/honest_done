package dtos

import "time"

type CreateGoalRequest struct {
	Name        string    `json:"name" binding:"required"`
	Description string    `json:"description"`
	TargetDate  time.Time `json:"target_date" binding:"required"`
}

type GetGoal struct {
	Id          string    `json:"id"`
	Name        string    `json:"name"`
	Description string    `json:"description"`
	TargetDate  time.Time `json:"target_date"`
	// Progress is derived from the goal's tasks rather than read from the
	// goals.progress column, which nothing in the codebase ever wrote to.
	Progress           int `json:"progress"`
	TaskCount          int `json:"task_count"`
	CompletedTaskCount int `json:"completed_task_count"`
}
