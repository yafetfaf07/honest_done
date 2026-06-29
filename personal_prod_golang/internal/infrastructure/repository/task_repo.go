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

func (t *TaskRepository) FindTaskByScheduleTime(ctx context.Context, scheduleTime time.Time) bool {
	var count int64
	err := t.db.WithContext(ctx).Model(&dbmodels.TodoTaskDB{}).Where("schedule_time = ?", scheduleTime).Count(&count).Error
	if err != nil {
		return false
	}
	return count > 0
}

func (t *TaskRepository) CreateTask(ctx context.Context, task *entities.Task) (*entities.Task, error) {

	tasks := t.FindTaskByScheduleTime(ctx, task.ScheduleTime)

	if tasks {
		return nil, usecase.ErrScheduleTimeConflict
	}
user_id,err:=uuid.Parse(task.UserId)
if err!=nil {
	return nil,err
}
	task_db := dbmodels.TodoTaskDB{
		Title:         task.Title,
		ScheduleTime:  task.ScheduleTime,
		CompletedTime: task.CompletedTime,
		UserId:       user_id,
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

func (t *TaskRepository) GetTaskByUserId(ctx context.Context, userId string) (*[]entities.Task, error) {
	var tasks []dbmodels.TodoTaskDB
	 tasksEntity := make([]entities.Task, 0, len(tasks))
	err := t.db.WithContext(ctx).Where("user_id = ?", userId).Find(&tasks).Error
	if err != nil {
		return nil, err
	}

	for _, task := range tasks {
		tasksEntity = append(tasksEntity, entities.Task{
			ID:            task.ID.String(),
			Title:         task.Title,
			ScheduleTime:  task.ScheduleTime,
			CompletedTime: task.CompletedTime,
			Status:        task.Status,
			UserId:        task.UserId.String(),
		})
	}
	return &tasksEntity, nil
}
