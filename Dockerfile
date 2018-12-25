FROM ubuntu:latest
LABEL maintainer="Erez Buchnik <erezb@ethernitynet.com>"

ARG IMG_LIBRESWAN_REPO="https://github.com/ethernitynet/libreswan.git"
ARG IMG_LIBRESWAN_VERSION="v3.27"

ENV SRC_DIR=/usr/src
ENV LIBRESWAN_REPO="${IMG_LIBRESWAN_REPO}"
ENV LIBRESWAN_VERSION=$IMG_LIBRESWAN_VERSION
ENV LIBRESWAN_DIR=${SRC_DIR}/libreswan

COPY enet/app-entrypoint.sh ${SRC_DIR}/
COPY enet/utils/*.sh ${SRC_DIR}/utils/
COPY enet/env/*.sh ${SRC_DIR}/env/

RUN . ${SRC_DIR}/app-entrypoint.sh; \
	exec_apt_update

RUN . ${SRC_DIR}/app-entrypoint.sh; \
	exec_apt_install "$(libreswan_prerequisites)"

WORKDIR $SRC_DIR
RUN . ${SRC_DIR}/app-entrypoint.sh; \
	libreswan_clone

WORKDIR $LIBRESWAN_DIR
	
COPY enet/runtime/*.sh ${SRC_DIR}/runtime/

RUN . ${SRC_DIR}/app-entrypoint.sh; \
	libreswan_pull

RUN . ${SRC_DIR}/app-entrypoint.sh; \
	libreswan_build
