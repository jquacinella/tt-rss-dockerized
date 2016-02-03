#/bin/bash

# docker-machine start personal-swarm-master
# docker-machine start personal-swarm-node1 

eval "$(docker-machine env --swarm personal-swarm-master)"

docker network create personal-net

docker run --net personal-net -d -e constraint:node==personal-swarm-node1  --name registrator-node1 --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://$(docker-machine ip consul):8500/

docker run --net personal-net -d -e constraint:node==personal-swarm-master --name registrator-master --volume=/var/run/docker.sock:/tmp/docker.sock gliderlabs/registrator:latest consul://$(docker-machine ip consul):8500/