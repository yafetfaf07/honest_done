package dtos

type CreateQuestionRequest struct {
	Name string `json:"name"`
}

type GetQuestionResponse struct {
	ID string 	`json:"id"`
	Text string `json:"text"`
	TodoId string `json:"todo_id"`
	
}