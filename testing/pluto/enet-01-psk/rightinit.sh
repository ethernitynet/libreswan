#!/bin/bash

DO=$1

TESTDIR=/usr/src/libreswan/testing/pluto
TESTNAME=enet-01-psk

$TESTDIR/$TESTNAME/sideclear.sh $TESTDIR $TESTNAME right left
[[ $DO == 'reset' ]] && exit
$TESTDIR/$TESTNAME/sideinit.sh $TESTDIR $TESTNAME right left
