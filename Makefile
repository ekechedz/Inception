NAME = inception
DCOMPOSE = docker compose
DCOMPOSE_FILE = docker-compose.yml

.PHONY: all up down restart build clean fclean re

## Start the containers
all: up

## Start services in detached mode
up:
	@$(DCOMPOSE) -f $(DCOMPOSE_FILE) up -d
	@echo "🚀 Inception started!"

## Stop containers but keep data
down:
	@$(DCOMPOSE) -f $(DCOMPOSE_FILE) down
	@echo "🛑 Inception stopped!"

## Restart all services
restart: down up

## Build or rebuild services
build:
	@$(DCOMPOSE) -f $(DCOMPOSE_FILE) build --no-cache
	@echo "🔧 Services rebuilt!"

## Remove stopped containers and dangling images
clean:
	@docker system prune -f
	@echo "🧹 Cleaned up unused Docker resources!"

## Completely remove containers, images, volumes, and networks
fclean:
	@$(DCOMPOSE) -f $(DCOMPOSE_FILE) down -v
	@docker system prune -a -f --volumes
	@echo "🔥 Everything removed!"

## Rebuild everything from scratch
re: fclean up
