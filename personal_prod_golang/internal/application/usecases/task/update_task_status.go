package usecases

import (
	"context"
	"errors"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
)

var (
	ErrTaskIdEmpty   = errors.New("task id shouldn't be empty")
	ErrTaskNotFound  = errors.New("task not found")
	ErrTaskForbidden = errors.New("task does not belong to this user")
	ErrInvalidStatus = errors.New(`status must be "` + dtos.TaskStatusPending + `" or "` + dtos.TaskStatusCompleted + `"`)
)

// SetTaskCompleted marks a task done or reopens it. This is what the checkbox
// in the client's task list needs: previously a task's completion state could
// only ever be fixed at creation time.
func (t *TaskService) SetTaskCompleted(ctx context.Context, taskId string, userId string, completed bool) (*dtos.GetTasks, error) {
	if taskId == "" {
		return nil, ErrTaskIdEmpty
	}
	if userId == "" {
		return nil, ErrUserIdEmpty
	}

	ownerId, err := t.taskRep.GetUserIdByTaskId(ctx, taskId)
	if err != nil {
		return nil, err
	}
	if ownerId != userId {
		return nil, ErrTaskForbidden
	}

	status := dtos.TaskStatusPending
	if completed {
		status = dtos.TaskStatusCompleted
	}

	task, err := t.taskRep.UpdateTaskStatus(ctx, taskId, status)
	if err != nil {
		return nil, err
	}

	return &dtos.GetTasks{
		Id:           task.ID,
		Title:        task.Title,
		ScheduleTime: task.ScheduleTime,
		CompleteTime: task.CompletedTime,
		Status:       task.Status,
		GoalId:       task.GoalID,
	}, nil
}

// DeleteTask removes a task owned by the given user.
func (t *TaskService) DeleteTask(ctx context.Context, taskId string, userId string) error {
	if taskId == "" {
		return ErrTaskIdEmpty
	}
	if userId == "" {
		return ErrUserIdEmpty
	}

	ownerId, err := t.taskRep.GetUserIdByTaskId(ctx, taskId)
	if err != nil {
		return err
	}
	if ownerId != userId {
		return ErrTaskForbidden
	}

	return t.taskRep.DeleteById(ctx, taskId)
}
