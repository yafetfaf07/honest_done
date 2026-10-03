package entities

import "time"

type Goal struct {
	ID          string
	Name        string
	Description string
	TargetDate  time.Time
	Streak      int
	Progress    int
	UserId      string
}
