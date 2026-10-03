package interfaces

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
)

type ITaskRepo interface {
	CreateTask(ctx context.Context, task *entities.Task) (*entities.Task, error)
	GetTaskByUserId(ctx context.Context, userId string) (*[]entities.Task, error)
	FindTasksWithin5Minutes(ctx context.Context) (*[]entities.Task, error)
	GetUserIdByTaskId(ctx context.Context, taskID string) (string, error)
	GetUserIdByGoalId(ctx context.Context, goalId string) (string, error)
	UpdateTaskStatus(ctx context.Context, taskID string, status string) (*entities.Task, error)
	DeleteById(ctx context.Context, taskId string) error
}
