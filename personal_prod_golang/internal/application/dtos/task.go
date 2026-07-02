package dtos

import "time"

type CreateTask struct {
	Title        string    `json:"title" binding:"required"`
	ScheduleTime time.Time `json:"schedule_time" binding:"required"`
	CompleteTime time.Time `json:"complete_time,omitzero"`
}

type GetTasks struct {
	Id           string    `json:"id" binding:"required"`
	Title        string    `json:"title" binding:"required"`
	ScheduleTime time.Time `json:"schedule_time" binding:"required"`
	CompleteTime time.Time `json:"complete_time"`
}
