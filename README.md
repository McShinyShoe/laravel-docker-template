# Laravel Docker Template
Too lazy to set up a stack for laravel in docker? Just copy this project and you have a working laravel stack.

## Configuration
It's discouraged to edit the `docker-compose.yaml` and the `web/.env` file directly, this is the way you should do it.

### Changing MySQL Credentials
Editing the username and password for the stack should be done in [mysql/mysql.env](mysql/mysql.env)

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
in [makefile](makefile)
``` makefile
USE_REDIS?=false
USE_MAIL?=false
USE_PHPMYADMIN?=false
```

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