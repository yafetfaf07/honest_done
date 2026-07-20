package handlers

import (
	"sync"

	"github.com/gorilla/websocket"
)

type ClientConnection struct {
	UserID string
	Conn   *websocket.Conn
}

type ConnectionManager struct {
	mu          sync.RWMutex
	connections map[string]*ClientConnection // userID -> connection
}

func NewConnectionManager() *ConnectionManager {
	return &ConnectionManager{
		connections: make(map[string]*ClientConnection),
	}
}

func (cm *ConnectionManager) AddConnection(userID string, conn *websocket.Conn) {
	cm.mu.Lock()
	defer cm.mu.Unlock()
	cm.connections[userID] = &ClientConnection{
		UserID: userID,
		Conn:   conn,
	}
}

func (cm *ConnectionManager) RemoveConnection(userID string) {
	cm.mu.Lock()
	defer cm.mu.Unlock()
	delete(cm.connections, userID)
}

func (cm *ConnectionManager) GetConnection(userID string) *ClientConnection {
	cm.mu.RLock()
	defer cm.mu.RUnlock()
	return cm.connections[userID]
}

func (cm *ConnectionManager) GetAllConnections() map[string]*ClientConnection {
	cm.mu.RLock()
	defer cm.mu.RUnlock()
	// Return a copy to avoid race conditions
	connCopy := make(map[string]*ClientConnection)
	for k, v := range cm.connections {
		connCopy[k] = v
	}
	return connCopy
}

func (cm *ConnectionManager) SendNotification(userID string, notification interface{}) error {
	cm.mu.RLock()
	conn := cm.connections[userID]
	cm.mu.RUnlock()

	if conn == nil {
		return nil // User not connected
	}

	return conn.Conn.WriteJSON(notification)
}
