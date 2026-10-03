package usecases

import (
	"context"
	"errors"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
)

type TaskService struct {
	taskRep interfaces.ITaskRepo
}

var (
	ErrScheduleTimeConflict = errors.New("schedule time conflict")
	ErrGoalIdEmpty          = errors.New("goal id shouldn't be empty")
	ErrUserIdEmpty          = errors.New("user id shouldn't be empty")
	ErrGoalForbidden        = errors.New("goal does not belong to this user")
	ErrGoalNotFound         = errors.New("goal not found")
)

func NewTaskService(repo interfaces.ITaskRepo) *TaskService {
	return &TaskService{
		taskRep: repo,
	}
}

func (t *TaskService) CreateTask(ctx context.Context, dto *dtos.CreateTask, goalId string, userId string) (*dtos.GetTasks, error) {

	if goalId == "" {
		return nil, ErrGoalIdEmpty
	}

	if userId == "" {
		return nil, ErrUserIdEmpty
	}

	// goalId arrives as a path parameter, so without this check any
	// authenticated user could create tasks inside someone else's goal.
	ownerId, err := t.taskRep.GetUserIdByGoalId(ctx, goalId)
	if err != nil {
		if errors.Is(err, interfaces.ErrNotFound) {
			return nil, ErrGoalNotFound
		}
		return nil, err
	}
	if ownerId != userId {
		return nil, ErrGoalForbidden
	}

	taskEntity := &entities.Task{
		Title:         dto.Title,
		ScheduleTime:  dto.ScheduleTime,
		CompletedTime: dto.CompleteTime,
		GoalID:        goalId,
		// Set explicitly rather than leaning on the column default, so the value
		// written and the value returned can never disagree.
		Status: dtos.TaskStatusPending,
	}
	task, err := t.taskRep.CreateTask(ctx, taskEntity)
	if err != nil {
		if errors.Is(err, ErrScheduleTimeConflict) {
			return nil, ErrScheduleTimeConflict
		}
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
