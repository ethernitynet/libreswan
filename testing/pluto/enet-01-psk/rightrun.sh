#!/bin/bash

TESTDIR=/usr/src/libreswan/testing/pluto
TESTNAME=enet-01-psk

$TESTDIR/$TESTNAME/siderun.sh $TESTDIR $TESTNAME right left
