package dbmodels

import "github.com/google/uuid"
type SelectedQuestionOptionDB struct {
	GormModel
	QuestionID uuid.UUID `gorm:"not null"`
	OptionID   uuid.UUID `gorm:"not null"`

	Question   QuestionDB `gorm:"foreignKey:QuestionID"`
	Option     QuestionOptionDB   `gorm:"foreignKey:OptionID"`
	
}

func (SelectedQuestionOptionDB) TableName() string {
	return "selected_question_options"
}