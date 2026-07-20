package interfaces

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
)

type ITaskRepo interface {
	CreateTask(ctx context.Context, task *entities.Task) (*entities.Task, error)
	GetTaskByUserId(ctx context.Context, userId string) (*[]entities.Task, error)
	FindTasksWithin5Minutes(ctx context.Context) (*[]entities.Task, error)
	GetGoalOwnerByTaskId(ctx context.Context, taskID string) (string, error)
}
