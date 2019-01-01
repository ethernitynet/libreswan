#!/bin/bash

libreswan_start() {

	modprobe af_key
	ipsec start
}
