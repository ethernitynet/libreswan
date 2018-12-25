#!/bin/bash

set -x

git_clone() {

	local_SRC_DIR=$1
	local_REPO_PATH=$2
	local_REPO_BRANCH=$3

	cd $local_SRC_DIR
	git config --global http.sslVerify false
	exec_log "git clone ${local_REPO_PATH} -b ${local_REPO_BRANCH}"
	git config --global http.sslVerify true
	cd -
}

git_pull() {

	local_REPO_ROOT=$1
	local_REPO_BRANCH=$2

	cd $local_REPO_ROOT
	git config --global http.sslVerify false
	exec_log "git pull origin ${local_REPO_BRANCH}"
	git config --global http.sslVerify true
	cd -
}

set +x
