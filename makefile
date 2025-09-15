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
	mkdir -p $(LARAVEL_FOLDER)
	${DOCKER_COMPOSE} run --rm --build composer create-project ${LARAVEL_PKG} .

start: mysql $(REDIS_TARGET) $(MAIL_TARGET) ${PHPMYADMIN_TARGET} \
       nginx

purge:
	sudo rm $(LARAVEL_FOLDER) -rf

all: clean start npm-build composer-install composer-migrate-fresh \
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
	cp $(LARAVEL_FOLDER)/.env.example $(LARAVEL_FOLDER)/.env

	sed -i 's/APP_NAME=Laravel/APP_NAME=${APP_NAME}/' $(LARAVEL_FOLDER)/.env
	sed -i 's/DB_CONNECTION=sqlite/DB_CONNECTION=mysql/' $(LARAVEL_FOLDER)/.env
	sed -i 's/# DB_HOST=127.0.0.1/DB_HOST=mysql/' $(LARAVEL_FOLDER)/.env
	sed -i 's/# DB_PORT=3306/DB_PORT=3306/' $(LARAVEL_FOLDER)/.env
	sed -i 's/# DB_DATABASE=laravel/DB_DATABASE=${MYSQL_DATABASE}/' $(LARAVEL_FOLDER)/.env
	sed -i 's/# DB_USERNAME=root/DB_USERNAME=${MYSQL_USER}/' $(LARAVEL_FOLDER)/.env
	sed -i 's/# DB_PASSWORD=/DB_PASSWORD=${MYSQL_PASSWORD}/' $(LARAVEL_FOLDER)/.env
	
ifeq ($(USE_REDIS),true)
	sed -i 's/REDIS_HOST=127.0.0.1/MAIL_HOST=redis/' $(LARAVEL_FOLDER)/.env
endif
	

ifeq ($(USE_MAIL),true)
	sed -i 's/MAIL_MAILER=log/MAIL_MAILER=smtp/' $(LARAVEL_FOLDER)/.env
	sed -i 's/MAIL_HOST=127.0.0.1/MAIL_HOST=mailhog/' $(LARAVEL_FOLDER)/.env
	sed -i 's/MAIL_PORT=2525/MAIL_PORT=1025/' $(LARAVEL_FOLDER)/.env
	sed -i 's/MAIL_FROM_ADDRESS="hello@example.com"/MAIL_FROM_ADDRESS="no-reply@example.com"/' $(LARAVEL_FOLDER)/.env
endif

redis:
	${DOCKER_COMPOSE} up -d --build redis

mailhog:
	${DOCKER_COMPOSE} up -d --build mailhog

phpmyadmin:
	${DOCKER_COMPOSE} up -d --build phpmyadmin
