#!/bin/bash

DO=$1

TESTDIR=/usr/src/libreswan/testing/pluto
TESTNAME=enet-01-psk
GW_DEV=e1ls107

$TESTDIR/$TESTNAME/sideclear.sh $TESTDIR $TESTNAME $GW_DEV right left
[[ $DO == 'reset' ]] && exit
$TESTDIR/$TESTNAME/sideinit.sh $TESTDIR $TESTNAME $GW_DEV right left
