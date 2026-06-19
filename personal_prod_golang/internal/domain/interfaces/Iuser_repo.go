package interfaces

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
)

type UserRepo interface {
	Create(ctx context.Context, user *entities.User) (*entities.User, error)
}
