package usecases

import (
	"context"
	"errors"

	"github.com/google/uuid"
)

var (
	ErrGoalIdEmpty   = errors.New("goal id shouldn't be empty")
	ErrGoalForbidden = errors.New("goal does not belong to this user")
)

// DeleteGoal removes a goal owned by the given user, together with its tasks
// and questions.
func (g *GoalService) DeleteGoal(ctx context.Context, goalId string, userId string) error {
	if goalId == "" {
		return ErrGoalIdEmpty
	}
	if userId == "" {
		return errors.New("user id shouldn't be empty")
	}
	if _, err := uuid.Parse(goalId); err != nil {
		return errors.New("goal id should be a valid UUID")
	}

	ownerId, err := g.goalRep.GetUserIdByGoalId(ctx, goalId)
	if err != nil {
		return err
	}
	if ownerId != userId {
		return ErrGoalForbidden
	}

	return g.goalRep.DeleteById(ctx, goalId)
}
