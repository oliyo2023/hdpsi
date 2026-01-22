# Builder stage
FROM golang:1.24.2-alpine as builder

# 设置GOPROXY加速依赖下载
ENV GOPROXY=https://goproxy.cn,direct

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
FROM alpine:3.19

WORKDIR /app

# Copy the built executable from the builder stage
COPY --from=builder /backend-app .

# Expose the port the application listens on
EXPOSE 8081

# Command to run the executable
ENTRYPOINT ["/app/backend-app"]