#!/bin/bash
ARCH=$(uname -m)

if [ "${ENABLE_TML64}" = "true" ]; then
	if [ "$ARCH" = "x86_64" ]; then
		killpid="$(pidof tModLoader64BitServer.bin.x86_64)"
	else
		killpid="$(pidof tModLoader64BitServer.bin.x86)"
	fi
else
	if [ "$ARCH" = "x86_64" ]; then
		killpid="$(pidof tModLoaderServer.bin.x86_64)"
	else
		killpid="$(pidof tModLoaderServer.bin.x86)"
	fi
fi

while true; do
	tail --pid=$killpid -f /dev/null
	kill "$(pidof tail)"
	exit 0
done
