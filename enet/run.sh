#!/bin/bash

ACENIC_ID=${1:-0}
ACENIC_PORT=${2:-104}
IMG_DOMAIN=${3:-local}
LIBRESWAN_VERSION=${4:-v3.27}

docker volume rm $(docker volume ls -qf dangling=true)
#docker network rm $(docker network ls | grep "bridge" | awk '/ / { print $1 }')
docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
docker rmi $(docker images | grep "none" | awk '/ / { print $3 }')
docker rm $(docker ps -qa --no-trunc --filter "status=exited")

DOCKER_INST="enet${ACENIC_ID}_libreswan${ACENIC_PORT}"
TGT_SRC_DIR=/root/ETHERNITY/GITHUB
VPN_SHARED_DIR="${TGT_SRC_DIR}/enet-vpn-gw/shared/${DOCKER_INST}"

case ${IMG_DOMAIN} in
	"hub")
	IMG_TAG=ethernitynet/enet-libreswan:$LIBRESWAN_VERSION
	docker pull $IMG_TAG
	;;
	*)
	IMG_TAG=local/enet-libreswan:$LIBRESWAN_VERSION
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
	-t \
	-d \
	--rm \
	--ipc=host \
	--privileged \
	-v ${VPN_SHARED_DIR}/ipsec.conf:/etc/ipsec.conf \
	-v ${VPN_SHARED_DIR}/ipsec.secrets:/etc/ipsec.secrets \
	--env ACENIC_ID=$ACENIC_ID \
	--env DOCKER_INST=$DOCKER_INST \
	--hostname=$DOCKER_INST \
	--name=$DOCKER_INST \
	$IMG_TAG
