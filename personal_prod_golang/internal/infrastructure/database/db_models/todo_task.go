package dbmodels

type TodoTask struct {
	Name     string
	Email    string `gorm:"index"`
	Password string
	GormModel
}


func(TodoTask) TableName() string{
	return "todo_tasks"
}