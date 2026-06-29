package router

import (
	"github.com/gin-gonic/gin"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
)

func SetupRouter(userHandler *handlers.Userhandler, taskHandler *handlers.TaskHandler) *gin.Engine {
	r := gin.Default()
	userApi := r.Group("/api/v1/user")
	{
		userApi.POST("/register", userHandler.Register())
	}
	taskApi:=r.Group("/api/v1/task") 
	{
		taskApi.POST("/create/:id",taskHandler.AddTaskHandler())
		taskApi.GET("/getTask/:id", taskHandler.GetTaskByUserIdHandler())
	}


	return r
}
