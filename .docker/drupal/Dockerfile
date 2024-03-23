ARG DRUPAL_TAG

FROM drupal:${DRUPAL_TAG}

ARG GROUP_ID
ARG USER_ID
ARG XDEBUG_VERSION

RUN apt-get update \
	&& apt-get install -y curl \
        wget \
        git \
        vim \
        unzip \
        default-mysql-client \
  && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install bcmath

RUN groupadd -g "${GROUP_ID}" drupal; \
	useradd  -u "${USER_ID}" -m -s /bin/bash -g drupal drupal; \
	adduser drupal www-data;

RUN yes | pecl install xdebug-${XDEBUG_VERSION} \
  && echo "zend_extension=$(find /usr/local/lib/php/extensions/ -name xdebug.so)" > /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.discover_client_host=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.start_with_request=yes" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.client_port=9003" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.log_level=0" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.idekey=VSCODE" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.log=/tmp/xdebug_remote.log" >> /usr/local/etc/php/conf.d/xdebug.ini \
  && echo "xdebug.client_host=172.17.0.1" >> /usr/local/etc/php/conf.d/xdebug.ini

RUN pecl install redis \
  && docker-php-ext-enable redis

ENV DRUSH_LAUNCHER_FALLBACK="/home/drupal/.composer/vendor/bin/drush"

RUN set -ex; \
  drush_launcher_url="https://github.com/drush-ops/drush-launcher/releases/download/0.10.2/drush.phar"; \
  wget -O drush.phar "${drush_launcher_url}"; \
  chmod +x drush.phar; \
  mv drush.phar /usr/local/bin/drush;

COPY .docker/drupal/conf/php.ini /usr/local/etc/php/conf.d/100-php.ini

RUN rm /var/www/html; \
  ln -sf /home/drupal/project/web /var/www/html;

RUN mkdir -p /home/drupal/.ssh
RUN chown -R drupal:drupal /home/drupal/.ssh

USER drupal

RUN mkdir /home/drupal/.composer \
  && composer global require drush/drush:^8.0

WORKDIR /home/drupal/project