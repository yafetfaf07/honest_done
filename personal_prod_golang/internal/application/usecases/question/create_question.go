package usecases

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
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
	question_entity := entities.Question{
		Text:   dto.Name,
		TodoId: todoId,
	}
	question, err := q.questionRep.Create(ctx, &question_entity)
	if err != nil {
		return nil, err
	}
	return &dtos.GetQuestionResponse{
		ID:     question.ID,
		Text:   question.Text,
		TodoId: question.TodoId,
	}, nil
}
