package handlers

import (
	"context"
	"log"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	usecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/goal"
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
		err = redis.Del(ctx, "/api/v1/goal/getGoal").Err()
		if err != nil {
			log.Printf("Failed to delete cache: %v\n", err)
		}

		c.JSON(http.StatusCreated, res)
	}
}

func (h *GoalHandler) GetGoalsByUserIdHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		userId := c.GetString("user_id")

		res, err := h.goalService.GetGoalByUserId(ctx, userId)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "unknown error occured"})
			return
		}
		c.JSON(http.StatusOK, res)
	}
}
