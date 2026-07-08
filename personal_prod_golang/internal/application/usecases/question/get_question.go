package usecases

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
)

var (
	NoGoalsFoundError = errors.New("No Questions found")
)
var (
	QuestionIdInvalidError = errors.New("Question id should be a valid UUID")
)

func (q *QuestionService) GetQuestion(ctx context.Context, id string) (*dtos.GetQuestionResponse, error) {
	if id=="" {
		return nil, errors.New("Question id shouldn't be empty")
	}
	uuidUserId, err := uuid.Parse(id)

	if err != nil {
		return nil, QuestionIdInvalidError
	}
}
