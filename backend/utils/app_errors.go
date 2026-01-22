package utils

// ValidationError represents an error that occurs due to invalid input or business rule violation.
// It implements the error interface.
type ValidationError struct {
	Message string
}

// Error returns the error message for ValidationError.
func (e *ValidationError) Error() string {
	return e.Message
}

// NewValidationError creates a new ValidationError.
func NewValidationError(message string) *ValidationError {
	return &ValidationError{Message: message}
}

// NotFoundError represents an error when a resource is not found.
type NotFoundError struct {
	Message string
}

// Error returns the error message for NotFoundError.
func (e *NotFoundError) Error() string {
	return e.Message
}

// NewNotFoundError creates a new NotFoundError.
func NewNotFoundError(message string) *NotFoundError {
	return &NotFoundError{Message: message}
}

// UnauthorizedError represents an authentication or authorization error.
type UnauthorizedError struct {
	Message string
}

// Error returns the error message for UnauthorizedError.
func (e *UnauthorizedError) Error() string {
	return e.Message
}

// NewUnauthorizedError creates a new UnauthorizedError.
func NewUnauthorizedError(message string) *UnauthorizedError {
	return &UnauthorizedError{Message: message}
}

// ForbiddenError represents an error when access to a resource is denied.
type ForbiddenError struct {
	Message string
}

// Error returns the error message for ForbiddenError.
func (e *ForbiddenError) Error() string {
	return e.Message
}

// NewForbiddenError creates a new ForbiddenError.
func NewForbiddenError(message string) *ForbiddenError {
	return &ForbiddenError{Message: message}
}
