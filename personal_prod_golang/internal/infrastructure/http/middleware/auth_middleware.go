package middleware

import (
	"fmt"
	"net/http"
	"strings"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/golang-jwt/jwt"
	"github.com/yafetfaf07/personal_prod.git/internal/config"
)

func AuthMiddleWare(cfg *config.Config) gin.HandlerFunc {
	return func(c *gin.Context) {
		authHeader := c.GetHeader("Authorization")
		if authHeader == "" {
			c.JSON(401, gin.H{"error": "Authorization header is missing"})
		// this is for closing any susbsequent middleware coming in
			c.Abort()
			return
		}
		tokenString:=strings.TrimPrefix(authHeader,"Bearer ")
	
		if tokenString=="" || tokenString==authHeader {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid Authorization"})
			c.Abort()
			return
		}
		token,err:=jwt.Parse(tokenString, func(token *jwt.Token) (any,error) {
			if token.Method.Alg()!=jwt.SigningMethodHS256.Alg() {
				return nil,fmt.Errorf("Unexpected SigningMethod %v",token.Header["alg"])
			}
			return []byte("hsadsa123#$"), nil
		})
		if err != nil ||!token.Valid {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token"})
			c.Abort()
			return
		}
		claims, ok := token.Claims.(jwt.MapClaims)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			c.Abort()
			return
		}
		userId, ok := claims["user_id"].(string)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			c.Abort()
			return
		}
		if exp,ok:=claims["exp"].(float64); ok{
			expirationTime:=time.Unix(int64(exp),0)
			if time.Now().After(expirationTime) {
				c.JSON(http.StatusUnauthorized, gin.H{"error": "Token expired"})
				c.Abort()
				return
			}
		}
		c.Set("user_id",userId)
		c.Next()
		
	}
}