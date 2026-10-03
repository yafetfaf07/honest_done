package usecases

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
)

var (
	NoTaskFoundError = errors.New("No tasks yet!")
)
var (
	UserIdInvalidError = errors.New("Invalid user id")
)
var (
	UserIdEmptyError = errors.New("User id shouldn't be empty")
)

func (t *TaskService) GetTask(ctx context.Context, userId string) ([]dtos.GetTasks, error) {
	if userId == "" {
		// Was log.Fatalf, which terminated the whole process on a bad request.
		return nil, UserIdEmptyError
	}

	uuidUserId, err := uuid.Parse(userId)
	if err != nil {
		return nil, UserIdInvalidError
	}

	var taskDto []dtos.GetTasks
	tasks, err := t.taskRep.GetTaskByUserId(ctx, uuidUserId.String())
	if err != nil {
		return nil, err
	}
	if len(*tasks) == 0 {
		return nil, NoTaskFoundError
	}
	taskDto = make([]dtos.GetTasks, len(*tasks))
	for i, task := range *tasks {
		taskDto[i].Id = task.ID
		taskDto[i].Title = task.Title
		taskDto[i].CompleteTime = task.CompletedTime
		taskDto[i].ScheduleTime = task.ScheduleTime
		taskDto[i].Status = task.Status
		taskDto[i].GoalId = task.GoalID
	}

	return taskDto, nil

}
