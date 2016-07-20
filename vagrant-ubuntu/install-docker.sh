#!/bin/bash

# See `https://docs.docker.com/engine/installation/linux/ubuntulinux/`.
apt-get update
apt-get upgrade -y
apt-get install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
bash -c 'echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" >>/etc/apt/sources.list.d/docker.list'
apt-get update
apt-get upgrade -y
#apt-get purge lxc-docker
apt-get install -y linux-image-extra-$(uname -r)
#apt-cache policy docker-engine
apt-get install -y docker-engine
