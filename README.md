# Laravel Docker Template
Too lazy to set up a stack for laravel in docker? Just copy this project and you have a working laravel stack.

By default Laravel folder is located at the folder `web`, but you can change it by changing this line in `.env`
``` bash
LARAVEL_FOLDER=web
```

## Configuration
It's discouraged to edit the `docker-compose.yaml` and the `web/.env` file directly. Most of the app configuration is in `.env` file in the root of the project. 

Before running the application, copy the `./env.example` file at the root of the project into a file named`.env`.

### Changing MySQL Credentials
Editing the username and password for the stack should be done in `.env`

``` bash
MYSQL_DATABASE=homestead
MYSQL_USER=homestead
MYSQL_PASSWORD=secret
MYSQL_ROOT_PASSWORD=secret
```

### Adding PHP Module 
If you want to add a php module, add it in [php/php.dockerfile](php/php.dockerfile) file in the `RUN docker-php-ext-install` line.

``` dockerfile
RUN docker-php-ext-install pdo pdo_mysql
```

### Using Redis/Mailhog/Phpmyadmin
in `.env`
``` bash
USE_REDIS=false
USE_MAIL=false
USE_PHPMYADMIN=false
```

### Increasing upload size
If you want to increase file upload size, you should edit this following lines in `.env`
``` bash
NGINX_CLIENT_MAX_BODY_SIZE=100M
PHP_UPLOAD_MAX_FILESIZE=100M
PHP_POST_MAX_SIZE=100M
```
Be sure that `PHP_POST_MAX_SIZE`  is larger or equal than `NGINX_CLIENT_MAX_BODY_SIZE`

## Development

### Running Php/Artisan/Composer
``` bash
docker compose run --rm php [arg]
docker compose run --rm artisan [arg]
docker compose run --rm composer [arg]
```

---
Or you can also enable the `.encrc` to add aliass for `php`, `artisan`, and `composer`. 
``` bash
direnv allow
```

---
If you want to do that without `direnv`, append `tools` directory to your `$PATH`.
``` bash
export PATH="$(pwd)/tools:$PATH"
```

### Initialize project
``` bash
make init
```

### Running
``` bash
make env # to create .env file
make all
```
Or you can just run the `run.sh` shell script
``` bash
./run.sh
```

### Stop
``` bash
make clean
```

### Purge
``` bash
make purge # Will remove the `web` directory
```