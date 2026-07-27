package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	usecases "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/user"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/security"
)

type Userhandler struct {
	userService *usecases.UserService
	jwtService  *security.JWTService
}

func NewUserHandler(service *usecases.UserService, jwtService *security.JWTService) *Userhandler {
	return &Userhandler{
		userService: service,
		jwtService:  jwtService,
	}
}

func (u *Userhandler) Register() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		var request dtos.CreateUser
		if err := c.ShouldBindBodyWithJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		res, err := u.userService.Register(ctx, &request)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": err})
			return
		}

		setRefreshTokenCookie(c, res.RefreshToken)
		c.JSON(http.StatusCreated, gin.H{
			"id":           res.ID,
			"name":         res.Name,
			"email":        res.Email,
			"access_token": res.AccessToken,
		})
	}
}

func (u *Userhandler) Login() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()
		var request dtos.LoginUser
		if err := c.ShouldBindBodyWithJSON(&request); err != nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
		}
		res, err := u.userService.Login(ctx, &request)
		if err != nil {
			c.JSON(http.StatusUnauthorized, gin.H{"error": err.Error()})
			return
		}

		setRefreshTokenCookie(c, res.RefreshToken)
		c.JSON(http.StatusOK, gin.H{
			"id":           res.ID,
			"name":         res.Name,
			"email":        res.Email,
			"access_token": res.AccessToken,
		})
	}
}

func (u *Userhandler) Refresh() gin.HandlerFunc {
	return func(c *gin.Context) {
		refreshToken, err := c.Cookie("refresh_token")
		if err != nil || refreshToken == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Refresh token not found"})
			return
		}

		claims, err := u.jwtService.ValidateToken(refreshToken, "refresh")
		if err != nil {
			statusCode := http.StatusUnauthorized
			message := "Invalid refresh token"
			if err == security.ErrTokenExpired {
				message = "Token expired please login"
			}
			c.JSON(statusCode, gin.H{"error": message})
			return
		}

		userId, ok := claims["user_id"].(string)
		if !ok {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Invalid token claims"})
			return
		}

		newAccessToken, err := u.jwtService.GenerateAccessToken(userId)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate access token"})
			return
		}

		c.JSON(http.StatusOK, gin.H{
			"access_token": newAccessToken,
		})
	}
}

func (u *Userhandler) Logout() gin.HandlerFunc {
	return func(c *gin.Context) {
		c.SetCookie("refresh_token", "", -1, "/", "", false, true)
		c.JSON(http.StatusOK, gin.H{"message": "Logged out successfully"})
	}
}

func setRefreshTokenCookie(c *gin.Context, refreshToken string) {
	c.SetCookie(
		"refresh_token",
		refreshToken,
		7*24*60*60,
		"/api/v1/user/refresh",
		"",
		false,
		true,
	)
}
