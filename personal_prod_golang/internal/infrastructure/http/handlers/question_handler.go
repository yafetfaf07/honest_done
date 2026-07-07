package handlers

import (
	"context"

	"github.com/gin-gonic/gin"
	usecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/question"
)
type QuestionHandler struct {
	questionService *usecase.QuestionService
}

// factory pattern

func NewQuestionHandler(questionService *usecase.QuestionService) *QuestionHandler{
	return &QuestionHandler{
		questionService: questionService,
	}
}

func (q *QuestionHandler) AddQuestion() gin.HandlerFunc{
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
	}
}
