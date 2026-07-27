package repository

import (
	"context"

	"time"

	"github.com/google/uuid"
	usecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/task"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	dbmodels "github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database/db_models"
	"gorm.io/gorm"
)

type taskRepository struct {
	db *gorm.DB
}

const layout = time.RFC3339

// factory pattern

func NewTaskRepo(db *gorm.DB) *taskRepository {
	return &taskRepository{
		db: db,
	}
}

func (t *taskRepository) FindTaskByScheduleTime(ctx context.Context, scheduleTime time.Time) bool {
	var count int64
	// Convert to UTC for comparison
	scheduleTimeUTC := scheduleTime.UTC()
	err := t.db.WithContext(ctx).Model(&dbmodels.TodoTaskDB{}).Where("schedule_time = ?", scheduleTimeUTC).Count(&count).Error
	if err != nil {
		return false
	}
	return count > 0
}

func (t *taskRepository) CreateTask(ctx context.Context, task *entities.Task) (*entities.Task, error) {

	tasks := t.FindTaskByScheduleTime(ctx, task.ScheduleTime)

	if tasks {
		return nil, usecase.ErrScheduleTimeConflict
	}
	goal_id, err := uuid.Parse(task.GoalID)
	if err != nil {
		return nil, err
	}

	// Normalize schedule time to UTC to avoid timezone issues
	scheduleTimeUTC := task.ScheduleTime.UTC()
	completedTimeUTC := task.CompletedTime.UTC()

	task_db := dbmodels.TodoTaskDB{
		Title:         task.Title,
		ScheduleTime:  scheduleTimeUTC,
		CompletedTime: completedTimeUTC,
		GoalID:        goal_id,
		Status:        task.Status,
	}
	task_db.ID = uuid.New()
	err = t.db.WithContext(ctx).Create(&task_db).Error

	if err != nil {

		return nil, err
	}
	task_entity := &entities.Task{
		ID:            task_db.ID.String(),
		Title:         task_db.Title,
		ScheduleTime:  scheduleTimeUTC,
		CompletedTime: completedTimeUTC,
		Status:        task_db.Status,
		GoalID:        task.GoalID,
	}

	return task_entity, nil
}

func (t *taskRepository) GetTaskByUserId(ctx context.Context, goalId string) (*[]entities.Task, error) {
	var tasks []dbmodels.TodoTaskDB
	tasksEntity := make([]entities.Task, 0, len(tasks))
	err := t.db.WithContext(ctx).Where("goal_id = ?", goalId).Find(&tasks).Error
	if err != nil {
		return nil, err
	}

	for _, task := range tasks {
		tasksEntity = append(tasksEntity, entities.Task{
			ID:            task.ID.String(),
			Title:         task.Title,
			ScheduleTime:  task.ScheduleTime.UTC(),
			CompletedTime: task.CompletedTime.UTC(),
			Status:        task.Status,
			GoalID:        task.GoalID.String(),
		})
	}
	return &tasksEntity, nil
}

func (t *taskRepository) FindTasksWithin5Minutes(ctx context.Context) (*[]entities.Task, error) {
	// Use UTC for all time comparisons
	now := time.Now().UTC()
	fiveMinutesLater := now.Add(5 * time.Minute)

	var tasks []dbmodels.TodoTaskDB
	err := t.db.WithContext(ctx).
		Where("schedule_time > ? AND schedule_time <= ?", now, fiveMinutesLater).
		Where("status != ?", "completed").
		Find(&tasks).Error

	if err != nil {
		return nil, err
	}

	tasksEntity := make([]entities.Task, 0, len(tasks))
	for _, task := range tasks {
		tasksEntity = append(tasksEntity, entities.Task{
			ID:            task.ID.String(),
			Title:         task.Title,
			ScheduleTime:  task.ScheduleTime,
			CompletedTime: task.CompletedTime,
			Status:        task.Status,
			GoalID:        task.GoalID.String(),
		})
	}
	return &tasksEntity, nil
}

func (t *taskRepository) GetGoalOwnerByTaskId(ctx context.Context, taskID string) (string, error) {
	var task dbmodels.TodoTaskDB
	err := t.db.WithContext(ctx).
		Where("id = ?", taskID).
		First(&task).Error

	if err != nil {
		return "", err
	}
	return task.GoalID.String(), nil
}
