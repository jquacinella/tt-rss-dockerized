# TT-RSS Dockerized

TT-RSS as Docker Setup using Machine, Swarm, Consul and Registrator

## Installation Steps

Inspiration:

* https://www.safaribooksonline.com/blog/2015/11/17/fun-with-docker-swarm/
* https://github.com/gliderlabs/docker-consul

# Consul VM

* docker-machine create --driver virtualbox consul1 
* eval $(docker-machine env consul1)
* docker pull progrium/consul
* docker run -d --name consul -p 8400:8400 -p 8500:8500 -p 8600:53/udp -h node1 progrium/consul -server -bootstrap -ui-dir /ui
* docker-machine ip consul1


## Create VMs for Swarm

* docker-machine create --driver virtualbox --swarm --swarm-master --swarm-discovery consul://$(docker-machine ip consul1):8500/ swarm-master
* docker-machine create --driver virtualbox --swarm --swarm-discovery consul://$(docker-machine ip consul1):8500/ swarm1 
* docker-machine create --driver virtualbox --swarm --swarm-discovery consul://$(docker-machine ip consul1):8500/ swarm2


## Use Swarm

* eval "$(docker-machine env --swarm swarm-master)"
* docker run -d -e constraint:node==swarm1 nginx

## Registartors

* docker run -d -e constraint:node==swarm1 --name registrator-node1 --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://$(docker-machine ip consul1):8500/

* docker run -d -e constraint:node==swarm-master --name registrator-master --net=host --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://$(docker-machine ip consul1):8500/


### Use DNS from Consul

* docker run --dns $(docker-machine ip consul1) --dns 8.8.8.8 --dns-search service.dc1.consul -t -i --name test --rm   phusion/baseimage /sbin/my_init -- bash -l

### Start new container for tt-rss

**TODO**

docker run --dns $(docker-machine ip consul1) --dns 8.8.8.8 --dns-search service.dc1.consul -t -i --name tt-rss --rm   phusion/baseimage /sbin/my_init 
docker exec -it tt-rss /bin/bash
sudo apt-get update