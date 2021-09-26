#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset

readonly SERVER_EXECUTABLE="vhserver"
readonly SERVER_GAME="vhserver"

if [ -n "$SERVER_EXECUTABLE" ] && [ -e "${STEAM_PATH}/$SERVER_EXECUTABLE" ]; then
	echo "[entrypoint.sh]updating..."
	./"$SERVER_EXECUTABLE" update-lgsm
	./"$SERVER_EXECUTABLE" update
else
	echo "[entrypoint.sh]installing..."
	bash linuxgsm.sh "$SERVER_GAME"
	./"$SERVER_EXECUTABLE" auto-install
fi


# server is installed
# apply custom configuration
mkdir -p "$STEAM_PATH/lgsm/config-lgsm/vhserver" || true
echo "servername=\"$SERVER_NAME\"" > "$STEAM_PATH/lgsm/config-lgsm/vhserver/vhserver.cfg"
echo "serverpassword=\"$SERVER_PASSWORD\"" >> "$STEAM_PATH/lgsm/config-lgsm/vhserver/vhserver.cfg"

IS_RUNNING="true"
function stopServer() {
	echo "stopping server..."
	cd "${STEAM_PATH}"
	pid=$(pidof "$SERVER_EXECUTABLE")
	kill -2 "$pid" || true
	echo "server stopped!"
	echo "stopping entrypoint..."
	IS_RUNNING="false"
	echo "done!"
}
./"$SERVER_EXECUTABLE" start &
trap stopServer SIGTERM

# --- Wait for Shutdown ---
echo "Server is running, waiting for SIGTERM"
while [ "$IS_RUNNING" = "true" ]
do
	sleep 1s
done
echo "entrypoint stopped"
exit 0
