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

type TaskRepository struct {
	db *gorm.DB
}

const layout = time.RFC3339

// factory function

func NewTaskRepo(db *gorm.DB) *TaskRepository {
	return &TaskRepository{
		db: db,
	}
}

func (t *TaskRepository) FindTaskByScheduleTime(ctx context.Context, scheduleTime time.Time) ([]*entities.Task, error) {
	var tasks []*entities.Task
	endTime := scheduleTime.Add(15 * time.Minute)
	var count int64
	err := t.db.WithContext(ctx).Where("schedule_time BETWEEN ? AND ?", scheduleTime, endTime).Limit(1).Count(&count).Find(&tasks).Error
	if err != nil {
		return nil, err
	}
	return tasks, nil
}

func (t *TaskRepository) CreateTask(ctx context.Context, task *entities.Task) (*entities.Task, error) {

	tasks, err := t.FindTaskByScheduleTime(ctx, task.ScheduleTime)
	if err != nil {
		return nil, err
	}
	if len(tasks) > 0 {
		return nil, usecase.ErrScheduleTimeConflict
	}

	task_db := dbmodels.TodoTaskDB{
		Title:         task.Title,
		ScheduleTime:  task.ScheduleTime,
		CompletedTime: task.CompletedTime,
		UserId:        uuid.MustParse(task.UserId),
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
		ScheduleTime:  task_db.ScheduleTime,
		CompletedTime: task_db.CompletedTime,
		Status:        task_db.Status,
		UserId:        task.UserId,
	}

	return task_entity, nil
}
