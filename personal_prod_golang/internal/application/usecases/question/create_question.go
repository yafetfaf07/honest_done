package usecases

import (
	"context"
	"errors"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
)

var (
	ErrNoOptionsProvided = errors.New("a question needs at least one option")
	ErrMultipleCorrect   = errors.New("a question can only have one correct option")
)

type QuestionService struct {
	questionRep interfaces.IQuestionRepo
}

func NewQuestionService(questionRep interfaces.IQuestionRepo) *QuestionService {
	return &QuestionService{
		questionRep: questionRep,
	}
}

func (q *QuestionService) CreateQuestion(ctx context.Context, dto *dtos.CreateQuestionRequest, todoId string) (*dtos.GetQuestionResponse, error) {
	options := make([]entities.QuestionOption, 0, len(dto.Options))
	correctCount := 0
	for _, option := range dto.Options {
		if option.IsCorrect {
			correctCount++
		}
		options = append(options, entities.QuestionOption{
			Text:      option.Text,
			IsCorrect: option.IsCorrect,
		})
	}

	if len(options) > 0 && correctCount != 1 {
		return nil, ErrMultipleCorrect
	}
	if len(options) == 0 {
		return nil, ErrNoOptionsProvided
	}

	question_entity := entities.Question{
		Text:    dto.Name,
		TodoId:  todoId,
		Options: options,
	}
	question, err := q.questionRep.Create(ctx, &question_entity)
	if err != nil {
		return nil, err
	}
	return toQuestionResponse(question), nil
}
