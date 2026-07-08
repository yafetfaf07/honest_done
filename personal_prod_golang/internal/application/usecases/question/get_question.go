package usecases

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
)

var (
	NoQuestionFoundError = errors.New("No Questions found")
)
var (
	QuestionIdInvalidError = errors.New("Question id should be a valid UUID")
)

func (q *QuestionService) GetQuestion(ctx context.Context, id string) ([]dtos.GetQuestionResponse, error) {

	uuidUserId, err := uuid.Parse(id)

	if err != nil {
		return nil, QuestionIdInvalidError
	}
	question,err:=q.questionRep.GetAllQuestions(ctx,uuidUserId.String())
	if err != nil {
		return nil, err
	}
	if len(*question) == 0 {
		return nil, NoQuestionFoundError
	}
	questionResponses:= make([]dtos.GetQuestionResponse, len(*question))
	for i, q := range *question {
		questionResponses[i].ID=q.ID
		questionResponses[i].Text=q.Text
		questionResponses[i].TodoId=q.TodoId
	}
	return questionResponses, nil
}
