#!/bin/bash

docker-machine create --driver virtualbox --virtualbox-memory "512" \
  --engine-insecure-registry registry.quacinella.org:5000 \
  consul

eval $(docker-machine env consul)
docker run -d  --name consul -p 8400:8400 -p 8500:8500 -p 53:53/udp -h consul-node1 progrium/consul -server -bootstrap -ui-dir /ui