package usecases

import (
	"context"
	"errors"
	"math"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
)

var NoGoalsFoundError = errors.New("No Goals yet!")
var UserIdInvalidError = errors.New("User id should be a valid UUID")

func (g *GoalService) GetGoalByUserId(ctx context.Context, userId string) ([]dtos.GetGoal, error) {
	if userId == "" {
		return nil, errors.New("User id shouldn't be empty")
	}

	uuidUserId, err := uuid.Parse(userId)
	if err != nil {
		return nil, UserIdInvalidError
	}

	goals, err := g.goalRep.GetGoalByUserId(ctx, uuidUserId.String())
	if err != nil {
		return nil, err
	}

	if len(goals) == 0 {
		return nil, NoGoalsFoundError
	}

	goalIds := make([]string, 0, len(goals))
	for _, goal := range goals {
		goalIds = append(goalIds, goal.ID)
	}
	counts, err := g.goalRep.GetTaskCountsByGoalIds(ctx, goalIds)
	if err != nil {
		return nil, err
	}

	countByGoalId := make(map[string]entities.GoalTaskCounts, len(counts))
	for _, count := range counts {
		countByGoalId[count.GoalID] = count
	}

	goalDto := make([]dtos.GetGoal, len(goals))
	for i, goal := range goals {
		count := countByGoalId[goal.ID]
		goalDto[i] = dtos.GetGoal{
			Id:                 goal.ID,
			Name:               goal.Name,
			Description:        goal.Description,
			TargetDate:         goal.TargetDate,
			Progress:           ProgressFromTasks(count.Completed, count.Total),
			TaskCount:          count.Total,
			CompletedTaskCount: count.Completed,
		}
	}
	return goalDto, nil
}

// ProgressFromTasks derives a 0-100 percentage from task tallies. A goal with no
// tasks reports 0 rather than dividing by zero.
func ProgressFromTasks(completed int, total int) int {
	if total <= 0 {
		return 0
	}
	if completed < 0 {
		completed = 0
	}
	if completed > total {
		completed = total
	}
	return int(math.Round(float64(completed) / float64(total) * 100))
}
