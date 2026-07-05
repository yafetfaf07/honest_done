package dtos

import "time"

type CreateGoalRequest struct {
	Name        string `json:"name"`
	Description string `json:"description"`
	TargetDate time.Time `json:"target_date" binding:"required"`

}

type GetGoal struct {
	Id          string `json:"id"`
	Name        string `json:"name"`
	Description string `json:"description"`
	TargetDate time.Time `json:"target_date"`
}