#!/bin/bash

set +x

SRCDIR=$(pwd)/programs/pluto
TESTDIR=$(pwd)/enet/enet_tunnel

gcc -g $TESTDIR/enet_tunnel_test.c $SRCDIR/enet_tunnel.c -lcurl -o $TESTDIR/enet_tunnel_test; BUILD_STATUS=$(echo "$?")

$TESTDIR/enet_tunnel_test

echo
echo "BUILD_STATUS=$BUILD_STATUS"
echo

set +x
