package dbmodels

type UserDB struct {
	Name     string
	Email    string `gorm:"index"`
	Password string
	gormModel
}
