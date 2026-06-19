package repository

import (
	"context"
	dbmodels "github.com/yafetfaf07/personal_prod.git/internal/infrastructure/database/db_models"
	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

// factory function 

func NewUserRepo( db *gorm.DB) *UserRepository{
	return &UserRepository{
		db: db,
	}
}
// More better to return the database models
func(u *UserRepository) RegisterUser(ctx context.Context, user *dbmodels.UserDB) (*dbmodels.UserDB,error){
	user_db:=dbmodels.UserDB{
		Name: user.Name,
		Email: user.Email,
		Password: user.Password,


	}
	err:=u.db.Create(&user_db).Error

	if err!=nil {
		return nil,err
	}
	return &user_db,nil


}