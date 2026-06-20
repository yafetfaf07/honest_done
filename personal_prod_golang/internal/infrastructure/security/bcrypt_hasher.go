package security

import "golang.org/x/crypto/bcrypt"

type Bcrypt struct {
	round int
}

//  factory function 

func NewBcrypt() *Bcrypt{
	return &Bcrypt{
		round: bcrypt.DefaultCost,
	}
}


func(b *Bcrypt) HashPassword(password string) (string,error) {
		bytes, err := bcrypt.GenerateFromPassword([]byte(password), b.round)
		if err!=nil {
			return "",err
		}
	return string(bytes),nil
}

func(b *Bcrypt) ComparePassword(hashedPassword,plainPassword string) error {

	err:=bcrypt.CompareHashAndPassword([]byte(hashedPassword), []byte(plainPassword))
if err!=nil {
	return err
}
return nil
}