package usecases

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
)

var (
	NoQuestionFoundError   = errors.New("No Questions found")
	QuestionIdInvalidError = errors.New("Question id should be a valid UUID")
)

func toQuestionResponse(question *entities.Question) *dtos.GetQuestionResponse {
	options := make([]dtos.QuestionOptionResponse, 0, len(question.Options))
	for _, option := range question.Options {
		options = append(options, dtos.QuestionOptionResponse{
			ID:        option.ID,
			Text:      option.Text,
			IsCorrect: option.IsCorrect,
		})
	}
	return &dtos.GetQuestionResponse{
		ID:      question.ID,
		Text:    question.Text,
		TodoId:  question.TodoId,
		Options: options,
	}
}

// GetQuestion returns every question attached to a task. The path parameter is
// a task id despite being named :id.
func (q *QuestionService) GetQuestion(ctx context.Context, id string) ([]dtos.GetQuestionResponse, error) {
	uuidTaskId, err := uuid.Parse(id)
	if err != nil {
		return nil, QuestionIdInvalidError
	}

	question, err := q.questionRep.GetAllQuestions(ctx, uuidTaskId.String())
	if err != nil {
		return nil, err
	}
	if len(*question) == 0 {
		return nil, NoQuestionFoundError
	}

	questionResponses := make([]dtos.GetQuestionResponse, len(*question))
	for i := range *question {
		questionResponses[i] = *toQuestionResponse(&(*question)[i])
	}
	return questionResponses, nil
}
