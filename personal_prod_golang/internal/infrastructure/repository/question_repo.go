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

func (q *questionRepository) Create(ctx context.Context, question *entities.Question) (*entities.Question, error) {
	// Was uuid.MustParse, which panics and takes the process down on a bad id.
	todoId, err := uuid.Parse(question.TodoId)
	if err != nil {
		return nil, err
	}

	question_db := dbmodels.QuestionDB{
		Text:   question.Text,
		TodoId: todoId,
	}
	question_db.ID = uuid.New()

	if len(question.Options) > 0 {
		question_db.QuestionOptions = make([]dbmodels.QuestionOptionDB, 0, len(question.Options))
		for _, option := range question.Options {
			option_db := dbmodels.QuestionOptionDB{
				Text:       option.Text,
				QuestionID: question_db.ID,
				IsCorrect:  option.IsCorrect,
			}
			option_db.ID = uuid.New()
			question_db.QuestionOptions = append(question_db.QuestionOptions, option_db)
		}
	}

	if err := q.db.WithContext(ctx).Create(&question_db).Error; err != nil {
		return nil, err
	}

	created := &entities.Question{
		Text:    question_db.Text,
		ID:      question_db.ID.String(),
		TodoId:  question_db.TodoId.String(),
		Options: mapOptions(question_db.QuestionOptions),
	}
	return created, nil
}

func (q *questionRepository) GetAllQuestions(ctx context.Context, todoId string) (*[]entities.Question, error) {
	var questions []dbmodels.QuestionDB
	// Options have to be preloaded: without this the response never carried
	// them, so no client could render a quiz.
	if err := q.db.WithContext(ctx).
		Preload("QuestionOptions").
		Where("todo_id = ?", todoId).
		Find(&questions).Error; err != nil {
		return nil, err
	}

	questionEntities := make([]entities.Question, len(questions))
	for i, question := range questions {
		questionEntities[i].Text = question.Text
		questionEntities[i].ID = question.ID.String()
		questionEntities[i].TodoId = question.TodoId.String()
		questionEntities[i].Options = mapOptions(question.QuestionOptions)
	}
	return &questionEntities, nil
}

func mapOptions(options []dbmodels.QuestionOptionDB) []entities.QuestionOption {
	mapped := make([]entities.QuestionOption, 0, len(options))
	for _, option := range options {
		mapped = append(mapped, entities.QuestionOption{
			ID:        option.ID.String(),
			Text:      option.Text,
			IsCorrect: option.IsCorrect,
		})
	}
	return mapped
}
