.PHONY: all clean build run down logs restart init stop start status

SECRETS_SCRIPT := ./srcs/secrets.sh
ENV_FILE := ./srcs/.env
SECRETS_DIR := ./secrets
DATA_DIR := ../../data

all: build run

build: init
	docker-compose -f srcs/docker-compose.yml build

run:
	@echo "\e[34mStarting containers ......\e[0m"
	docker-compose -f srcs/docker-compose.yml up -d --force-recreate --build
	@echo "\e[32mContainers started\e[0m"

down:
	@echo "\e[34mStopping and removing containers...\e[0m"
	docker-compose -f srcs/docker-compose.yml down
	@echo "\e[32mContainers stopped and removed. Volumes are still there.\e[0m"

clean: down
	@echo "\e[34mCleaning up secrets and environment files...\e[0m"
	@rm -fr $(SECRETS_DIR) || true
	@rm -fr $(ENV_FILE) || true
	@sudo rm -fr $(DATA_DIR) || true
	@echo "\e[32mClean up complete\e[0m"
	@echo "\e[34mRemoving Docker volumes...\e[0m"
	@docker volume rm mariadb wordpress || true
	@echo "\e[34mPruning Docker system...\e[0m"
	@docker system prune --all --force
	@echo "\e[32mPrune complete. Containers and Volumes were removed\e[0m"

logs:
	docker-compose -f srcs/docker-compose.yml logs -f

re: down run

init:
	@echo "Initializing Files and Credentials..."
	@$(SECRETS_SCRIPT)
	@echo "Initialization complete"

stop:
	@echo "Stopping all containers..."
	docker stop $$(docker ps -q) > /dev/null 2>&1 || true
	@echo "Containers stopped"

start:
	@echo "Starting stopped containers..."
	docker-compose -f srcs/docker-compose.yml start
	@echo "Containers started"

status:
	@echo "IMAGES OVERVIEW"
	@docker images
	@echo "CONTAINER OVERVIEW"
	@docker ps -a
	@echo "NETWORK OVERVIEW"
	@docker network ls
	@echo "CONTAINER LOGS"
	@docker-compose -f srcs/docker-compose.yml logs
