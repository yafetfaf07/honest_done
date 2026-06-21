package router

import (
	"github.com/gin-gonic/gin"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
)

func SetupRouter(userHandler *handlers.Userhandler) *gin.Engine {
	r := gin.Default()
	api := r.Group("/api/v1/user")
	{
		api.POST("/register", userHandler.Register())
	}

	return r
}
