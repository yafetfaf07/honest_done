package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
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
		Name:        goal_db.Name,
		Description: goal_db.Description,
		UserId:      goal_db.UserID.String(),
		TargetDate:  goal_db.TargetDate,
		Streak:      goal_db.Streak,
		Progress:    goal_db.Progress,
	}, nil
}
func (t *taskRepository) GetGoalByUserId(ctx context.Context, userId string) (*[]entities.Goal, error) {
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
	return &goalsEntity, nil
}
