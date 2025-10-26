# Use official Golang image for building
FROM golang:1.21 as builder

WORKDIR /app

# Copy go.mod and go.sum first for caching dependencies
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o pod-monitor main.go

# Use minimal image for runtime
FROM alpine:latest

WORKDIR /root/
COPY --from=builder /app/pod-monitor .

# Use non-root user (optional but best practice)
USER 1000

# Run the binary
CMD ["./pod-monitor"]
