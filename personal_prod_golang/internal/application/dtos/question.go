package dtos

type CreateQuestionOption struct {
	Text      string `json:"text" binding:"required"`
	IsCorrect bool   `json:"is_correct"`
}

type CreateQuestionRequest struct {
	Name    string                 `json:"name"`
	Options []CreateQuestionOption `json:"options"`
}

type QuestionOptionResponse struct {
	ID        string `json:"id"`
	Text      string `json:"text"`
	IsCorrect bool   `json:"is_correct"`
}

type GetQuestionResponse struct {
	ID     string `json:"id"`
	Text   string `json:"text"`
	TodoId string `json:"todo_id"`
	// Options were already stored in question_options but never returned, so
	// no quiz client could render a question.
	Options []QuestionOptionResponse `json:"options"`
}
