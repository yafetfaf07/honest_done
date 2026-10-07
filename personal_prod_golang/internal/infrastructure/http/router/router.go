package router

import (
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/redis/go-redis/v9"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/middleware"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/security"
)

func SetupRouter(userHandler *handlers.Userhandler, taskHandler *handlers.TaskHandler, goalHandler *handlers.GoalHandler, questionHandler *handlers.QuestionHandler, redisClient *redis.Client, wsHandler *handlers.WsHandler, jwtService *security.JWTService) *gin.Engine {
	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "Hello World"})
	})

	authMiddleware := middleware.AuthMiddleWare(jwtService)

	// Reminders are pushed over this socket, so it sits behind the same auth as
	// the REST routes and takes the user id from the validated token.
	wsApi := r.Group("/api/v1", authMiddleware)
	{
		wsApi.GET("/ws", wsHandler.Connect())
	}

	userApi := r.Group("/api/v1/user")
	{
		userApi.POST("/register", userHandler.Register())
		userApi.POST("/login", userHandler.Login())
		userApi.POST("/refresh", userHandler.Refresh())
		userApi.POST("/logout", userHandler.Logout())
		userApi.GET("/me", authMiddleware, userHandler.Me())
	}

	taskApi := r.Group("/api/v1/task")
	{
		taskApi.POST("/create/:goal_id", authMiddleware, taskHandler.AddTaskHandler(redisClient))
		taskApi.GET("/getTask", authMiddleware, middleware.RedisCacheMiddleWare(redisClient, 5*time.Minute), taskHandler.GetTaskByUserIdHandler())
		taskApi.PATCH("/:id/complete", authMiddleware, taskHandler.CompleteTaskHandler(redisClient))
		taskApi.PATCH("/:id/uncomplete", authMiddleware, taskHandler.UncompleteTaskHandler(redisClient))
		taskApi.DELETE("/:id", authMiddleware, taskHandler.DeleteTaskHandler(redisClient))
	}

	goalApi := r.Group("/api/v1/goal")
	{
		goalApi.POST("/create", authMiddleware, goalHandler.AddGoalHandler(redisClient))
		goalApi.GET("/getGoal", authMiddleware, middleware.RedisCacheMiddleWare(redisClient, 5*time.Minute), goalHandler.GetGoalsByUserIdHandler())
		goalApi.DELETE("/:id", authMiddleware, goalHandler.DeleteGoalHandler(redisClient))
	}

	questionApi := r.Group("/api/v1/question")
	{
		questionApi.POST("/create/:id", authMiddleware, questionHandler.AddQuestion(redisClient))
		questionApi.GET("/getQuestion/:id", authMiddleware, middleware.RedisCacheMiddleWare(redisClient, 5*time.Minute), questionHandler.GetQuestionsByTodoId())
	}

	return r
}
