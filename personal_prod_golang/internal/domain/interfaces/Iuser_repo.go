package interfaces

import (
	"context"

	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
)

type IUserRepo interface {
	Create(ctx context.Context, user *entities.User) (*entities.User, error)
	UserExists(ctx context.Context, email string) (bool, error)
	FindByEmail(ctx context.Context, email string) (*entities.User, error)
	FindById(ctx context.Context, id string) (*entities.User, error)
}
