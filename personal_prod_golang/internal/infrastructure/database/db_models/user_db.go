package dbmodels
type User struct{
	Name string;
	Email string `gorm:"index"`;
	Password string;
	GormModel
}