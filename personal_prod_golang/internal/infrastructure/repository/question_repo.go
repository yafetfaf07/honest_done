package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	dbmodels "github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database/db_models"
	"gorm.io/gorm"
)

type questionRepository struct {
	db *gorm.DB
}

func NewQuestionRepo(db *gorm.DB) *questionRepository {
	return &questionRepository{db: db}
}


func(q *questionRepository) Create(ctx context.Context, question *entities.Question)(*entities.Question, error) {
	question_db:=dbmodels.QuestionDB{
		Text: question.Text,
		TodoId: uuid.MustParse(question.TodoId),
		
	}
	question_db.ID=uuid.New()
	if err := q.db.WithContext(ctx).Create(&question_db).Error; err != nil {
		return nil, err
	}
	return &entities.Question{
		Text: question_db.Text,
		ID: question_db.ID.String(),
		TodoId: question_db.TodoId.String(),
	}, nil
}
