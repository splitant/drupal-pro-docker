include .env

default: help

DRUPAL_CONTAINER=$(shell docker ps --filter name='^/$(PROJECT_NAME)_drupal' --format "{{ .ID }}")
COMPOSER_ROOT ?= /home/drupal/project
DRUPAL_ROOT ?= /home/drupal/project/web
DESKTOP_PATH ?= ~/Desktop/
DRUPAL_VERSION ?= latest

## help : Print commands help.
.PHONY: help
ifneq (,$(wildcard docker.mk))
help : docker.mk
	@sed -n 's/^##//p' $<
else
help : Makefile
	@sed -n 's/^##//p' $<
endif

## up : Start up containers.
.PHONY: up
up:
	mkdir -p project
	@echo "Starting up containers for $(PROJECT_NAME)..."
	docker compose pull
	docker compose up -d --wait --remove-orphans --build

## down : Stop containers.
.PHONY: down
down: stop

## start : Start containers without updating.
.PHONY: start
start:
	@echo "Starting containers for $(PROJECT_NAME) from where you left off..."
	@docker compose start

## restart : Restart containers without updating.
.PHONY: restart
restart:
	@echo "Restarting containers for $(PROJECT_NAME)..."
	@docker compose restart

## stop : Stop containers.
.PHONY: stop
stop:
	@echo "Stopping containers for $(PROJECT_NAME)..."
	@docker compose stop

## prune : Remove containers and their volumes.
##		You can optionally pass an argument with the service name to prune single container
##		prune mariadb : Prune `mariadb` container and remove its volumes.
##		prune mariadb solr : Prune `mariadb` and `solr` containers and remove their volumes.
.PHONY: prune
prune:
	$(MAKE) clean-project
	@echo "Removing containers for $(PROJECT_NAME)..."
	@docker compose down -v $(filter-out $@,$(MAKECMDGOALS))

## ps : List running containers.
.PHONY: ps
ps:
	@docker ps --filter name='$(PROJECT_NAME)*'

## shell : Access `php` container via shell.
##		You can optionally pass an argument with a service name to open a shell on the specified container
.PHONY: shell
shell:
	docker exec -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_$(or $(filter-out $@,$(MAKECMDGOALS)), 'drupal')' --format "{{ .ID }}") bash

## shell-root : Access `php` container via shell in ROOT user.
##		You can optionally pass an argument with a service name to open a shell on the specified container
.PHONY: shell-root
shell-root:
	docker exec -u root -ti -e COLUMNS=$(shell tput cols) -e LINES=$(shell tput lines) $(shell docker ps --filter name='$(PROJECT_NAME)_$(or $(filter-out $@,$(MAKECMDGOALS)), 'drupal')' --format "{{ .ID }}") bash

## composer : Executes `composer` command in a specified `COMPOSER_ROOT` directory (default is `/var/www/html`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make composer "update drupal/core --with-dependencies"
.PHONY: composer
composer:
	docker exec $(DRUPAL_CONTAINER) composer --working-dir=$(COMPOSER_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## drush : Executes `drush` command in a specified `DRUPAL_ROOT` directory (default is `/var/www/html/web`).
##		To use "--flag" arguments include them in quotation marks.
##		For example: make drush "watchdog:show --type=cron"
.PHONY: drush
drush:
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) $(filter-out $@,$(MAKECMDGOALS))

## logs : View containers logs.
##		You can optinally pass an argument with the service name to limit logs
##		logs php : View `php` container logs.
##		logs nginx php : View `nginx` and `php` containers logs.
.PHONY: logs
logs:
	@docker compose logs -f $(filter-out $@,$(MAKECMDGOALS))

## create-init : Setup local project.
##		For example: make create-init "<project_name>"
.PHONY: create-init
create-init:
	mv ${DESKTOP_PATH}drupal-pro-docker ${DESKTOP_PATH}$(word 2, $(MAKECMDGOALS))-docker
	mkdir ${DESKTOP_PATH}$(word 2, $(MAKECMDGOALS))-docker/project
	$(MAKE) copy-env-file

## create-setup : Setup local project from existing Git project.
##		For example: make create-setup "<project_name> <repo-git>"
.PHONY: create-setup
create-setup:
	mv ${DESKTOP_PATH}drupal-pro-docker ${DESKTOP_PATH}$(word 2, $(MAKECMDGOALS))-docker
	git clone $(word 3, $(MAKECMDGOALS)) ${DESKTOP_PATH}$(word 2, $(MAKECMDGOALS))-docker/project
	$(MAKE) copy-env-file

.PHONY: generate-ssl-ca
generate-ssl-ca:
## generate-ssl-ca	:	Generates SSL certificates.
	mkdir -p .docker/traefik/certs
	mkcert -cert-file .docker/traefik/certs/cert.pem -key-file .docker/traefik/certs/cert-key.pem ${PROJECT_BASE_URL}

## init : Create local project.
.PHONY: init
init:
	$(MAKE) up
	$(MAKE) create-project
	$(MAKE) vendor
	$(MAKE) drupal-init

## setup : Create local project from existing Git project.
.PHONY: setup
setup:
	$(MAKE) up
ifdef GITLAB_TOKEN
	$(MAKE) gitlab-auth
endif
	$(MAKE) vendor
	$(MAKE) copy-files
	$(MAKE) drupal-install
	$(MAKE) packages
	$(MAKE) build

## pull : Deploy on local.
.PHONY: pull
pull:
	$(MAKE) drush-cex
	$(MAKE) vendor
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) deploy
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) locale:check
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) locale:update

## drush-cex : Export configurations.
.PHONY: drush-cex
drush-cex:
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) config:export -y --destination=./export

## vendor : Composer install.
.PHONY: vendor
vendor:
	docker exec $(DRUPAL_CONTAINER) composer --working-dir=$(COMPOSER_ROOT) install -o

## create-project : Create project from composer.
.PHONY: create-project
create-project:
ifeq ($(DRUPAL_VERSION),latest)
	docker exec $(DRUPAL_CONTAINER) composer --working-dir=$(COMPOSER_ROOT) create-project drupal/recommended-project ./
else
	docker exec $(DRUPAL_CONTAINER) composer --working-dir=$(COMPOSER_ROOT) create-project drupal/recommended-project:${DRUPAL_VERSION} ./
endif
	docker exec $(DRUPAL_CONTAINER) composer --working-dir=$(COMPOSER_ROOT) require drush/drush

## clean-project : Remove project directory content
.PHONY: clean-project
clean-project:
	docker exec -u root -w /home/drupal $(DRUPAL_CONTAINER) bash -c 'shopt -s dotglob && rm -rf project/*'

## gitlab-auth : Composer create auth json.
.PHONY: gitlab-auth
gitlab-auth:
	docker exec $(DRUPAL_CONTAINER) composer --working-dir=$(COMPOSER_ROOT) config --auth gitlab-token.gitlab.choosit.com ${GITLAB_TOKEN} --no-ansi --no-interaction

## copy-files : Copy pre-commit, settings.php and .env files.
.PHONY: copy-files
copy-files:
	$(MAKE) copy-pre-commit
	$(MAKE) copy-settings-php
	$(MAKE) copy-settings-local-php
	cp .env ./project/.env

## copy-env-file : Copy .env file.
.PHONY: copy-env-file
copy-env-file:
	cp .env.dist .env

## copy-pre-commit : Copy pre-commit file.
.PHONY: copy-pre-commit
copy-pre-commit:
	cp .docker/common/git/pre-commit ./project/.git/hooks/pre-commit

## copy-settings-php : Copy settings.php file.
.PHONY: copy-settings-php
copy-settings-php:
	cp .docker/drupal/conf/default.settings.php ./project/web/sites/default/settings.php

## copy-settings-local-php : Copy settings.local.php file.
.PHONY: copy-settings-local-php
copy-settings-local-php:
	cp ./project/web/sites/example.settings.local.php ./project/web/sites/default/settings.local.php

## drupal-install : Drupal site install from existent.
.PHONY: drupal-install
drupal-install:
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) site:install minimal -y --account-name=${INSTALL_ACCOUNT_NAME} --account-pass=${INSTALL_ACCOUNT_PASS} --account-mail=${INSTALL_ACCOUNT_MAIL} --existing-config

## drupal-init : Drupal site install from scratch.
.PHONY: drupal-init
drupal-init:
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) site:install -y --db-url=${DB_DRIVER}://root:${DB_ROOT_PASSWORD}@${DB_HOST}/${DB_NAME} --account-name=${INSTALL_ACCOUNT_NAME} --account-pass=${INSTALL_ACCOUNT_PASS} --account-mail=${INSTALL_ACCOUNT_MAIL}

## packages : npm install.
.PHONY: packages
packages:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_node' --format "{{ .ID }}") npm install

## build : npm run build.
.PHONY: build
build:
	docker exec $(shell docker ps --filter name='^/$(PROJECT_NAME)_node' --format "{{ .ID }}") npm run build

## restore-dump : Restore dump.
##		For example: make restore-dump ./dump/<dump_name>.sql.gz
.PHONY: restore-dump
restore-dump:
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) sql-drop -y
	docker exec -i $(DRUPAL_CONTAINER) gunzip -c $(filter-out $@,$(MAKECMDGOALS)) | docker exec -i $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) sql-cli
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) uli

## backup : Make a backup.
.PHONY: backup
backup:
	docker exec $(DRUPAL_CONTAINER) drush -r $(DRUPAL_ROOT) sql-dump --result-file=auto --gzip

# https://stackoverflow.com/a/6273809/1826109
%:
	@:
