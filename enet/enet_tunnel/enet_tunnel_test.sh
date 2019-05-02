#!/bin/bash

set +x

SRCDIR=$(pwd)/programs/pluto
TESTDIR=$(pwd)/enet/enet_tunnel

gcc -g $TESTDIR/enet_tunnel_test.c -I $SRCDIR -I $(pwd)/include -I /usr/include/nss3 -I /usr/include/nspr4 -lcurl -o $TESTDIR/enet_tunnel_test; BUILD_STATUS=$(echo "$?")

ENET_VPN_URI="http://172.17.0.1:44000" $TESTDIR/enet_tunnel_test

echo
echo "BUILD_STATUS=$BUILD_STATUS"
echo

set +x
