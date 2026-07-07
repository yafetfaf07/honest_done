package interfaces

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
)

type IQuestionRepo interface {
	Create(ctx context.Context, question *entities.Question)(*entities.Question, error)
}