package middleware

import (
	"net/http"
	"strings"

	"github.com/gin-gonic/gin"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/security"
)

func AuthMiddleWare(jwtService *security.JWTService) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Authorization header is missing"})
			c.Abort()
			return
		}

		tokenString := strings.TrimPrefix(authHeader, "Bearer ")
		if tokenString == "" || tokenString == authHeader {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Authorization"})
			c.Abort()
			return
		}

		claims, err := jwtService.ValidateToken(tokenString, "access")
		if err != nil {
			statusCode := http.StatusUnauthorized
			message := "Invalid token"
			if err == security.ErrTokenExpired {
				message = "Access token expired"
			}
			c.JSON(statusCode, gin.H{"error": message})
			c.Abort()
			return
		}

		userId, ok := claims["user_id"].(string)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			c.Abort()
			return
		}

		c.Set("user_id", userId)
		c.Next()
	}
}
