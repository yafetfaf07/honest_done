package usecases

import (
	"context"
	"errors"
	"net/mail"
	"strings"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/security"
)

var (
	ErrEmailAlreadyExists = errors.New("an account with that email already exists")
	ErrInvalidEmail       = errors.New("a valid email address is required")
	ErrInvalidPassword    = errors.New("password must be between 8 and 72 characters")
)

func isValidEmail(email string) bool {
	_, err := mail.ParseAddress(email)
	return err == nil
}

// DI
type UserService struct {
	userRepo    interfaces.IUserRepo
	hashService security.Bcrypt
	jwtService  *security.JWTService
}

func NewUserService(repo interfaces.IUserRepo, hashService *security.Bcrypt, jwtService *security.JWTService) *UserService {
	return &UserService{
		userRepo:    repo,
		hashService: *hashService,
		jwtService:  jwtService,
	}
}

func (u *UserService) Register(ctx context.Context, dto *dtos.CreateUser) (*dtos.CreateAndLoginResponse, error) {
	email := strings.ToLower(strings.TrimSpace(dto.Email))
	if !isValidEmail(email) {
		return nil, ErrInvalidEmail
	}

	exists, err := u.userRepo.UserExists(ctx, email)
	if err != nil {
		return nil, err
	}
	if exists {
		return nil, ErrEmailAlreadyExists
	}

	// bcrypt truncates beyond 72 bytes, and anything shorter than 8 characters
	// is too weak to be worth hashing. Reject both instead of silently
	// accepting a password whose tail had no effect.
	if len(dto.Password) < 8 || len(dto.Password) > 72 {
		return nil, ErrInvalidPassword
	}

	hashedPassword, err := u.hashService.HashPassword(dto.Password)
	if err != nil {
		return nil, err
	}
	userEntity := &entities.User{
		Name:     strings.TrimSpace(dto.Name),
		Password: hashedPassword,
		Email:    email,
	}

	savedUser, err := u.userRepo.Create(ctx, userEntity)
	if err != nil {
		return nil, err
	}

	accessToken, err := u.jwtService.GenerateAccessToken(savedUser.ID)
	if err != nil {
		return nil, err
	}

	refreshToken, err := u.jwtService.GenerateRefreshToken(savedUser.ID)
	if err != nil {
		return nil, err
	}

	return &dtos.CreateAndLoginResponse{
		ID:           savedUser.ID,
		Name:         savedUser.Name,
		Email:        savedUser.Email,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
