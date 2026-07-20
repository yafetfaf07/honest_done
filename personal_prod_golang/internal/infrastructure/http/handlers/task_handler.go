package handlers

import (
	"context"
	"errors"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/redis/go-redis/v9"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	usecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/task"
)

type TaskHandler struct {
	taskService *usecase.TaskService
}

// factory pattern

func NewTaskHandler(service *usecase.TaskService) *TaskHandler {
	return &TaskHandler{
		taskService: service,
	}
}

func (t *TaskHandler) AddTaskHandler(redis *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {

		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		var request dtos.CreateTask
		id := c.Param("goal_id")
		goal_id, err := uuid.Parse(id)

		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "the params should be type of uuid"})
			return
		}

		if err := c.ShouldBindBodyWithJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		res, err := t.taskService.CreateTask(ctx, &request, goal_id.String())

		if err != nil {
			if errors.Is(err, usecase.ErrScheduleTimeConflict) {
				c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"Unknown error happened": err.Error()})
			return
		}
		err = redis.Del(ctx, "/api/v1/task/getTask/"+id).Err()
		if err != nil {
			log.Println("Falied to delete cache ")

		}
		c.JSON(http.StatusCreated, res)
	}
}

func (t *TaskHandler) GetTaskByUserIdHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		userId := c.Param("id")
		tasks, err := t.taskService.GetTask(ctx, userId)

		if err != nil {
			if errors.Is(err, usecase.UserIdInvalidError) {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
			if errors.Is(err, usecase.NoTaskFoundError) {
				c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, tasks)
	}
}
