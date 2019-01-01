#!/bin/bash

IMG_DOMAIN=${1:-local}
LIBRESWAN_VERSION=${2:-v3.27}
DOCKER_INST=${4:-enet-libreswan}

docker volume rm $(docker volume ls -qf dangling=true)
#docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
docker rm $(docker ps -qa --no-trunc --filter "status=exited")

case ${IMG_DOMAIN} in
	"hub")
	IMG_TAG=ethernitynet/$DOCKER_INST:$LIBRESWAN_VERSION
	docker pull $IMG_TAG
	;;
	*)
	IMG_TAG=local/$DOCKER_INST:$LIBRESWAN_VERSION
	LIBRESWAN_REPO="https://github.com/ethernitynet/libreswan.git"
	docker build \
		-t $IMG_TAG \
		--build-arg IMG_LIBRESWAN_REPO=$LIBRESWAN_REPO \
		--build-arg IMG_LIBRESWAN_VERSION=$LIBRESWAN_VERSION \
		./
	;;
esac

docker kill $DOCKER_INST
docker rm $DOCKER_INST
docker run \
	-ti \
	--ipc=host \
	--privileged \
	--name=$DOCKER_INST \
	$IMG_TAG \
	/bin/bash
