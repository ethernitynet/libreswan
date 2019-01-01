#!/bin/bash

set -x

print_log() {

	local_log_file="/tmp/img_log.log"
	local_log_format="\n$(date +"%Y.%m.%d %H:%M:%S") $1"
	shift
	printf "${local_log_format}" "'$@'" >> ${local_log_file}
}

exec_log() {

	local_exec_cmd="$@"
	local_exec_result="$($@)"
	
	print_log ">> %s\n%s\n%s\n" "${local_exec_cmd}" "${local_exec_result}" "---"
	echo "${local_exec_result}"
}

exec_remote() {

	local_remote_dir=$1
	local_remote_cmd=$2
	local_remote_ip=$3
	local_remote_user=$4
	local_remote_pass=$5

	local_exec_cmd="cd ${local_remote_dir}; ${local_remote_cmd}"
	local_ssh_cmd="sshpass -p ${local_remote_pass} ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no ${local_remote_user}@${local_remote_ip} /bin/bash -c '${local_exec_cmd}'"
	local_ssh_result="$(${local_ssh_cmd})"
	print_log ">>> %s\n%s\n%s\n" "${local_ssh_cmd}" "${local_ssh_result}" "---"
	echo "${local_ssh_result}"
}

exec_tgt() {

	local_remote_dir=$1
	local_remote_cmd=$2

	echo "$(exec_remote \"${local_remote_dir}\" \"${local_remote_cmd}\" \"${TGT_IP}\" \"${TGT_USER}\" \"${TGT_PASS}\")"
}

exec_apt_update() {

	apt-get -y update && apt-get install -y dialog apt-utils
}

exec_apt_install() {

	exec_log "apt-get install -y --no-install-recommends $@"
}

exec_apt_clean() {

	apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
}

exec_yum_install() {

	yum -y update
	exec_log "yum install -y $@"
}

set +x
