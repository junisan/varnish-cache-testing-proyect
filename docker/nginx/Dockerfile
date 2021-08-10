FROM nginx:alpine

ARG APP_ENV=dev

RUN apk update && \
    apk add iputils

RUN rm /etc/nginx/conf.d/default.conf

COPY ./docker/nginx/local.conf /etc/nginx/conf.d/local.conf

WORKDIR /app

COPY ./public /app/public
