FROM ich777/debian-baseimage:latest_arm64

LABEL maintainer="admin@minenet.at"

RUN export TZ=Europe/Rome && \
	apt-get update && \
	ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && \
	echo $TZ > /etc/timezone && \
	apt-get -y install --no-install-recommends screen unzip curl && \
	rm -rf /var/lib/apt/lists/*

RUN apt update && \
    apt install -y apt-transport-https dirmngr gnupg ca-certificates && \
    apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 3FA7E0328081BFF6A14DA29AA6A19B38D3D831EF && \
	echo "deb https://download.mono-project.com/repo/debian stable-buster main" | tee /etc/apt/sources.list.d/mono-official-stable.list && \
	apt update && \
	apt install -y mono-devel

RUN wget -O /tmp/gotty.tar.gz https://github.com/yudai/gotty/releases/download/v1.0.1/gotty_linux_arm.tar.gz && \
	tar -C /usr/bin/ -xvf /tmp/gotty.tar.gz && \
	rm -rf /tmp/gotty.tar.gz

ENV DATA_DIR="/serverdata"
ENV SERVER_DIR="${DATA_DIR}/serverfiles"
ENV GAME_VERSION="template"
ENV GAME_MOD="template"
ENV GAME_PARAMS="template"
ENV TARRARIA_SRV_V="1.4.2.3"
ENV ENABLE_WEBCONSOLE="true"
ENV GOTTY_PARAMS="-w --title-format Terraria-tModloader"
ENV UMASK=000
ENV UID=99
ENV GID=100
ENV USER="terraria"
ENV DATA_PERM=770

RUN mkdir $DATA_DIR && \
	mkdir $SERVER_DIR && \
	useradd -d $DATA_DIR -s /bin/bash $USER && \
	chown -R $USER $DATA_DIR && \
	ulimit -n 2048

ADD /scripts/ /opt/scripts/
RUN chmod -R 777 /opt/scripts/

#Server Start
ENTRYPOINT ["/opt/scripts/start.sh"]