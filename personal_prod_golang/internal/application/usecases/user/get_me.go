package usecases

import (
	"context"
	"errors"

	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
)

var UserNotFoundError = errors.New("user not found")

// GetMe returns the profile for the authenticated user. There was no way to
// read the profile back before this, so the client had to cache whatever the
// login response happened to contain.
func (u *UserService) GetMe(ctx context.Context, userId string) (*dtos.MeResponse, error) {
	if userId == "" {
		return nil, errors.New("user id shouldn't be empty")
	}

	user, err := u.userRepo.FindById(ctx, userId)
	if err != nil {
		return nil, err
	}
	if user == nil {
		return nil, UserNotFoundError
	}

	return &dtos.MeResponse{
		ID:    user.ID,
		Name:  user.Name,
		Email: user.Email,
	}, nil
}
