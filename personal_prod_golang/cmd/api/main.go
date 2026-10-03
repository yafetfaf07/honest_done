package main

import (
	"context"
	"log"

	"github.com/yafetfaf07/personal_prod.git/internal/application/services"
	goalusecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/goal"
	questionusecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/question"
	taskusecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/task"
	userusecase "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/user"

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
	redisInit, err := database.InitRedis(cfg.RedisAddr)
	if err != nil {
		log.Fatalf("An error occured during connection to redis %v", err)

	}
	defer redisInit.Close()
	hashService := security.NewBcrypt()
	jwtService := security.NewJWTService(cfg.JWTSecret)

	// Use case passed repo as DI
	userRepo := repository.NewUserRepo(db)
	userUsecase := userusecase.NewUserService(userRepo, hashService, jwtService)
	userHandler := handlers.NewUserHandler(userUsecase, jwtService)

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

	// Initialize connection manager for WebSocket
	connManager := handlers.NewConnectionManager()

	// websocket handler with connection manager
	websocketHandler := handlers.NewWsHandler(connManager)

	// Initialize notification service
	notificationService := services.NewNotificationService(taskRepo, connManager)

	// Start the background task reminder scheduler
	go notificationService.StartTaskReminderScheduler(context.Background())

	r := router.SetupRouter(userHandler, taskHandler, goalHandler, questionHandler, redisInit, websocketHandler, jwtService)
	log.Printf("Server running on port %s", cfg.Port)
	if err := r.Run(":" + cfg.Port); err != nil {
		log.Fatalf("Failed to start server: %v", err)
	}

}
