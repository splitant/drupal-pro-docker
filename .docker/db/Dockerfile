ARG DB_TAG
ARG DB_IMAGE

FROM ${DB_IMAGE}:${DB_TAG}

COPY .docker/db/conf/custom.cnf /etc/mysql/conf.d/custom.cnf
