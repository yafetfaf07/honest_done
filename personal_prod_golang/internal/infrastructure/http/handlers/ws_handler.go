// internal/infrastructure/http/handlers/ws_handler.go
package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/gorilla/websocket"
)

// Define the upgrader - this converts HTTP to WS
var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
	// ⚠️ IMPORTANT: Allow all origins for development. 
	// Restrict this in production!
	CheckOrigin: func(r *http.Request) bool { return true },
}

type WsHandler struct{}

func NewWsHandler() *WsHandler {
	return &WsHandler{}
}

func (h *WsHandler) Connect() gin.HandlerFunc {
	return func(c *gin.Context) {
		// 1. Upgrade HTTP connection to WebSocket
		conn, err := upgrader.Upgrade(c.Writer, c.Request, nil)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to upgrade connection"})
			return
		}
		defer conn.Close() // Always close the connection when done

		// 2. Infinite loop to listen for messages
		for {
			messageType, message, err := conn.ReadMessage()
			if err != nil {
				// Client disconnected or error occurred
				break
			}

			// 3. Echo the message back (Basic test)
			err = conn.WriteMessage(messageType, message)
			if err != nil {
				break
			}
		}
	}
}