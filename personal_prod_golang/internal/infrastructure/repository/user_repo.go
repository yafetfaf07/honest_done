package repository

import (
	"context"

	"github.com/google/uuid"
	"github.com/yafetfaf07/personal_prod.git/internal/domain/entities"
	dbmodels "github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database/db_models"
	"gorm.io/gorm"
)

type userRepository struct {
	db *gorm.DB
}

func NewUserRepo(db *gorm.DB) *userRepository {
	return &userRepository{
		db: db,
	}
}

func (u *userRepository) Create(ctx context.Context, user *entities.User) (*entities.User, error) {
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
		ID:       user_db.ID.String(),
		Name:     user_db.Name,
		Email:    user_db.Email,
		Password: user_db.Password,
	}

	return user_entity, nil
}

func (u *userRepository) UserExists(ctx context.Context, email string) (bool, error) {
	var user dbmodels.UserDB
	err := u.db.WithContext(ctx).Where("email = ?", email).First(&user).Error
	if err != nil {
		if err == gorm.ErrRecordNotFound {
			return false, nil
		}
		return false, err
	}
	return true, nil
}

func (u *userRepository) FindById(ctx context.Context, id string) (*entities.User, error) {
	uuidUserId, err := uuid.Parse(id)
	if err != nil {
		return nil, err
	}
	var user dbmodels.UserDB
	if err := u.db.WithContext(ctx).Where("id = ?", uuidUserId).First(&user).Error; err != nil {
		return nil, err
	}
	return &entities.User{
		ID:    user.ID.String(),
		Name:  user.Name,
		Email: user.Email,
	}, nil
}

func (u *userRepository) FindByEmail(ctx context.Context, email string) (*entities.User, error) {
	var user dbmodels.UserDB
	err := u.db.WithContext(ctx).Where("email = ?", email).First(&user).Error
	if err != nil {
		return nil, err
	}
	return &entities.User{
		ID:       user.ID.String(),
		Name:     user.Name,
		Email:    user.Email,
		Password: user.Password,
	}, nil
}
