package handlers

import (
	"context"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/yafetfaf07/personal_prod.git/internal/application/dtos"
	usecases "github.com/yafetfaf07/personal_prod.git/internal/application/usecases/user"
)

// handler should import from the usecase as DI
type Userhandler struct {
userService *usecases.UserService
}


// factory function 

func NewUserHandler(service *usecases.UserService) *Userhandler {
	return &Userhandler{
userService: service,
	}
}

func(u *Userhandler) Register() gin.HandlerFunc {
return func(c *gin.Context) {
	ctx,cancel:=context.WithTimeout(c.Request.Context(),5*time.Second)
	defer cancel()
	var request dtos.CreateUser
	if err:=c.ShouldBindBodyWithJSON(&request); err!=nil {
			c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
			return
	}
	res,err:=u.userService.Register(ctx,&request)
	if err!=nil {
		c.JSON(http.StatusInternalServerError,gin.H{"error":err})
		return
	}
	c.JSON(http.StatusCreated,res)

}
}
