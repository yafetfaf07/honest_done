package repository

import (
	"context"
	"errors"
	"strings"
	"time"

	"github.com/google/uuid"
	"github.com/jackc/pgx/v5/pgconn"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	usecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/task"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
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

// findTaskByScheduleTime checks for a slot clash within a single goal. The
// check is scoped to the goal on purpose: a global check would mean one user's
// 09:00 task blocks every other user from booking 09:00. GORM excludes
// soft-deleted rows from the count, so a deleted task frees its slot.
func (t *taskRepository) findTaskByScheduleTime(ctx context.Context, goalID uuid.UUID, scheduleTime time.Time) bool {
	var count int64
	// Convert to UTC for comparison
	scheduleTimeUTC := scheduleTime.UTC()
	err := t.db.WithContext(ctx).Model(&dbmodels.TodoTaskDB{}).
		Where("goal_id = ? AND schedule_time = ?", goalID, scheduleTimeUTC).
		Count(&count).Error
	if err != nil {
		return false
	}
	return count > 0
}

// isUniqueViolation reports whether err is a Postgres unique-constraint failure
// (SQLSTATE 23505).
func isUniqueViolation(err error) bool {
	if err == nil {
		return false
	}
	var pgErr *pgconn.PgError
	if errors.As(err, &pgErr) {
		return pgErr.Code == "23505"
	}
	// GORM's translated error string, for drivers that do not surface PgError.
	return strings.Contains(err.Error(), "duplicate key value")
}

func (t *taskRepository) CreateTask(ctx context.Context, task *entities.Task) (*entities.Task, error) {

	goal_id, err := uuid.Parse(task.GoalID)
	if err != nil {
		return nil, err
	}

	if t.findTaskByScheduleTime(ctx, goal_id, task.ScheduleTime) {
		return nil, usecase.ErrScheduleTimeConflict
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
		// The pre-insert clash check and this insert are not atomic, so two
		// concurrent requests for the same slot can both pass the check and one
		// loses on the unique index. Surface that as the same conflict error
		// rather than a 500.
		if isUniqueViolation(err) {
			return nil, usecase.ErrScheduleTimeConflict
		}
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

func (t *taskRepository) GetTaskByUserId(ctx context.Context, userId string) (*[]entities.Task, error) {
	var tasks []dbmodels.TodoTaskDB
	// Tasks do not carry a user id. Ownership is reached through the parent
	// goal, so filter on goals.user_id rather than todo_tasks.goal_id.
	err := t.db.WithContext(ctx).
		Joins("JOIN goals ON goals.id = todo_tasks.goal_id").
		Where("goals.user_id = ?", userId).
		Find(&tasks).Error
	if err != nil {
		return nil, err
	}

	tasksEntity := make([]entities.Task, 0, len(tasks))
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

// GetUserIdByTaskId resolves the owning user for a task by walking task -> goal
// -> user. The previous version returned the goal id, which is what caused
// reminders to be published to a connection key no client ever registers under.
func (t *taskRepository) GetUserIdByTaskId(ctx context.Context, taskID string) (string, error) {
	var userId string
	err := t.db.WithContext(ctx).
		Model(&dbmodels.TodoTaskDB{}).
		Select("goals.user_id").
		Joins("JOIN goals ON goals.id = todo_tasks.goal_id").
		Where("todo_tasks.id = ?", taskID).
		Scan(&userId).Error
	if err != nil {
		return "", err
	}
	if userId == "" {
		return "", usecase.ErrTaskNotFound
	}
	return userId, nil
}

// GetUserIdByGoalId resolves the owning user for a goal, used to authorise
// writes that address a goal by id.
func (t *taskRepository) GetUserIdByGoalId(ctx context.Context, goalId string) (string, error) {
	var goal dbmodels.GoalDB
	if err := t.db.WithContext(ctx).Where("id = ?", goalId).First(&goal).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return "", interfaces.ErrNotFound
		}
		return "", err
	}
	return goal.UserID.String(), nil
}

// UpdateTaskStatus flips a task between pending and completed. completed_time is
// stamped on completion and zeroed on reopen so the two states cannot disagree.
func (t *taskRepository) UpdateTaskStatus(ctx context.Context, taskID string, status string) (*entities.Task, error) {
	uuidTaskId, err := uuid.Parse(taskID)
	if err != nil {
		return nil, err
	}

	var completedAt time.Time
	if status == dtos.TaskStatusCompleted {
		completedAt = time.Now().UTC()
	}

	var task dbmodels.TodoTaskDB
	err = t.db.WithContext(ctx).
		Model(&dbmodels.TodoTaskDB{}).
		Where("id = ?", uuidTaskId).
		Updates(map[string]interface{}{
			"status":         status,
			"completed_time": completedAt,
		}).
		First(&task).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, usecase.ErrTaskNotFound
		}
		return nil, err
	}

	return &entities.Task{
		ID:            task.ID.String(),
		Title:         task.Title,
		ScheduleTime:  task.ScheduleTime.UTC(),
		CompletedTime: task.CompletedTime.UTC(),
		Status:        task.Status,
		GoalID:        task.GoalID.String(),
	}, nil
}

// DeleteById removes a task along with the questions and options attached to it.
func (t *taskRepository) DeleteById(ctx context.Context, taskId string) error {
	uuidTaskId, err := uuid.Parse(taskId)
	if err != nil {
		return err
	}

	return t.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		questionSubQuery := tx.Model(&dbmodels.QuestionDB{}).
			Select("id").
			Where("todo_id = ?", uuidTaskId)

		if err := tx.Where("question_id IN (?)", questionSubQuery).
			Delete(&dbmodels.QuestionOptionDB{}).Error; err != nil {
			return err
		}
		if err := tx.Where("todo_id = ?", uuidTaskId).
			Delete(&dbmodels.QuestionDB{}).Error; err != nil {
			return err
		}
		return tx.Where("id = ?", uuidTaskId).Delete(&dbmodels.TodoTaskDB{}).Error
	})
}
