package usecases

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
	"github.com/yafetfaf07/personal_prod.git/internal/infrastructure/security"
)

// DI
type UserService struct {
	userRepo     interfaces.IUserRepo
	hashService  security.Bcrypt
	jwtService   *security.JWTService
}

func NewUserService(repo interfaces.IUserRepo, hashService *security.Bcrypt, jwtService *security.JWTService) *UserService {
	return &UserService{
		userRepo:    repo,
		hashService: *hashService,
		jwtService:  jwtService,
	}
}

func (u *UserService) Register(ctx context.Context, dto *dtos.CreateUser) (*dtos.CreateAndLoginResponse, error) {
	hashedPassword, err := u.hashService.HashPassword(dto.Password)
	if err != nil {
		return nil, err
	}
	userEntity := &entities.User{
		Name:     dto.Name,
		Password: hashedPassword,
		Email:    dto.Email,
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
