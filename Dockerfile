FROM ubuntu:20.04

ENV STEAM_PATH="/home/steam" \
	SERVER_PATH="/home/steam/.config" \
	STEAM_CMD="/home/steam/.steam/steamcmd" \
	GROUP_ID=10000 \
	USER_ID=10000 \
	DOCKER_USER=valheim \
	\
	SERVER_NAME="" \
	SERVER_PASSWORD=""

COPY entrypoint.sh "$STEAM_PATH/entrypoint.sh"

RUN dpkg --add-architecture i386 && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y curl wget file tar bzip2 gzip unzip bsdmainutils python3 cpio util-linux ca-certificates binutils bc jq tmux netcat lib32gcc1 lib32stdc++6 libsdl2-2.0-0:i386 && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections && \
    apt-get install -y steamcmd && \
    \
    groupadd -g "$GROUP_ID" "$DOCKER_USER" && \
    useradd -d "$STEAM_PATH" -g "$GROUP_ID" -u "$USER_ID" -m "$DOCKER_USER" && \
    mkdir -p "$SERVER_PATH" && \
    chown -R "$DOCKER_USER:$DOCKER_USER" "$STEAM_PATH" && \
    \
    wget -O "$STEAM_PATH/linuxgsm.sh" https://linuxgsm.sh && \
    \
    apt-get clean && apt-get autoclean && \
    \
    chmod +x "$STEAM_PATH/entrypoint.sh" "$STEAM_PATH/linuxgsm.sh" && \
    chown "$DOCKER_USER:$DOCKER_USER" "$STEAM_PATH/entrypoint.sh" "$STEAM_PATH/linuxgsm.sh"

USER "$DOCKER_USER"
WORKDIR "$STEAM_PATH"
EXPOSE 2456/udp 2457/udp
ENTRYPOINT "$STEAM_PATH/entrypoint.sh"
