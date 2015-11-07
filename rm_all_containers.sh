#!/bin/sh

docker rm -f $(docker ps -aq)

docker rmi -f $(docker images | grep none | awk '{print $3}')


