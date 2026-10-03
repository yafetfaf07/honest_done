package handlers

import (
	"context"
	"errors"
	"net/http"
	"strings"
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
			switch {
			case errors.Is(err, usecases.ErrEmailAlreadyExists):
				c.JSON(http.StatusConflict, gin.H{"error": err.Error()})
			case errors.Is(err, usecases.ErrInvalidEmail),
				errors.Is(err, usecases.ErrInvalidPassword):
				c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			default:
				c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
			}
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
		// Match the normalisation used at registration, otherwise the lookup
		// misses an account registered as Foo@Bar.com.
		request.Email = strings.ToLower(strings.TrimSpace(request.Email))

		res, err := u.userService.Login(ctx, &request)
		if err != nil {
			// Distinguishing "no such user" from "wrong password" would leak
			// which emails are registered, so both stay a flat 401.
			c.JSON(http.StatusUnauthorized, gin.H{"error": "invalid email or password"})
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

		// A browser sends the http-only cookie automatically. A native client
		// has no cookie jar, so it reads the set-cookie header itself and sends
		// the token back in the body instead.
		if err != nil || refreshToken == "" {
			var body dtos.RefreshTokenRequest
			if bindErr := c.ShouldBindBodyWithJSON(&body); bindErr == nil {
				refreshToken = body.RefreshToken
			}
		}

		if refreshToken == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "Refresh token not found"})
			return
		}

		claims, err := u.jwtService.ValidateToken(refreshToken, "refresh")
		if err != nil {
			message := "Invalid refresh token"
			if err == security.ErrTokenExpired {
				message = "Token expired please login"
			}
			c.JSON(http.StatusUnauthorized, gin.H{"error": message})
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

		// Rotate the refresh token on every use so a captured one has a short
		// useful life.
		newRefreshToken, err := u.jwtService.GenerateRefreshToken(userId)
		if err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "Failed to generate refresh token"})
			return
		}
		setRefreshTokenCookie(c, newRefreshToken)

		c.JSON(http.StatusOK, gin.H{
			"access_token":  newAccessToken,
			"refresh_token": newRefreshToken,
		})
	}
}

// Me returns the authenticated user's profile, so the client can restore a
// session without relying on whatever the login response cached.
func (u *Userhandler) Me() gin.HandlerFunc {
	return func(c *gin.Context) {
		ctx, cancel := context.WithTimeout(c.Request.Context(), 5*time.Second)
		defer cancel()

		userId := c.GetString("user_id")
		if userId == "" {
			c.JSON(http.StatusUnauthorized, gin.H{"error": "unauthenticated"})
			return
		}

		res, err := u.userService.GetMe(ctx, userId)
		if err != nil {
			c.JSON(http.StatusNotFound, gin.H{"error": "user not found"})
			return
		}
		c.JSON(http.StatusOK, res)
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
