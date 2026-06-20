package repository

import (
	"context"
	"github.com/google/uuid" 
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	dbmodels "github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database/db_models"
	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepo(db *gorm.DB) *UserRepository {
	return &UserRepository{
		db: db,
	}
}


func (u *UserRepository) Create(ctx context.Context, user *entities.User) (*entities.User, error) {
	user_db := dbmodels.UserDB{
		Name:     user.Name,
		Email:    user.Email,
		Password: user.Password,
	}
	user_db.ID = uuid.New()
	err := u.db.WithContext(ctx).Create(&user_db).Error
	if err != nil {
		return nil, err
	}
	
	user_entity := &entities.User{
		// Note: Ensure `user_db.ID.UUID.String()` correctly resolves to a string 
		// based on the specific UUID library you are using.
		ID:       user_db.ID.String(),
		Name:     user_db.Name,
		Email:    user_db.Email,
		Password: user_db.Password,
	}

	return user_entity, nil
} 