package main

import (
	"fmt"

	"github.com/gin-gonic/gin"
	usecases "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/user"
	"github.com/yafetfaf07/personal_prod.git/internal/config"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/repository"
)
func init() {
	
}
func main() {
	cfg,err:=config.Load()

	if err!=nil {
		fmt.Errorf("Unable to load config",err.Error())
	}

	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		fmt.Errorf("An error occured during connection of database", err.Error())
	}
	// redisInit, err := database.InitRedis(os.Getenv("REDIS_ADDR"))
	// if err != nil {
	// 	fmt.Errorf("An error occured during connection to redis", err)

	// }

	// Repo passed DB as DI
	userRepo := repository.NewUserRepo(db)

	// Use case passed repo as DI
	userUsecase := usecases.NewUserService(userRepo)
	userHandler := handlers.NewUserHandler(userUsecase)
	var router *gin.Engine = gin.Default()

	router.POST("/register", userHandler.Register())
	router.Run(":"+cfg.Port)

}
