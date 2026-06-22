package dbmodels

type UserDB struct {
	Name     string `gorm:"not null"`
	Email    string `gorm:"index"`
	Password string `gorm:"not null"`
	Tasks []TodoTaskDB `gorm:"foreignKey:UserId"`
	GormModel
}


func(UserDB) TableName() string{
	return "users"
}