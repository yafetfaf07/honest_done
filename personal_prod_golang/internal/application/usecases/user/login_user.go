package usecases

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
)

func (u *UserService) EmailExists(ctx context.Context, email string) (bool, error) {
	return u.userRepo.UserExists(ctx, email)
}

func (u *UserService) Login(ctx context.Context, dto *dtos.LoginUser) (*dtos.CreateAndLoginResponse, error) {
	user, err := u.userRepo.FindByEmail(ctx, dto.Email)
	if err != nil {
		return nil, err
	}

	err = u.hashService.ComparePassword(user.Password, dto.Password)
	if err != nil {
		return nil, err
	}

	accessToken, err := u.jwtService.GenerateAccessToken(user.ID)
	if err != nil {
		return nil, err
	}

	refreshToken, err := u.jwtService.GenerateRefreshToken(user.ID)
	if err != nil {
		return nil, err
	}

	return &dtos.CreateAndLoginResponse{
		ID:           user.ID,
		Name:         user.Name,
		Email:        user.Email,
		AccessToken:  accessToken,
		RefreshToken: refreshToken,
	}, nil
}
