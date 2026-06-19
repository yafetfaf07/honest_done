package dbmodels

type UserDB struct {
	Name     string
	Email    string `gorm:"index"`
	Password string
	GormModel
}


func(UserDB) TableName() string{
	return "users"
}