.PHONY: install start docker-build docker-run push

# Dependencies installation
install:
	bundle install

# Development server start
start:
	bundle exec ruby app.rb

# Quick development start without manual dependencies installation
dev: install start

# Docker image build
docker-build:
	docker build -t rbbr-landing .

# Docker container run
docker-run:
	docker run -p 4567:4567 rbbr-landing

# Complete cycle: build and run Docker
docker: docker-build docker-run

# Server availability check
check:
	@echo "Checking server availability..."
	@curl -s http://localhost:4567 > /dev/null && echo "Server is running!" || echo "Server is not running!"

# Push to Git repository
push:
	@echo "Pushing to git repository..."
	git add .
	git commit -m "Update landing page" || true
	git push

# Help
help:
	@echo "Available commands:"
	@echo "  make install     - Install dependencies"
	@echo "  make start       - Start development server"
	@echo "  make dev         - Install dependencies and start server"
	@echo "  make docker-build - Build Docker image"
	@echo "  make docker-run  - Run Docker container"
	@echo "  make docker      - Build and run Docker container"
	@echo "  make check       - Check server availability"
	@echo "  make push        - Push changes to repository"

# Default - show help
default: help