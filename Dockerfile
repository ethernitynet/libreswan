FROM ubuntu:latest
LABEL maintainer="Erez Buchnik <erezb@ethernitynet.com>"

ARG IMG_LIBRESWAN_REPO="https://github.com/ethernitynet/libreswan.git"
ARG IMG_LIBRESWAN_VERSION="v3.27"
ARG IMG_LIBRESWAN_TEST_DIR="/usr/src/libreswan"

ENV SRC_DIR=/usr/src
ENV LIBRESWAN_REPO="${IMG_LIBRESWAN_REPO}"
ENV LIBRESWAN_VERSION=$IMG_LIBRESWAN_VERSION
ENV LIBRESWAN_DIR=${SRC_DIR}/libreswan
ENV LIBRESWAN_TEST_DIR=$IMG_LIBRESWAN_TEST_DIR

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

RUN echo "$(date)> Building Libreswan:"
RUN libreswan_pull
RUN libreswan_build

RUN if [[ ${LIBRESWAN_TEST_DIR} != ${LIBRESWAN_DIR} ]]; \
then \
/bin/bash -c ' \
	ln -s ${LIBRESWAN_DIR}/testing ${LIBRESWAN_TEST_DIR}/testing; \
	apt-get -y install python3 python3-distutils python3-pip vim tcpdump iputils-ping net-tools bridge-utils rsync ipsec-tools gdb curl sudo netcat jq; \
	pip3 install pexpect; \
	curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -; \
	apt-get -y install nodejs; \
	libreswan_pull; \
	libreswan_build; \
	echo "LIBRESWAN_TEST_DIR: ${LIBRESWAN_TEST_DIR}"'; \
else \
echo "WORKDIR: ${LIBRESWAN_TEST_DIR}"; \
fi
	
WORKDIR $LIBRESWAN_TEST_DIR

#CMD ["/bin/bash", "-c", "ipsec start"]
