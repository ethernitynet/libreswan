#!/bin/bash

set -x

libreswan_prerequisites() {

	echo 'libnss3-dev libnspr4-dev pkg-config libpam-dev 
		libcap-ng-dev libcap-ng-utils libselinux-dev 
		libcurl3-nss-dev flex bison gcc make libldns-dev 
		libunbound-dev libnss3-tools libevent-dev xmlto 
		libsystemd-dev iproute2 iptables 
		git'
}

libreswan_clone() {

	git_clone $SRC_DIR $LIBRESWAN_REPO $LIBRESWAN_VERSION
}

libreswan_pull() {

	git_pull "${LIBRESWAN_DIR}" "${LIBRESWAN_VERSION}"
}

libreswan_config() {

	echo 'libreswan_config'
}

libreswan_build() {

	cd "${LIBRESWAN_DIR}"
	make USE_FIPSCHECK=false USE_DNSSEC=false base
	make install-base
	cd -
}

set +x

