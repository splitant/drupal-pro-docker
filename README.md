# Drupal pro docker

## About The Project

The goal is to set up fastly a local Drupal project with docker environment for professional uses.

### Built With

* [Official Drupal Docker Image](https://hub.docker.com/_/drupal)
* [Official MySQL Docker Image](https://hub.docker.com/_/mysql)
* [Official Node Docker Image](https://hub.docker.com/_/node)
* [Official phpMyAdmin Docker Image](https://hub.docker.com/_/phpmyadmin)
* [Official traefik Docker Image](https://hub.docker.com/_/traefik)
* [Mailhog Docker Image](https://hub.docker.com/r/mailhog/mailhog)

## Getting Started

### Installation

   ```sh
   make create-setup <project> <repo-git>
   make copy-env-file
   # Fill env file
   # optionally fill GITLAB_TOKEN in .env and `make gitlab-auth`
   make setup
   ```

### New project

   ```sh
   make create-init <project>
   make copy-env-file
   # Fill env file
   make init
   ```

## Nota

* XDEBUG Drush in container : `DRUSH_ALLOW_XDEBUG=1 drush <drush-command-name>`
