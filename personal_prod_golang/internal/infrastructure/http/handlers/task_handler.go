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
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/middleware"
)

type TaskHandler struct {
	taskService *usecase.TaskService
}

func NewTaskHandler(service *usecase.TaskService) *TaskHandler {
	return &TaskHandler{
		taskService: service,
	}
}

const (
	taskListCachePath = "/api/v1/task/getTask"
	goalListCachePath = "/api/v1/goal/getGoal"
)

func (t *TaskHandler) AddTaskHandler(redis *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		var request dtos.CreateTask
		userId := c.GetString("user_id")
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
		res, err := t.taskService.CreateTask(ctx, &request, goal_id.String(), userId)

		if err != nil {
			switch {
			case errors.Is(err, usecase.ErrGoalForbidden):
				c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			case errors.Is(err, usecase.ErrScheduleTimeConflict):
				c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
			case errors.Is(err, usecase.ErrGoalIdEmpty), errors.Is(err, usecase.ErrUserIdEmpty):
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			case errors.Is(err, usecase.ErrGoalNotFound):
				c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			default:
				c.JSON(http.StatusInternalServerError, gin.H{"Unknown error happened": err.Error()})
			}
			return
		}
		invalidateTaskCache(ctx, redis, userId)
		c.JSON(http.StatusCreated, res)
	}
}

func (t *TaskHandler) GetTaskByUserIdHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		userId := c.GetString("user_id")
		tasks, err := t.taskService.GetTask(ctx, userId)

		if err != nil {
			if errors.Is(err, usecase.UserIdInvalidError) {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
			if errors.Is(err, usecase.NoTaskFoundError) {
				// Missing return here used to fall through and write a second
				// JSON document, producing a body no strict decoder can parse.
				c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, tasks)
	}
}

// CompleteTaskHandler marks a task done.
func (t *TaskHandler) CompleteTaskHandler(redis *redis.Client) gin.HandlerFunc {
	return t.setTaskStatusHandler(redis, true)
}

// UncompleteTaskHandler reopens a completed task.
func (t *TaskHandler) UncompleteTaskHandler(redis *redis.Client) gin.HandlerFunc {
	return t.setTaskStatusHandler(redis, false)
}

func (t *TaskHandler) setTaskStatusHandler(redis *redis.Client, completed bool) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		taskId := c.Param("id")
		userId := c.GetString("user_id")

		res, err := t.taskService.SetTaskCompleted(ctx, taskId, userId, completed)
		if err != nil {
			switch {
			case errors.Is(err, usecase.ErrTaskForbidden):
				c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			case errors.Is(err, usecase.ErrTaskNotFound):
				c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			case errors.Is(err, usecase.ErrTaskIdEmpty), errors.Is(err, usecase.ErrUserIdEmpty):
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			default:
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			}
			return
		}

		invalidateTaskCache(ctx, redis, userId)
		c.JSON(http.StatusOK, res)
	}
}

// DeleteTaskHandler removes a task along with its questions.
func (t *TaskHandler) DeleteTaskHandler(redis *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		taskId := c.Param("id")
		userId := c.GetString("user_id")

		if err := t.taskService.DeleteTask(ctx, taskId, userId); err != nil {
			switch {
			case errors.Is(err, usecase.ErrTaskForbidden):
				c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			case errors.Is(err, usecase.ErrTaskNotFound):
				c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
			case errors.Is(err, usecase.ErrTaskIdEmpty), errors.Is(err, usecase.ErrUserIdEmpty):
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			default:
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			}
			return
		}

		invalidateTaskCache(ctx, redis, userId)
		c.JSON(http.StatusNoContent, nil)
	}
}

// invalidateTaskCache drops both the task list and the goal list. Goal progress
// is derived from task completion counts, so any task mutation changes the goal
// payload too; invalidating only the task cache served a stale progress value.
func invalidateTaskCache(ctx context.Context, redis *redis.Client, userId string) {
	keys := []string{
		middleware.CacheKey(userId, taskListCachePath),
		middleware.CacheKey(userId, goalListCachePath),
	}
	if err := redis.Del(ctx, keys...).Err(); err != nil {
		log.Printf("failed to invalidate task cache: %v", err)
	}
}
