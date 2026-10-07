package services

import (
	"context"
	"log"
	"sync"
	"time"

	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/http/handlers"
)

type NotificationService struct {
	taskRepo          interfaces.ITaskRepo
	connManager       *handlers.ConnectionManager
	mu                sync.Mutex
	sentNotifications map[string]bool // Track sent notifications by taskID
}

type TaskNotification struct {
	Type         string    `json:"type"`
	TaskID       string    `json:"task_id"`
	Title        string    `json:"title"`
	Message      string    `json:"message"`
	ScheduleTime time.Time `json:"schedule_time"`
	Timestamp    time.Time `json:"timestamp"`
}

func NewNotificationService(
	taskRepo interfaces.ITaskRepo,
	connManager *handlers.ConnectionManager,
) *NotificationService {
	return &NotificationService{
		taskRepo:          taskRepo,
		connManager:       connManager,
		sentNotifications: make(map[string]bool),
	}
}

// StartTaskReminderScheduler runs in a goroutine and checks tasks every minute
func (ns *NotificationService) StartTaskReminderScheduler(ctx context.Context) {
	ticker := time.NewTicker(10 * time.Second)
	defer ticker.Stop()

	log.Println("Task reminder scheduler started")

	for {
		select {
		case <-ctx.Done():
			log.Println("Task reminder scheduler stopped")
			return
		case <-ticker.C:
			ns.checkAndNotifyTasks(ctx)
		}
	}
}

func (ns *NotificationService) checkAndNotifyTasks(ctx context.Context) {
	// Find tasks within 5 minutes
	tasks, err := ns.taskRepo.FindTasksWithin5Minutes(ctx)
	if err != nil {
		log.Printf("Error finding tasks: %v", err)
		return
	}

	if tasks == nil || len(*tasks) == 0 {
		return
	}

	for _, task := range *tasks {
		// Skip if already notified
		if ns.isAlreadyNotified(task.ID) {
			continue
		}

		// Connections are registered under a user id, so resolve task -> goal ->
		// user. This used to return the goal id, which never matched a
		// registered connection, so no reminder was ever delivered.
		userId, err := ns.taskRepo.GetUserIdByTaskId(ctx, task.ID)
		if err != nil {
			log.Printf("Error getting owner for task %s: %v", task.ID, err)
			continue
		}

		// Create notification.
		//
		// Both timestamps are normalised to UTC so the payload carries a single
		// convention. ScheduleTime arrives from a timestamptz column and Timestamp
		// was previously local, which made the two disagree by the server's UTC
		// offset (3h here) in their RFC3339 suffixes even though both denoted the
		// correct instant.
		notification := TaskNotification{
			Type:         "task_reminder",
			TaskID:       task.ID,
			Title:        task.Title,
			Message:      "Task starting in 5 minutes",
			ScheduleTime: task.ScheduleTime.UTC(),
			Timestamp:    time.Now().UTC(),
		}

		// Send to connected user
		err = ns.connManager.SendNotification(userId, notification)
		if err != nil {
			log.Printf("Error sending notification to user %s: %v", userId, err)
		} else {
			log.Printf("Notification sent to user %s for task %s", userId, task.ID)
		}

		// Mark as notified
		ns.markAsNotified(task.ID)
	}
}

func (ns *NotificationService) isAlreadyNotified(taskID string) bool {
	ns.mu.Lock()
	defer ns.mu.Unlock()
	return ns.sentNotifications[taskID]
}

func (ns *NotificationService) markAsNotified(taskID string) {
	ns.mu.Lock()
	defer ns.mu.Unlock()
	ns.sentNotifications[taskID] = true
}

// Optional: Clear old notifications after task completion
func (ns *NotificationService) ClearNotification(taskID string) {
	ns.mu.Lock()
	defer ns.mu.Unlock()
	delete(ns.sentNotifications, taskID)
}
