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
	usecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/question"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/middleware"
)

type QuestionHandler struct {
	questionService *usecase.QuestionService
}

// factory pattern

func NewQuestionHandler(questionService *usecase.QuestionService) *QuestionHandler {
	return &QuestionHandler{
		questionService: questionService,
	}
}

func (q *QuestionHandler) GetQuestionsByTodoId() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		id := c.Param("id")
		if id == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "Question id shouldn't be empty"})
			return
		}
		questions, err := q.questionService.GetQuestion(ctx, id)
		if err != nil {
			if err == usecase.NoQuestionFoundError {
				c.JSON(http.StatusNotFound, gin.H{"error": err.Error()})
				return
			}
			if err == usecase.QuestionIdInvalidError {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		c.JSON(http.StatusOK, questions)
	}
}

func (q *QuestionHandler) AddQuestion(redisClient *redis.Client) gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		var request dtos.CreateQuestionRequest
		id := c.Param("id")
		todo_id, err := uuid.Parse(id)
		if err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": "the params should be type of uuid"})
			return
		}
		if err := c.ShouldBindBodyWithJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		res, err := q.questionService.CreateQuestion(ctx, &request, todo_id.String())
		if err != nil {
			// A malformed question is the caller's mistake, not a server fault.
			if errors.Is(err, usecase.ErrNoOptionsProvided) || errors.Is(err, usecase.ErrMultipleCorrect) {
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
				return
			}
			c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			return
		}
		// Cache key is per-user and built from the concrete request path, so the
		// parameterised /getQuestion/:id has to be expanded to match.
		userId := c.GetString("user_id")
		cacheKey := middleware.CacheKey(userId, "/api/v1/question/getQuestion/"+todo_id.String())
		if err := redisClient.Del(ctx, cacheKey).Err(); err != nil {
			log.Printf("failed to invalidate question cache: %v", err)
		}
		c.JSON(http.StatusCreated, res)
	}
}
