package repository

import (
	"context"
	"errors"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
	dbmodels "github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database/db_models"
	"gorm.io/gorm"
)

type goalRepository struct {
	db *gorm.DB
}

func NewGoalRepo(db *gorm.DB) *goalRepository {
	return &goalRepository{db: db}
}

func (g *goalRepository) Create(ctx context.Context, goal *entities.Goal) (*entities.Goal, error) {
	goal_id, err := uuid.Parse(goal.UserId)
	if err != nil {
		return nil, err
	}
	goal_db := dbmodels.GoalDB{
		Name:        goal.Name,
		Description: goal.Description,
		UserID:      goal_id,
		TargetDate:  goal.TargetDate,
	}
	goal_db.ID = uuid.New()
	if err := g.db.WithContext(ctx).Create(&goal_db).Error; err != nil {
		return nil, err
	}
	return &entities.Goal{
		ID:          goal_db.ID.String(),
		Name:        goal_db.Name,
		Description: goal_db.Description,
		UserId:      goal_db.UserID.String(),
		TargetDate:  goal_db.TargetDate,
		Streak:      goal_db.Streak,
		Progress:    goal_db.Progress,
	}, nil
}

// GetUserIdByGoalId resolves the owning user for a goal, used to authorise
// writes that address a goal by id.
func (t *goalRepository) GetUserIdByGoalId(ctx context.Context, goalId string) (string, error) {
	uuidGoalId, err := uuid.Parse(goalId)
	if err != nil {
		return "", err
	}
	var goal dbmodels.GoalDB
	if err := t.db.WithContext(ctx).Where("id = ?", uuidGoalId).First(&goal).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return "", interfaces.ErrNotFound
		}
		return "", err
	}
	return goal.UserID.String(), nil
}

// GetTaskCountsByGoalIds tallies total and completed tasks per goal in a single
// grouped query. Goal progress is derived from these tallies rather than from
// the goals.progress column, which was never written to by any code path.
func (t *goalRepository) GetTaskCountsByGoalIds(ctx context.Context, goalIds []string) ([]entities.GoalTaskCounts, error) {
	if len(goalIds) == 0 {
		return []entities.GoalTaskCounts{}, nil
	}

	ids := make([]uuid.UUID, 0, len(goalIds))
	for _, id := range goalIds {
		parsed, err := uuid.Parse(id)
		if err != nil {
			continue
		}
		ids = append(ids, parsed)
	}
	if len(ids) == 0 {
		return []entities.GoalTaskCounts{}, nil
	}

	type countRow struct {
		GoalID    uuid.UUID
		Total     int
		Completed int
	}

	var rows []countRow
	err := t.db.WithContext(ctx).
		Model(&dbmodels.TodoTaskDB{}).
		Select("goal_id, COUNT(*) AS total, COUNT(*) FILTER (WHERE status = ?) AS completed", "completed").
		Where("goal_id IN ?", ids).
		Group("goal_id").
		Scan(&rows).Error
	if err != nil {
		return nil, err
	}

	counts := make([]entities.GoalTaskCounts, 0, len(rows))
	for _, row := range rows {
		counts = append(counts, entities.GoalTaskCounts{
			GoalID:    row.GoalID.String(),
			Total:     row.Total,
			Completed: row.Completed,
		})
	}
	return counts, nil
}

// DeleteById removes a goal and everything hanging off it. The child tables are
// cleared explicitly because there are no ON DELETE CASCADE constraints, so
// deleting only the goal row would leave orphaned tasks and questions behind.
func (t *goalRepository) DeleteById(ctx context.Context, goalId string) error {
	uuidGoalId, err := uuid.Parse(goalId)
	if err != nil {
		return err
	}

	return t.db.WithContext(ctx).Transaction(func(tx *gorm.DB) error {
		taskSubQuery := tx.Model(&dbmodels.TodoTaskDB{}).
			Select("id").
			Where("goal_id = ?", uuidGoalId)

		questionSubQuery := tx.Model(&dbmodels.QuestionDB{}).
			Select("id").
			Where("todo_id IN (?)", taskSubQuery)

		if err := tx.Where("question_id IN (?)", questionSubQuery).
			Delete(&dbmodels.QuestionOptionDB{}).Error; err != nil {
			return err
		}
		if err := tx.Where("todo_id IN (?)", taskSubQuery).
			Delete(&dbmodels.QuestionDB{}).Error; err != nil {
			return err
		}
		if err := tx.Where("goal_id = ?", uuidGoalId).
			Delete(&dbmodels.TodoTaskDB{}).Error; err != nil {
			return err
		}
		return tx.Where("id = ?", uuidGoalId).Delete(&dbmodels.GoalDB{}).Error
	})
}

func (t *goalRepository) GetGoalByUserId(ctx context.Context, userId string) ([]entities.Goal, error) {
	var goals []dbmodels.GoalDB
	goalsEntity := make([]entities.Goal, 0, len(goals))
	err := t.db.WithContext(ctx).Where("user_id = ?", userId).Find(&goals).Error
	if err != nil {
		return nil, err
	}

	for _, goal := range goals {
		goalsEntity = append(goalsEntity, entities.Goal{
			ID:          goal.ID.String(),
			Name:        goal.Name,
			Description: goal.Description,
			TargetDate:  goal.TargetDate,
			Streak:      goal.Streak,
			Progress:    goal.Progress,
		})
	}
	return goalsEntity, nil
}
