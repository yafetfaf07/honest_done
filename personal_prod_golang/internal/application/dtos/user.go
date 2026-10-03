package dtos

// user create dto
type CreateUser struct {
	Name     string `json:"name" binding:"required"`
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

type CreateAndLoginResponse struct {
	ID           string `json:"id"`
	Name         string `json:"name"`
	Email        string `json:"email"`
	AccessToken  string `json:"access_token"`
	RefreshToken string `json:"-"`
}

// user login dto
type LoginUser struct {
	Email    string `json:"email" binding:"required"`
	Password string `json:"password" binding:"required"`
}

// RefreshTokenRequest lets native clients supply the refresh token in the
// body instead of relying on the http-only cookie, which a non-browser client
// has no automatic cookie jar for.
type RefreshTokenRequest struct {
	RefreshToken string `json:"refresh_token"`
}

type MeResponse struct {
	ID    string `json:"id"`
	Name  string `json:"name"`
	Email string `json:"email"`
}
