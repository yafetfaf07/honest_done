package usecase

import (
	"context"
	"errors"
	"log"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
)


var(NoTaskFoundError=errors.New("No tasks yet!"))
var(UserIdInvalidError=errors.New("Invalid user id"))
func(t *TaskService) GetTask(ctx context.Context, userId string )([]dtos.GetTasks,error) {
	if userId=="" {
		log.Fatalf("User Id shouldn't be null")
	}

	uuidUserId, err := uuid.Parse(userId)
	if err != nil {
		return nil, UserIdInvalidError
	}
	
var taskDto []dtos.GetTasks
	tasks,err:=t.taskRep.GetTaskByUserId(ctx,uuidUserId.String())
	if err!=nil {
		return nil,err
	}
	if len(*tasks)==0 {
		return nil,NoTaskFoundError
	}
	taskDto=make([]dtos.GetTasks,len(*tasks))
	for i,task:=range *tasks{
		taskDto[i].Id=task.ID
		taskDto[i].Title=task.Title
		taskDto[i].CompleteTime=task.CompletedTime
		taskDto[i].ScheduleTime=task.ScheduleTime
	}

	return taskDto,nil
	
}