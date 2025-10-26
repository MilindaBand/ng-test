# ---------- Build Stage ----------
FROM golang:1.23 AS builder

WORKDIR /app

# Copy go.mod and go.sum first for caching
COPY go.mod ./
COPY go.sum* . || true

# Download dependencies
RUN go mod tidy && go mod download

# Copy the rest of the code (Dockerfile is in same folder)
COPY . .

# Build the binary
RUN CGO_ENABLED=0 GOOS=linux go build -o pod-monitor main.go

# ---------- Runtime Stage ----------
FROM alpine:3.20

# Install certificates for HTTPS calls
RUN apk --no-cache add ca-certificates

WORKDIR /root

# Copy binary from builder
COPY --from=builder /app/pod-monitor .

# Create non-root user
RUN adduser -D appuser
USER appuser

# Run the binary
ENTRYPOINT ["./pod-monitor"]
