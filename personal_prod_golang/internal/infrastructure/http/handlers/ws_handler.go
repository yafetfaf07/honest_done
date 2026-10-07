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

// Connect upgrades an authenticated request to a WebSocket.
//
// The user id is taken from the access token that AuthMiddleWare validated and
// stored on the context. It previously came from a `user_id` query parameter on
// an unauthenticated route, which let anyone subscribe to another user's
// reminders.
func (h *WsHandler) Connect() gin.HandlerFunc {
	return func(c *gin.Context) {
		userID, ok := c.Get("user_id")
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authenticated user"})
			return
		}
		userId, ok := userID.(string)
		if !ok || userId == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Missing authenticated user"})
			return
		}

		// Upgrade HTTP connection to WebSocket
		conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
		if err != nil {
			log.Printf("Failed to upgrade WebSocket for user %s: %v", userId, err)
			return
		}

		// Register connection
		client := h.connManager.AddConnection(userId, conn)
		log.Printf("User %s connected via WebSocket", userId)

		// Listen for messages and cleanup on disconnect
		go func() {
			defer func() {
				h.connManager.RemoveConnectionIf(userId, client)
				conn.Close()
				log.Printf("User %s disconnected", userId)
			}()

			for {
				messageType, message, err := conn.ReadMessage()
				if err != nil {
					if websocket.IsUnexpectedCloseError(err, websocket.CloseGoingAway, websocket.CloseAbnormalClosure) {
						log.Printf("WebSocket error: %v", err)
					}
					break
				}

				// Echo back or handle incoming messages. Routed through the
				// client so the echo shares the write lock with notification
				// pushes; two concurrent writers corrupt the frame stream.
				err = client.WriteMessage(messageType, message)
				if err != nil {
					break
				}
			}
		}()
	}
}
