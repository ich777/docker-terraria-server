#!/bin/bash
killpid="$(pidof tModLoaderServer.bin.x86_64)"
while true
do
	tail --pid=$killpid -f /dev/null
	kill "$(pidof tail)"
	exit 0
done