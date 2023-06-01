ARG NODE_TAG

FROM node:${NODE_TAG}

ARG GROUP_ID
ARG USER_ID

RUN groupmod -g ${GROUP_ID} node \
    && usermod -u ${USER_ID} -g ${GROUP_ID} node