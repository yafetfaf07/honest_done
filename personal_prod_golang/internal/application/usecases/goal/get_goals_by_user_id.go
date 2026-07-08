package usecases

import (
	"context"
	"errors"
	"log"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
)


var(NoGoalsFoundError=errors.New("No Goals yet!"))
var(UserIdInvalidError=errors.New("User id should be a valid UUID"))


func(g *GoalService) GetGoalByUserId(ctx context.Context, userId string)([]dtos.GetGoal,error) {
	if userId=="" {
		return nil, errors.New("User id shouldn't be empty")
	}

	uuidUserId, err := uuid.Parse(userId)
	if err != nil {
		return nil, UserIdInvalidError
	}
	var goalDto []dtos.GetGoal

	goals,err:=g.goalRep.GetGoalByUserId(ctx,uuidUserId.String())
	if err!=nil {
		return nil,err
	}

	if len(goals) ==0{
		return nil,NoGoalsFoundError
	}
	goalDto=make([]dtos.GetGoal,len(goals))
	for i,goal:=range goals{
		goalDto[i]=dtos.GetGoal{
			Id: goal.ID,
			Name:        goal.Name,
			Description: goal.Description,
			TargetDate:  goal.TargetDate,
		}
	}
	return goalDto, nil
}