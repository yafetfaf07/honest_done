package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
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

func (h *GoalHandler) AddGoalHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		var request dtos.CreateGoalRequest
		id := c.Param("id")
		user_id, err := uuid.Parse(id)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "the params should be type of uuid"})
			return
		}
		if err:=c.ShouldBindBodyWithJSON(&request); err!=nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		res,err:=h.goalService.CreateGoal(ctx,&request,user_id.String())

		if err!=nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusCreated, res)
	}
}

func (h *GoalHandler) GetGoalsByUserIdHandler() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		id := c.Param("id")
		user_id, err := uuid.Parse(id)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "the params should be type of uuid"})
			return
		}
		res, err := h.goalService.GetGoalByUserId(ctx, user_id.String())
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, res)
	}
}
