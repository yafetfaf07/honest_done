package dbmodels

type UserDB struct {
	Name string `gorm:"not null"`
	// Unique and partial: without it, registering the same email twice silently
	// creates two accounts, and login then resolves to an arbitrary one. The
	// partial predicate keeps a soft-deleted account from blocking reuse.
	Email    string   `gorm:"uniqueIndex:idx_users_email,where:deleted_at IS NULL"`
	Password string   `gorm:"not null"`
	Goals    []GoalDB `gorm:"foreignKey:UserID"`
	GormModel
}

func (UserDB) TableName() string {
	return "users"
}
