# TT-RSS Dockerized

TT-RSS as Docker Setup using Machine, Swarm, Consul and Registrator

## Installation Steps

Inspiration:

* https://www.safaribooksonline.com/blog/2015/11/17/fun-with-docker-swarm/
* https://github.com/gliderlabs/docker-consul
* http://stackoverflow.com/questions/29905953/how-to-correctly-link-php-fpm-and-nginx-docker-containers-together

# Consul VM

* docker-machine create --driver virtualbox --virtualbox-memory "512" --engine-insecure-registry registry.quacinella.org:5000 consul
* eval $(docker-machine env consul)
* docker pull progrium/consul
* docker run -d  --name consul -p 8400:8400 -p 8500:8500 -p 53:53/udp -h consul-node1 progrium/consul -server -bootstrap -ui-dir /ui
* docker-machine ip consul


## Create VMs for Swarm

* docker-machine create --driver virtualbox --virtualbox-memory "512" --swarm --swarm-master --swarm-discovery consul://$(docker-machine ip consul):8500/ --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" --engine-opt="cluster-advertise=eth1:2376" --engine-insecure-registry registry.quacinella.org:5000 personal-swarm-master

* docker-machine create --driver virtualbox --virtualbox-memory "512" --swarm --swarm-discovery consul://$(docker-machine ip consul):8500/ --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" --engine-opt="cluster-advertise=eth1:2376"  --engine-insecure-registry registry.quacinella.org:5000 personal-swarm-node1 


## Use Swarm

* eval "$(docker-machine env --swarm personal-swarm-master)"
* docker run -h personal-mysql -d -e constraint:node==swarm1 nginx

## Create Overlay Network

docker network create --driver overlay personal-net

## Registarators

* docker run --net personal-net -d -e constraint:node==personal-swarm-node1  --name registrator-node1 --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://$(docker-machine ip consul):8500/

* docker run --net personal-net -d -e constraint:node==personal-swarm-master --name registrator-master --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://$(docker-machine ip consul):8500/


### Example: Use DNS from Consul

* docker run --net personal-net --dns $(docker-machine ip consul) --dns 8.8.8.8 --dns-search service.dc1.consul -t -i --name test --rm   phusion/baseimage /sbin/my_init -- bash -l


### PHP5-FPM Container

* docker run --net personal-net -e constraint:node==personal-swarm-node1 --dns $(docker-machine ip consul) --dns 8.8.8.8  --name ttrss-php5 -t -i -d -p 9000:9000 -v $(pwd):/var/www/html/ php:5-fpm

curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin

docker-php-ext-install mbstring mysqli

chmod -R 777 cache/images
chmod -R 777 cache/upload
chmod -R 777 cache/export
chmod -R 777 cache/js
chmod -R 777 feed-icons
chmod -R 777 lock


### NGinx

* docker run --net personal-net -e constraint:node==personal-swarm-node1 --dns $(docker-machine ip consul) --dns 8.8.8.8  --name nginx -d -p 8080:80 nginx:latest

    server {
        listen  80;

        root /var/www/html/tt-rss

        error_log /var/log/nginx/localhost.error.log;
        access_log /var/log/nginx/localhost.access.log;

        location / {
            # try to serve file directly, fallback to app.php
            try_files $uri /index.php
        }

        location ~ ^/.+\.php(/|$) {
            fastcgi_pass ttrss-php5:9000;
            fastcgi_split_path_info ^(.+\.php)(/.*)$;
            include fastcgi_params;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        }
    }



 apt-get update && apt-get install git vim
 mkdir -p /var/www/html
 cd /var/www/html
 git clone https://tt-rss.org/git/tt-rss.git tt-rss


### MySQL

* docker run --net personal-net -e constraint:node==personal-swarm-node1 --name ttrss-mysql -e MYSQL_ROOT_PASSWORD=changeme -e MYSQL_DATABASE=ttrss -e MYSQL_USER=ttrss -e MYSQL_PASSWORD=ttrss -p 3306:3306 -d mysql:5.7


## TODO

* Setup custom registry on aws spot instance backed by s3
* create some images of the mysql, nginx and php containers

* flocker management
* create mysql volume
* volume with tt-rss installed?


#### Registry



Docker registry IAM user
AKIAJRWS3U2ZJB5GT6QQ
W2StiVdhLwIGCsplTtgIOQpXJcrtTlFAVbMNgq7j


* why does consul not show right ip addresses when using overlay network
