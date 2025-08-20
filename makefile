include .env

LARAVEL_PKG := $(if $(filter $(LARAVEL_VERSION),latest),laravel/laravel,laravel/laravel:^$(LARAVEL_VERSION))

REDIS_TARGET :=
ifeq ($(USE_REDIS),true)
REDIS_TARGET := redis
endif

MAIL_TARGET :=
ifeq ($(USE_MAIL),true)
MAIL_TARGET := mailhog
endif

PHPMYADMIN_TARGET :=
ifeq ($(USE_PHPMYADMIN),true)
PHPMYADMIN_TARGET := phpmyadmin
endif

.PHONY: clean init purge all mysql nginx npm-build composer-install
		composer-migrate-fresh composer-seed composer-key-generate env
		redis mailhog phpmyadmin

clean:
	${DOCKER_COMPOSE} down

init:
	mkdir -p web
	${DOCKER_COMPOSE} run --rm --build composer create-project ${LARAVEL_PKG} .

purge:
	sudo rm web -rf

all: clean mysql $(REDIS_TARGET) $(MAIL_TARGET) ${PHPMYADMIN_TARGET}\
	 nginx npm-build composer-install composer-migrate-fresh \
	 composer-seed composer-key-generate

mysql:
	${DOCKER_COMPOSE} up -d --build mysql

nginx:
	${DOCKER_COMPOSE} up -d --build nginx

npm-build:
	${DOCKER_COMPOSE} run --build --rm npm install	
	${DOCKER_COMPOSE} run --build --rm npm run build

composer-install:
	${DOCKER_COMPOSE} run --build --rm composer install

composer-migrate-fresh:
	docker compose run --build --rm artisan migrate:fresh

composer-seed:
	docker compose run --build --rm artisan db:seed
	
composer-key-generate:
	docker compose run --build --rm artisan key:generate

env:
	cp web/.env.example web/.env

	sed -i 's/APP_NAME=Laravel/APP_NAME=${APP_NAME}/' web/.env
	sed -i 's/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' web/.env
	sed -i 's/# DB_HOST=127.0.0.1/DB_HOST=mysql/' web/.env
	sed -i 's/# DB_PORT=3306/DB_PORT=3306/' web/.env
	sed -i 's/# DB_DATABASE=laravel/DB_DATABASE=${MYSQL_DATABASE}/' web/.env
	sed -i 's/# DB_USERNAME=root/DB_USERNAME=${MYSQL_USER}/' web/.env
	sed -i 's/# DB_PASSWORD=/DB_PASSWORD=${MYSQL_PASSWORD}/' web/.env
	
ifeq ($(USE_REDIS),true)
	sed -i 's/REDIS_HOST=127.0.0.1/MAIL_HOST=redis/' web/.env
endif
	

ifeq ($(USE_MAIL),true)
	sed -i 's/MAIL_MAILER=log/MAIL_MAILER=smtp/' web/.env
	sed -i 's/MAIL_HOST=127.0.0.1/MAIL_HOST=mailhog/' web/.env
	sed -i 's/MAIL_PORT=2525/MAIL_PORT=1025/' web/.env
	sed -i 's/MAIL_FROM_ADDRESS="hello@example.com"/MAIL_FROM_ADDRESS="no-reply@example.com"/' web/.env
endif

redis:
	${DOCKER_COMPOSE} up -d --build redis

mailhog:
	${DOCKER_COMPOSE} up -d --build mailhog

phpmyadmin:
	${DOCKER_COMPOSE} up -d --build phpmyadmin
