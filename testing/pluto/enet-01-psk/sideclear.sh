#!/bin/bash

TESTDIR=$1
TESTNAME=$2
GW_DEV=$3
SIDE=$4
OPPOSITE=$5
NS=ns$SIDE
GW_MASK=8

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
echo "---------------------------------  CLEAR  -------------------------------------------"
echo "${LOCAL_IP}/32===${GW_IP}<${GW_IP}>...${OPPOSITE_GW_IP}<${OPPOSITE_GW_IP}>===${REMOTE_IP}/32"
echo "-------------------------------------------------------------------------------------"

ns_exec "ipsec stop"
ns_exec "rm /etc/ipsec.d/*.db"
ns_exec "ip xfrm state flush"
ns_exec "ip xfrm policy flush"
ns_exec "ip route del ${LOCAL_IP}/32"
ns_exec "ip route del ${REMOTE_IP}/32"
ns_exec "ip route del ${GW_IP}/${GW_MASK}"
ns_exec "ip route del ${OPPOSITE_GW_IP}/${GW_MASK}"
ns_exec "ip addr del ${LOCAL_IP}/32 dev lo"
ns_exec "ip addr del ${REMOTE_IP}/32 dev lo"
ns_exec "ip addr del ${GW_IP}/${GW_MASK} dev ${GW_DEV}"
ns_exec "ip addr del ${OPPOSITE_GW_IP}/${GW_MASK} dev ${GW_DEV}"

set -x

ns_exec "ip xfrm state"
ns_exec "ip xfrm policy"
ns_exec "ip addr"
ns_exec "ip route"
ns_exec "ipsec status"
ns_exec "$TESTDIR/bin/ipsec-look.sh"
ns_exec "setkey -D"

set +x

