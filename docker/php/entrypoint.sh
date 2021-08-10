#!/bin/sh

set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- php-fpm "$@"
fi

if [ "$1" = 'php-fpm' ] || [ "$1" = 'php' ] || [ "$1" = 'bin/console' ]; then
	PHP_INI_RECOMMENDED="$PHP_INI_DIR/php.ini-production"
	if [ "$APP_ENV" != 'prod' ] && [ "$APP_ENV" != 'staging' ]; then
		PHP_INI_RECOMMENDED="$PHP_INI_DIR/php.ini-development"
	fi
	ln -sf "$PHP_INI_RECOMMENDED" "$PHP_INI_DIR/php.ini"

  composer clear-cache
	if [ "$APP_ENV" != 'prod' ]; then
		composer install --prefer-dist --no-progress --no-suggest --no-interaction
	else
	  composer install --prefer-dist --no-progress --no-suggest --no-interaction --no-dev
  fi
  composer dump-autoload --classmap-authoritative

#	echo "Waiting for db to be ready..."
#	until php bin/console doctrine:query:sql "SELECT 1" > /dev/null 2>&1; do
#		sleep 1
#	done

	echo "DB ready!"

#	if [ "$APP_ENV" != 'prod' ]; then
#	  echo "Droping existing DB schema..."
#	  bin/console doctrine:schema:drop --force
#		echo "Updating DB schema..."
#		php bin/console doctrine:schema:update --force --no-interaction
#		echo "Loading fixtures..."
#		bin/console doctrine:fixtures:load -n
#		echo "Executing pending migrations..."
#		php bin/console doctrine:migrations:migrate -n
#	fi
	chown -R www-data:www-data var
fi

exec docker-php-entrypoint "$@"
