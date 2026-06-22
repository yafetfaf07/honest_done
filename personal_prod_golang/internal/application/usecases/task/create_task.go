package usecase

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	// "github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
)

type TaskService struct{
	taskRep interfaces.ITaskRepo

}

func NewTaskService(repo interfaces.ITaskRepo) *TaskService {
	return &TaskService{
		taskRep: repo,
	}
}

func(t *TaskService) CreateTask(ctx context.Context, dto *dtos.CreateTask)(*dtos.GetTasks,error) {

// 	taskEntity:=&entities.Task{
// Title: dto.Title,
// ScheduleTime: dto.ScheduleTime.Format(""),
// CompletedTime: dto.CompleteTime.Format(),
// 	}
return nil,nil
}
