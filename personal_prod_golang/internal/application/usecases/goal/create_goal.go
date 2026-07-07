package usecases

import (
	"context"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
)

type GoalService struct {
	goalRep interfaces.IGoalRepo
}
func NewGoalService(goalRep interfaces.IGoalRepo) *GoalService {
	return &GoalService{goalRep: goalRep}
}

func(g *GoalService) CreateGoal(ctx context.Context, dto *dtos.CreateGoalRequest, userId string ) (*dtos.GetGoal,error) {

	goalEntity:= &entities.Goal{
		Name:        dto.Name,
		Description: dto.Description,
		TargetDate:  dto.TargetDate,
		UserId:      userId,
		
	}
	goal,err := g.goalRep.Create(ctx,goalEntity); 
	if err != nil {
		return nil, err
	}
	return &dtos.GetGoal{
		Name:        goal.Name,
		Description: goal.Description,
		TargetDate:  goal.TargetDate,
	}, nil
}
