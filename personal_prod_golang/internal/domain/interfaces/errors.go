package interfaces

import "errors"

// Shared sentinels so repositories can report "missing" and "not yours" without
// either the repository or the use case layer having to import the other, or
// leaking a persistence-specific error such as gorm.ErrRecordNotFound.
var (
	ErrNotFound  = errors.New("record not found")
	ErrForbidden = errors.New("record does not belong to this user")
)
