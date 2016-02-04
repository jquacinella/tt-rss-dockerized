#!/bin/bash

docker-machine create --driver virtualbox --virtualbox-memory "512" --swarm --swarm-master \
  --swarm-discovery consul://$(docker-machine ip consul):8500/ \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
  --engine-opt="cluster-advertise=eth1:2376" \
  --engine-insecure-registry registry.quacinella.org \
  personal-swarm-master

docker-machine create --driver virtualbox --virtualbox-memory "512" --swarm \
  --swarm-discovery consul://$(docker-machine ip consul):8500/ \
  --engine-opt="cluster-store=consul://$(docker-machine ip consul):8500" \
  --engine-opt="cluster-advertise=eth1:2376"  \
  --engine-insecure-registry registry.quacinella.org \
  personal-swarm-node1