# Drupal pro docker

## About The Project

The goal is to set up fastly a local Drupal project with docker environment for professional uses.

### Built With

* [Docker4Drupal](https://github.com/wodby/docker4drupal)

## Getting Started

### Installation

   ```sh
   make create-setup <project> <repo-git>
   cd ../<project>-docker
   make copy-env-file
   # Fill env file
   # optionally fill GITLAB_TOKEN in .env and `make gitlab-auth`
   make up
   make setup
   ```

### New project

   ```sh
   make create-init <project>
   cd ../<project>-docker
   make copy-env-file
   # Fill env file
   make up
   make init
   ```
