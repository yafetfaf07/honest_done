package entities

type QuestionOption struct {
	ID        string
	Text      string
	IsCorrect bool
}

type Question struct {
	Text    string
	ID      string
	TodoId  string
	Options []QuestionOption
}
