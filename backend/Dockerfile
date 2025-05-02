# Builder stage
FROM golang:1.24.2-alpine as builder

WORKDIR /app

# Copy go.mod and go.sum and download dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy the rest of the source code
COPY . .

# Build the application
# CGO_ENABLED=0 is important for creating a static executable
RUN CGO_ENABLED=0 GOOS=linux go build -o /backend-app ./main.go

# Final stage
FROM alpine:latest

WORKDIR /app

# Copy the built executable from the builder stage
COPY --from=builder /backend-app .

# Copy configuration files (assuming they are in backend/config/)
# Adjust this if your config files are located elsewhere or named differently
COPY backend/config/ ./config/

# Expose the port the application listens on (assuming 8080)
# Update this if your application listens on a different port
EXPOSE 8080

# Command to run the executable
ENTRYPOINT ["/app/backend-app"]