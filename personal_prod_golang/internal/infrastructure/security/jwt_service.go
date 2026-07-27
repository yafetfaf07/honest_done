package security

import (
	"errors"
	"time"

	"github.com/golang-jwt/jwt"
)

var (
	ErrTokenExpired = errors.New("token expired please login")
	ErrInvalidToken = errors.New("invalid token")
	ErrInvalidClaims = errors.New("invalid token claims")
	ErrUnexpectedSigningMethod = errors.New("unexpected signing method")
	ErrMismatchedTokenType = errors.New("mismatched token type")
)

type JWTService struct {
	secretKey        []byte
	accessTokenTTL  time.Duration
	refreshTokenTTL time.Duration
}

func NewJWTService(secret string) *JWTService {
	return &JWTService{
		secretKey:        []byte(secret),
		accessTokenTTL:  15 * time.Minute,
		refreshTokenTTL: 7 * 24 * time.Hour,
	}
}

func (j *JWTService) GenerateAccessToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"user_id":    userID,
		"token_type": "access",
		"exp":        time.Now().Add(j.accessTokenTTL).Unix(),
		"iat":        time.Now().Unix(),
	}
	return j.signToken(claims)
}

func (j *JWTService) GenerateRefreshToken(userID string) (string, error) {
	claims := jwt.MapClaims{
		"user_id":    userID,
		"token_type": "refresh",
		"exp":        time.Now().Add(j.refreshTokenTTL).Unix(),
		"iat":        time.Now().Unix(),
	}
	return j.signToken(claims)
}

func (j *JWTService) ValidateToken(tokenString string, expectedType string) (jwt.MapClaims, error) {
	token, err := jwt.Parse(tokenString, func(token *jwt.Token) (interface{}, error) {
		if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
			return nil, ErrUnexpectedSigningMethod
		}
		return j.secretKey, nil
	})
	if err != nil {
		if ve, ok := err.(*jwt.ValidationError); ok {
			if ve.Errors&jwt.ValidationErrorExpired != 0 {
				return nil, ErrTokenExpired
			}
		}
		return nil, ErrInvalidToken
	}

	claims, ok := token.Claims.(jwt.MapClaims)
	if !ok || !token.Valid {
		return nil, ErrInvalidToken
	}

	tokenType, ok := claims["token_type"].(string)
	if !ok || tokenType != expectedType {
		return nil, ErrMismatchedTokenType
	}

	return claims, nil
}

func (j *JWTService) signToken(claims jwt.MapClaims) (string, error) {
	token := jwt.NewWithClaims(jwt.SigningMethodHS256, claims)
	return token.SignedString(j.secretKey)
}
