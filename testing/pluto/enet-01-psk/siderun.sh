#!/bin/bash

TESTDIR=$1
TESTNAME=$2
SIDE=$3
OPPOSITE=$4

LOCAL_IP=$(cat $TESTDIR/$TESTNAME/$SIDE.conf | sed -n "s~${SIDE}subnet=\([0-9]*\)\.\([0-9]*\.[0-9]*\)\.[0-9]*/24~\1\.\2\.\1~p")
REMOTE_IP=$(cat $TESTDIR/$TESTNAME/$OPPOSITE.conf | sed -n "s~${OPPOSITE}subnet=\([0-9]*\)\.\([0-9]*\.[0-9]*\)\.[0-9]*/24~\1\.\2\.\1~p")

set -x

ping -i 0.01 ${REMOTE_IP}

set +x
