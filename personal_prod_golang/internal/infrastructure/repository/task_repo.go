package repository

import (
	"context"
	"log"
	"time"

	"github.com/google/uuid"
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

func (t *TaskRepository) CreateTask(ctx context.Context, task *entities.Task) (*entities.Task, error) {

	schedule_time, err := time.Parse(layout, task.ScheduleTime)
	if err != nil {
		log.Fatal("schedule time should be a type of time ")
	}
	completed_time, err := time.Parse(layout, task.CompletedTime)
	if err != nil {
		log.Fatal("completed time should be a type of time ")
	}

	task_db := dbmodels.TodoTaskDB{
		Title:         task.Title,
		ScheduleTime:  schedule_time,
		CompletedTime: &completed_time,
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
		ScheduleTime:  task_db.ScheduleTime.String(),
		CompletedTime: task_db.CompletedTime.String(),
		Status:        task_db.Status,
		UserId:        task.UserId,
	}

	return task_entity, nil
}
