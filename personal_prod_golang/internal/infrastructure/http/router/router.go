package router

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
)

func SetupRouter(userHandler *handlers.Userhandler, taskHandler *handlers.TaskHandler, goalHandler *handlers.GoalHandler) *gin.Engine {
	r := gin.Default()

	r.GET("/ping", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"message": "Hello World"})
	})

	userApi := r.Group("/api/v1/user")
	{
		userApi.POST("/register", userHandler.Register())
	}
	taskApi := r.Group("/api/v1/task")
	{
		taskApi.POST("/create/:goal_id", taskHandler.AddTaskHandler())
		taskApi.GET("/getTask/:id", taskHandler.GetTaskByUserIdHandler())
	}
	goalApi := r.Group("/api/v1/goal")
	{
		goalApi.POST("/create/:id", goalHandler.AddGoalHandler())
		goalApi.GET("/getGoal/:id", goalHandler.GetGoalsByUserIdHandler())
	}
	questionApi := r.Group("/api/v1/question")
	{
		questionApi.POST("/create/:id",)
	}

	return r
}
