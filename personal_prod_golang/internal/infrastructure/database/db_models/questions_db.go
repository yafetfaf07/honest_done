package dbmodels

import "github.com/google/uuid"
type QuestionDB struct {
	GormModel
	Text string `gorm:"not null"`
	QuestionOptions []QuestionOptionDB `gorm:"foreignKey:QuestionID"`
	TodoId uuid.UUID `gorm:"not null"`
	TodoTaskDB TodoTaskDB `gorm:"foreignKey:TodoId"`
}
