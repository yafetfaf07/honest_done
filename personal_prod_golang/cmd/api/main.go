package main

import (
	"log"

	usecases "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/user"
	"github.com/yafetfaf07/personal_prod.git/internal/config"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/router"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/repository"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/security"
)
func init() {
	
}
func main() {
	cfg,err:=config.Load()

	if err!=nil {
		log.Fatalf("Unable to load config",err.Error())
	}

	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("An error occured during connection of database",err.Error())

	}
	// redisInit, err := database.InitRedis(os.Getenv("REDIS_ADDR"))
	// if err != nil {
	// 	fmt.Errorf("An error occured during connection to redis", err)

	// }
	hashService:=security.NewBcrypt()
	// Repo passed DB as DI
	userRepo := repository.NewUserRepo(db)

	// Use case passed repo as DI
	userUsecase := usecases.NewUserService(userRepo,hashService)
	userHandler := handlers.NewUserHandler(userUsecase)
	r:=router.SetupRouter(userHandler)
	log.Printf("Server running on port %s", cfg.Port)
	if err := r.Run(":"+cfg.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

}
