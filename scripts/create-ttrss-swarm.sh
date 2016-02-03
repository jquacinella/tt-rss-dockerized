#!/bin/bash

docker run --net personal-net -e constraint:node==personal-swarm-node1 \
  --dns $(docker-machine ip consul) --dns 8.8.8.8  \
  --name ttrss-php5 \
  -t -i -d \
  -p 9000:9000 \
  php:5-fpm

docker run --net personal-net -e constraint:node==personal-swarm-node1 \
  --dns $(docker-machine ip consul) --dns 8.8.8.8  \
  --name nginx \
  -t -i -d \
  -p 8080:80 \
  nginx:latest

docker run --net personal-net -e constraint:node==personal-swarm-node1 \
  --dns $(docker-machine ip consul) --dns 8.8.8.8  \
  --name ttrss-mysql \
  -e MYSQL_ROOT_PASSWORD=changeme \
  -e MYSQL_DATABASE=ttrss \
  -e MYSQL_USER=ttrss \
  -e MYSQL_PASSWORD=ttrss \
  -p 3306:3306 \
  -t -i -d \
  mysql:5.7