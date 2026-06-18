package dtos

import "context"

// user create dto
type CreateUser struct{
	Name string `json:"name" binding:"required"`
	Email string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}
type CreateAndLoginResponse struct{
	ID string `json:"id"`
	Name string `json:"name"`
	Email string `json:"email"`
}
// user login dto
type LoginUser struct {
	Email string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type UserUseCase interface {
Register(ctx context.Context, createUser CreateUser)(*CreateAndLoginResponse, error)
}