#!/bin/bash

LIBRESWAN_IMG=${1:-local}
LIBRESWAN_VERSION=${2:-v3.27}

docker volume rm $(docker volume ls -qf dangling=true)
#docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
docker rm $(docker ps -qa --no-trunc --filter "status=exited")

case ${LIBRESWAN_IMG} in
	"hub")
	LIBRESWAN_IMG=ethernitynet/libreswan:enet-$LIBRESWAN_VERSION
	docker pull $LIBRESWAN_IMG
	;;
	*)
	LIBRESWAN_IMG=local/libreswan:enet-$LIBRESWAN_VERSION
	LIBRESWAN_REPO="https://github.com/ethernitynet/libreswan.git"
	docker build \
		-t $LIBRESWAN_IMG \
		--build-arg IMG_LIBRESWAN_REPO=$LIBRESWAN_REPO \
		--build-arg IMG_LIBRESWAN_VERSION=$LIBRESWAN_VERSION \
		./
	;;
esac

docker run \
	-ti \
	--ipc=host \
	--privileged \
	$LIBRESWAN_IMG \
	/bin/bash
