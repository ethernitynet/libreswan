#!/bin/bash

TESTDIR=$1
TESTNAME=$2
SIDE=$3
OPPOSITE=$4
NS=ns$SIDE

ns_exec() {

	local CMD=$1
	
	#ip netns exec $NS $CMD
	$CMD
}

GW_IP=$(cat $TESTDIR/$TESTNAME/$SIDE.conf | sed -n "s~$SIDE=\([0-9\.]*\)~\1~p")
OPPOSITE_GW_IP=$(cat $TESTDIR/$TESTNAME/$OPPOSITE.conf | sed -n "s~$OPPOSITE=\([0-9\.]*\)~\1~p")
LOCAL_IP=$(cat $TESTDIR/$TESTNAME/$SIDE.conf | sed -n "s~${SIDE}subnet=\([0-9]*\)\.\([0-9]*\.[0-9]*\)\.[0-9]*/24~\1\.\2\.\1~p")
REMOTE_IP=$(cat $TESTDIR/$TESTNAME/$OPPOSITE.conf | sed -n "s~${OPPOSITE}subnet=\([0-9]*\)\.\([0-9]*\.[0-9]*\)\.[0-9]*/24~\1\.\2\.\1~p")

#echo "GW_IP=${GW_IP} OPPOSITE_GW_IP=${OPPOSITE_GW_IP} LOCAL_IP=${LOCAL_IP} REMOTE_IP=${REMOTE_IP}"
echo
echo "---------------------------------  INIT  --------------------------------------------"
echo "${LOCAL_IP}/32===${GW_IP}<${GW_IP}>...${OPPOSITE_GW_IP}<${OPPOSITE_GW_IP}>===${REMOTE_IP}/32"
echo "-------------------------------------------------------------------------------------"

ns_exec "ip addr replace ${GW_IP}/32 dev eth0"
ns_exec "ip route replace ${OPPOSITE_GW_IP}/32 via ${GW_IP}"

ns_exec "cp $TESTDIR/$TESTNAME/$SIDE.conf /etc/ipsec.conf"
ns_exec "cp $TESTDIR/$TESTNAME/$SIDE.secrets /etc/ipsec.secrets"
ns_exec "ipsec initnss"
ns_exec "ipsec setup start"

ns_exec "ip addr replace ${LOCAL_IP}/32 dev lo"
ns_exec "ip route replace ${REMOTE_IP}/32 via ${GW_IP} dev eth0 src ${LOCAL_IP}"

set -x

ns_exec "ip xfrm state"
ns_exec "ip xfrm policy"
ns_exec "ip addr"
ns_exec "ip route"
ns_exec "ipsec status"
ns_exec "$TESTDIR/bin/ipsec-look.sh"
ns_exec "setkey -D"

set +x

