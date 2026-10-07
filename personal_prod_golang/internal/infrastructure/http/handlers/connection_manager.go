package handlers

import (
	"sync"

	"github.com/gorilla/websocket"
)

type ClientConnection struct {
	UserID string
	Conn   *websocket.Conn

	// gorilla/websocket permits only one concurrent writer per connection.
	// The handler's read loop echoes messages while the reminder scheduler
	// pushes notifications, so both paths must serialise through here or the
	// interleaved frames corrupt the stream.
	writeMu sync.Mutex
}

// WriteJSON sends v as a single text frame, excluding any concurrent writer.
func (c *ClientConnection) WriteJSON(v interface{}) error {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()
	return c.Conn.WriteJSON(v)
}

// WriteMessage sends an already-framed message, excluding any concurrent
// writer. Used by the handler's echo path.
func (c *ClientConnection) WriteMessage(messageType int, data []byte) error {
	c.writeMu.Lock()
	defer c.writeMu.Unlock()
	return c.Conn.WriteMessage(messageType, data)
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

// AddConnection registers conn as the active socket for userID.
//
// Connections are keyed by user, so a second device or tab silently replaces
// the first. Multi-device support would key by a connection id and index by
// user instead; that is deliberately left as a follow-up.
func (cm *ConnectionManager) AddConnection(userID string, conn *websocket.Conn) *ClientConnection {
	cm.mu.Lock()
	defer cm.mu.Unlock()
	client := &ClientConnection{
		UserID: userID,
		Conn:   conn,
	}
	cm.connections[userID] = client
	return client
}

func (cm *ConnectionManager) RemoveConnection(userID string) {
	cm.mu.Lock()
	defer cm.mu.Unlock()
	delete(cm.connections, userID)
}

// RemoveConnectionIf drops the registration only when it still points at conn.
//
// Connections are keyed by user, so when a second socket replaces the first the
// superseded one's read loop eventually exits and calls RemoveConnection. An
// unconditional delete would evict the live connection and silently stop
// reminders for that user.
func (cm *ConnectionManager) RemoveConnectionIf(userID string, conn *ClientConnection) {
	cm.mu.Lock()
	defer cm.mu.Unlock()
	if current, ok := cm.connections[userID]; ok && current == conn {
		delete(cm.connections, userID)
	}
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

	return conn.WriteJSON(notification)
}
