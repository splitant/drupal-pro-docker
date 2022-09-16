# Drupal pro docker

## About The Project

The goal is to set up fastly a local Drupal project with docker environment for professional uses.

### Built With

* [Docker4Drupal](https://github.com/wodby/docker4drupal)

## Getting Started

### Installation

   ```sh
   make create-setup <project> <repo-git>
   make copy-env-file
   # Fill env file
   # optionally fill GITLAB_TOKEN in .env and `make gitlab-auth` 
   make setup
   ```

