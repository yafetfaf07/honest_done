package dbmodels

import "github.com/google/uuid"

type QuestionOptionDB struct {
	GormModel
	Text       string     `gorm:"not null"`
	QuestionID uuid.UUID  `gorm:"not null"`
	IsCorrect  bool       `gorm:"not null"`
	Question   QuestionDB `gorm:"foreignKey:QuestionID"`
}

func (QuestionOptionDB) TableName() string {
	return "question_options"
}
