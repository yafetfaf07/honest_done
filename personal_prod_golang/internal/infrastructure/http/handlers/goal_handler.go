package handlers

import (
	"context"
	"errors"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	usecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/goal"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/middleware"
)

type GoalHandler struct {
	goalService *usecase.GoalService
}

// factory pattern
func NewGoalHandler(goalService *usecase.GoalService) *GoalHandler {
	return &GoalHandler{goalService: goalService}
}

func (h *GoalHandler) AddGoalHandler(redis *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		var request dtos.CreateGoalRequest
		userId := c.GetString("user_id")

		if err := c.ShouldBindBodyWithJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		res, err := h.goalService.CreateGoal(ctx, &request, userId)

		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		if err := redis.Del(ctx, middleware.CacheKey(userId, goalListCachePath)).Err(); err != nil {
			log.Printf("Failed to delete cache: %v\n", err)
		}

		c.JSON(http.StatusCreated, res)
	}
}

// DeleteGoalHandler removes a goal and everything under it.
func (h *GoalHandler) DeleteGoalHandler(redis *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		goalId := c.Param("id")
		userId := c.GetString("user_id")

		if err := h.goalService.DeleteGoal(ctx, goalId, userId); err != nil {
			switch {
			case errors.Is(err, usecase.ErrGoalForbidden):
				c.JSON(http.StatusForbidden, gin.H{"error": err.Error()})
			case errors.Is(err, usecase.ErrGoalIdEmpty):
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			default:
				c.JSON(http.StatusNotFound, gin.H{"error": "goal not found"})
			}
			return
		}

		// Deleting a goal deletes its tasks, so the task list cache is stale too.
		keys := []string{
			middleware.CacheKey(userId, goalListCachePath),
			middleware.CacheKey(userId, taskListCachePath),
		}
		if err := redis.Del(ctx, keys...).Err(); err != nil {
			log.Printf("failed to invalidate goal cache: %v", err)
		}
		c.JSON(http.StatusOK, gin.H{"message": "goal deleted"})
	}
}

func (h *GoalHandler) GetGoalsByUserIdHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		userId := c.GetString("user_id")

		res, err := h.goalService.GetGoalByUserId(ctx, userId)
		if err != nil {
			// "No goals yet" is a normal state, not a failure. Returning 200 with
			// an empty list keeps the client from having to tell an empty
			// account apart from a broken server.
			if errors.Is(err, usecase.NoGoalsFoundError) {
				c.JSON(http.StatusOK, []dtos.GetGoal{})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, res)
	}
}
