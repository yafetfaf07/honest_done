package main

import (
	"log"
	"os"

	goalusecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/goal"
	taskusecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/task"
	userusecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/user"
	questionusecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/question"

	"github.com/yafetfaf07/personal_prod.git/internal/config"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/router"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/repository"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/security"
)

func main() {
	cfg, err := config.Load()

	if err != nil {
		log.Fatalf("Unable to load config %v", err)
	}

	db, err := database.Connect(cfg.DatabaseURL)
	if err != nil {
		log.Fatalf("An error occured during connection of database %v", err)

	}
	redisInit, err := database.InitRedis(os.Getenv("REDIS_ADDR"))
	if err != nil {
		log.Fatalf("An error occured during connection to redis %v", err)

	}
	defer redisInit.Close()
	hashService := security.NewBcrypt()

	// Use case passed repo as DI
	userRepo := repository.NewUserRepo(db)
	userUsecase := userusecase.NewUserService(userRepo, hashService)
	userHandler := handlers.NewUserHandler(userUsecase)

	// Repo passed DB as DI
	taskRepo := repository.NewTaskRepo(db)
	taskUsecase := taskusecase.NewTaskService(taskRepo)
	taskHandler := handlers.NewTaskHandler(taskUsecase)

	// Repo passed DB as DI
	goalRepo := repository.NewGoalRepo(db)
	goalUsecase := goalusecase.NewGoalService(goalRepo)
	goalHandler := handlers.NewGoalHandler(goalUsecase)

	// Repo passed DB as DI
	questionRepo := repository.NewQuestionRepo(db)
	questionUsecase := questionusecase.NewQuestionService(questionRepo)
	questionHandler := handlers.NewQuestionHandler(questionUsecase)

	r := router.SetupRouter(userHandler, taskHandler, goalHandler, questionHandler,redisInit)
	log.Printf("Server running on port %s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

}
