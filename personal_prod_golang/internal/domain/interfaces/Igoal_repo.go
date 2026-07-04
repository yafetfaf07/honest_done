package interfaces

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
)

type IGoalRepo interface {
	Create(ctx context.Context, goal *entities.Goal) (*entities.Goal, error)
	GetGoalByUserId(ctx context.Context, userId string)([]entities.Goal,error)
}