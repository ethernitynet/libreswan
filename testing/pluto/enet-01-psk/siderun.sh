#!/bin/bash

TESTDIR=$1
TESTNAME=$2
SIDE=$3
OPPOSITE=$4

GW_IP=$(cat $TESTDIR/$TESTNAME/$SIDE.conf | sed -n "s~$SIDE=\([0-9\.]*\)~\1~p")
LOCAL_IP=$(cat $TESTDIR/$TESTNAME/$SIDE.conf | sed -n "s~${SIDE}subnet=\([0-9]*\)\.\([0-9]*\.[0-9]*\)\.[0-9]*/24~\1\.\2\.\1~p")
REMOTE_IP=$(cat $TESTDIR/$TESTNAME/$OPPOSITE.conf | sed -n "s~${OPPOSITE}subnet=\([0-9]*\)\.\([0-9]*\.[0-9]*\)\.[0-9]*/24~\1\.\2\.\1~p")

echo "GW_IP=${GW_IP} LOCAL_IP=${LOCAL_IP} REMOTE_IP=${REMOTE_IP}"
ip route replace ${REMOTE_IP}/32 via ${GW_IP} dev eth0 src ${LOCAL_IP}
ip addr
ip route

set -x

ipsec auto --verbose --add vpn_psk
ipsec status
ip xfrm state
ip xfrm policy

set +x

