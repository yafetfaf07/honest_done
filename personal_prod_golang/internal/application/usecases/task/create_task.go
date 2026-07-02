package usecases

import (
	"context"
	"errors"
	"log"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
)

type TaskService struct {
	taskRep interfaces.ITaskRepo
}
var(ErrScheduleTimeConflict = errors.New("schedule time conflict")
)
func NewTaskService(repo interfaces.ITaskRepo) *TaskService {
	return &TaskService{
		taskRep: repo,
	}
}

func (t *TaskService) CreateTask(ctx context.Context, dto *dtos.CreateTask, goalId string) (*dtos.GetTasks, error) {

	if goalId=="" {
		log.Fatalf("User Id shouldn't be null")
		
	}
	
	taskEntity := &entities.Task{
		Title:         dto.Title,
		ScheduleTime:  dto.ScheduleTime,
		CompletedTime: dto.CompleteTime,
		GoalID:        goalId,
	}
	task, err := t.taskRep.CreateTask(ctx, taskEntity)
	if err != nil {
		if errors.Is(err, ErrScheduleTimeConflict) {
			return nil, ErrScheduleTimeConflict
		}
		return nil, err
	}

	return &dtos.GetTasks{
		Id: task.ID,
		Title: task.Title,
		ScheduleTime: task.ScheduleTime,
		CompleteTime: task.CompletedTime,
	}, nil
}
