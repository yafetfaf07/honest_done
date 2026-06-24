package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	usecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/task"
)

type TaskHandler struct {
	taskService *usecase.TaskService
}

// factory pattern 

func NewTaskHandler (service *usecase.TaskService) *TaskHandler{
	return  &TaskHandler{
		taskService: service,
	}
}

func( t *TaskHandler) AddTask() gin.HandlerFunc {
	return func(c *gin.Context) {
		
		ctx,cancel:=context.WithTimeout(c.Request.Context(),5*time.Second)
		defer cancel()
		var request dtos.CreateTask
		id:=c.Param("id")

	
		if err:=c.ShouldBindBodyWithJSON(&request); err!=nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
	res,err:=t.taskService.CreateTask(ctx,&request, id)

	if err!=nil {
		c.JSON(http.StatusInternalServerError, gin.H{"Unknown error happened": err.Error()})
		return
	}
	c.JSON(http.StatusOK, res)
	}
}

