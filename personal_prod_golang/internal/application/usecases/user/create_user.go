package usecases

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/interfaces"
)

type userservice struct {
	userRepo interfaces.UserRepo
}

func NewUserService(repo interfaces.UserRepo) userservice {
	return userservice{
		userRepo: repo,
	}
}

func (u *userservice) Register(ctx context.Context, dto *dtos.CreateUser) (*dtos.CreateAndLoginResponse, error) {
	// Map the DTO to their respective entities

	userEntity := &entities.User{
		Name:     dto.Name,
		Password: dto.Password,
		Email:    dto.Email,
	}
	// Call repo pass entity then get back entity for user id purposes
	savedUser, err := u.userRepo.Create(ctx, userEntity)
	if err != nil {
		return nil, err
	}
	return &dtos.CreateAndLoginResponse{
		ID:    savedUser.ID,
		Name:  savedUser.Name,
		Email: savedUser.Email,
	}, nil
}
