# Drupal pro docker

## About The Project

The goal is to set up fastly a local Drupal project with docker environment for professional uses.

### Built With

* [Official Drupal Docker Image](https://hub.docker.com/_/drupal)
* [Official MySQL Docker Image](https://hub.docker.com/_/mysql)
* [Official Solr Docker Image](https://hub.docker.com/_/solr)
* [Official Redis Docker Image](https://hub.docker.com/_/redis)
* [Official phpMyAdmin Docker Image](https://hub.docker.com/_/phpmyadmin)
* [Official traefik Docker Image](https://hub.docker.com/_/traefik)
* [Mailhog Docker Image](https://hub.docker.com/r/mailhog/mailhog)

### Requirements

* Install [mkcert](https://github.com/FiloSottile/mkcert)
* Execute for local CA trust store: `mkcert -install`

## Getting Started

### Installation

   ```sh
   git clone git@github.com:splitant/drupal-pro-docker.git
   cd drupal-pro-docker
   make create-setup <project> <repo-git>
   # Fill env file
   make generate-ssl-ca # Generate SSL certificates
   make setup
   ```

### New project

   ```sh
   git clone git@github.com:splitant/drupal-pro-docker.git
   cd drupal-pro-docker
   make create-init <project>
   # Fill env file
   make generate-ssl-ca # Generate SSL certificates
   make init
   ```

## Nota

* XDEBUG Drush in container : `DRUSH_ALLOW_XDEBUG=1 drush <drush-command-name>`
