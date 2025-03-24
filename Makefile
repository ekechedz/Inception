.PHONY: all clean build run down logs restart init stop start status

SECRETS_SCRIPT := ./srcs/secrets.sh
ENV_FILE := ./srcs/.env
SECRETS_DIR := ./secrets
DATA_DIR := ../../data

# Default target: build and run the containers
all: build run

# Build the containers
build: init
	@echo "Building containers ......"
	docker-compose -f srcs/docker-compose.yml build
	@echo "Build complete"

# Start the containers
run:
	@echo "Starting containers ......"
	docker-compose -f srcs/docker-compose.yml up -d --force-recreate --build
	@echo "Containers started successfully"

# Stop and remove the containers
down:
	@echo "Stopping and removing containers..."
	docker-compose -f srcs/docker-compose.yml down
	@echo "Containers stopped and removed. Volumes are still there."

# Clean up all the files and volumes
clean: down
	@echo "Cleaning up secrets and environment files..."
	@rm -fr $(SECRETS_DIR) || true
	@rm -fr $(ENV_FILE) || true
	@sudo rm -fr $(DATA_DIR) || true
	@echo "Secrets and environment files removed"
	@echo "Removing Docker volumes..."
	@docker volume rm mariadb wordpress || true
	@echo "Pruning Docker system..."
	@docker system prune --all --force
	@echo "Prune complete. Containers and Volumes were removed"

# View the logs of the containers
logs:
	@echo "Displaying logs..."
	docker-compose -f srcs/docker-compose.yml logs -f

# Rebuild and restart the containers
re: down run

# Initialize secrets and environment variables
init:
	@echo "Initializing Files and Credentials..."
	@$(SECRETS_SCRIPT)
	@echo "Initialization complete"

# Stop all running containers
stop:
	@echo "Stopping all containers..."
	docker stop $$(docker ps -q) > /dev/null 2>&1 || true
	@echo "Containers stopped"

# Start all stopped containers
start:
	@echo "Starting stopped containers..."
	docker-compose -f srcs/docker-compose.yml start
	@echo "Containers started"

# Display system status and Docker info
status:
	@echo "IMAGES OVERVIEW"
	@docker images
	@echo "CONTAINER OVERVIEW"
	@docker ps -a
	@echo "NETWORK OVERVIEW"
	@docker network ls
	@echo "CONTAINER LOGS"
	@docker-compose -f srcs/docker-compose.yml logs
