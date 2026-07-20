package router

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/middleware"
)

func SetupRouter(userHandler *handlers.Userhandler, taskHandler *handlers.TaskHandler, goalHandler *handlers.GoalHandler, questionHandler *handlers.QuestionHandler, redisClient *redis.Client, wsHandler *handlers.WsHandler) *gin.Engine {
	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "Hello World"})
	})
	wsApi:=r.Group("/api/v1")
	 {
		wsApi.GET("/ws",wsHandler.Connect())
	}
	userApi := r.Group("/api/v1/user")
	{
		userApi.POST("/register", userHandler.Register())
	}
	taskApi := r.Group("/api/v1/task")
	{
		taskApi.POST("/create/:goal_id", taskHandler.AddTaskHandler(redisClient))
		taskApi.GET("/getTask/:id", middleware.RedisCacheMiddleWare(redisClient, 5*time.Minute), taskHandler.GetTaskByUserIdHandler())
	}
	goalApi := r.Group("/api/v1/goal")
	{
		goalApi.POST("/create/:id", goalHandler.AddGoalHandler(redisClient))
		goalApi.GET("/getGoal/:id", middleware.RedisCacheMiddleWare(redisClient, 5*time.Minute), goalHandler.GetGoalsByUserIdHandler())
	}
	questionApi := r.Group("/api/v1/question")
	{
		questionApi.POST("/create/:id", questionHandler.AddQuestion(redisClient))
		questionApi.GET("/getQuestion/:id ", middleware.RedisCacheMiddleWare(redisClient,5*time.Minute),questionHandler.GetQuestionsByTodoId())
	}

	return r
}
