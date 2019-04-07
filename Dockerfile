FROM ubuntu:latest
LABEL maintainer="Erez Buchnik <erezb@ethernitynet.com>"

ARG IMG_LIBRESWAN_REPO="https://github.com/ethernitynet/libreswan.git"
ARG IMG_LIBRESWAN_VERSION="v3.27"

ENV SRC_DIR=/usr/src
ENV LIBRESWAN_REPO="${IMG_LIBRESWAN_REPO}"
ENV LIBRESWAN_VERSION=$IMG_LIBRESWAN_VERSION
ENV LIBRESWAN_DIR=${SRC_DIR}/libreswan

COPY enet/app/ ${SRC_DIR}/
ENV BASH_ENV=${SRC_DIR}/docker-entrypoint.sh
SHELL ["/bin/bash", "-c"]

RUN exec_apt_update
RUN exec_apt_install "$(libreswan_prerequisites)"

WORKDIR $SRC_DIR
RUN libreswan_clone

WORKDIR $LIBRESWAN_DIR
	
COPY enet/runtime/ ${SRC_DIR}/runtime/
ENV BASH_ENV=${SRC_DIR}/app-entrypoint.sh

RUN libreswan_pull
RUN libreswan_build

#CMD ["/bin/bash", "-c", "ipsec start"]
