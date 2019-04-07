#!/bin/bash

set -x

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
HOST_VPN_DIR=$(pwd)/../enet-vpn-gw
VPN_SHARED_DIR="/shared/enet${ACENIC_ID}-vpn"
LIBRESWAN_SHARED_DIR="${VPN_SHARED_DIR}/$DOCKER_INST"
HOST_SHARED_DIR=${HOST_VPN_DIR}${LIBRESWAN_SHARED_DIR}

case ${IMG_DOMAIN} in
	"hub")
	IMG_TAG=ethernity/libreswan:$LIBRESWAN_VERSION
	docker pull $IMG_TAG
	;;
	*)
	IMG_TAG=local/libreswan:$LIBRESWAN_VERSION
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
	--env ACENIC_ID=$ACENIC_ID \
	--env DOCKER_INST=$DOCKER_INST \
	--hostname=$DOCKER_INST \
	--name=$DOCKER_INST \
	-v ${HOST_SHARED_DIR}/ipsec.conf:/etc/ipsec.conf \
	-v ${HOST_SHARED_DIR}/ipsec.secrets:/etc/ipsec.secrets \
	-v ${HOST_SHARED_DIR}/conns:$LIBRESWAN_SHARED_DIR/conns \
	$IMG_TAG

set +x
