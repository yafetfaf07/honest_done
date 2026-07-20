package handlers

import (
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	CheckOrigin:     func(r *http.Request) bool { return true },
}

type WsHandler struct {
	connManager *ConnectionManager
}

func NewWsHandler(connManager *ConnectionManager) *WsHandler {
	return &WsHandler{
		connManager: connManager,
	}
}

func (h *WsHandler) Connect() gin.HandlerFunc {
	return func(c *gin.Context) {
		// Get user ID from query params or auth header
		userID := c.Query("user_id")
		if userID == "" {
			c.JSON(http.StatusBadRequest, gin.H{"error": "user_id is required"})
			return
		}

		// Upgrade HTTP connection to WebSocket
		conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upgrade connection"})
			return
		}

		// Register connection
		h.connManager.AddConnection(userID, conn)
		log.Printf("User %s connected via WebSocket", userID)

		// Listen for messages and cleanup on disconnect
		go func() {
			defer func() {
				h.connManager.RemoveConnection(userID)
				conn.Close()
				log.Printf("User %s disconnected", userID)
			}()

			for {
				messageType, message, err := conn.ReadMessage()
				if err != nil {
					if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
						log.Printf("WebSocket error: %v", err)
					}
					break
				}

				// Echo back or handle incoming messages
				err = conn.WriteMessage(messageType, message)
				if err != nil {
					break
				}
			}
		}()
	}
}
