#!/bin/bash

# docker-machine start consul
eval $(docker-machine env consul)
docker start consul