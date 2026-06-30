package entities

import "time"
type Goal struct {
	Name        string
	Description string
	TargetDate  time.Time
	Streak      int
	Progress    int
	UserId      string
}
