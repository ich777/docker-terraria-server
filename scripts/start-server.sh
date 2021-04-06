#!/bin/bash
CUR_MOD_V="$(find ${SERVER_DIR} -name tshock_* 2>/dev/null | cut -d '_' -f2)" 
LAT_MOD_V="$(curl -s https://api.github.com/repos/Pryaxis/TShock/releases | grep tag_name | cut -d '"' -f4 | cut -d 'v' -f2 | head -1)"

echo "---Version Check of TShock Mod---"
if [ -z "$CUR_MOD_V" ]; then
    echo "---TShock Mod not found! Downloading...---"
    cd ${SERVER_DIR}
    curl -s https://api.github.com/repos/Pryaxis/TShock/releases \
    | grep "browser_download_url." \
    | cut -d ":" -f2,3 \
    | cut -d '"' -f2 \
    | head -1 \
    | wget -q -O ${SERVER_DIR}/tshock_$LAT_MOD_V.zip -i -
    unzip -qo /serverdata/serverfiles/tshock_$LAT_MOD_V.zip
    cd TShock*
    cp -rf * ${SERVER_DIR}/
    mv ${SERVER_DIR}/tshock_$LAT_MOD_V.zip ${SERVER_DIR}/tshock_$LAT_MOD_V
elif [ "$LAT_MOD_V" != "$CUR_MOD_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${SERVER_DIR}/tshock_$CUR_MOD_V
    cd ${SERVER_DIR}
    curl -s https://api.github.com/repos/Pryaxis/TShock/releases \
    | grep "browser_download_url." \
    | cut -d ":" -f2,3 \
    | cut -d '"' -f2 \
    | head -1 \
    | wget -q -O ${SERVER_DIR}/tshock_$LAT_MOD_V.zip -i -
    unzip -qo /serverdata/serverfiles/tshock_$LAT_MOD_V.zip
    cp -rf * ${SERVER_DIR}/
    mv ${SERVER_DIR}/tshock_$LAT_MOD_V.zip ${SERVER_DIR}/tshock_$LAT_MOD_V
elif [ "$LAT_MOD_V" == "$CUR_MOD_V" ]; then
    echo "---TShock Mod Version up-to-date---"
else
    echo "---Something went wrong, putting server in sleep mode---"
    sleep infinity
fi

echo "---Prepare Server---"
if [ ! -f ~/.screenrc ]; then
    echo "defscrollback 30000
bindkey \"^C\" echo 'Blocked. Please use to command \"exit\" to shutdown the server or close this window to exit the terminal.'" > ~/.screenrc
fi
if [ ! -f "${SERVER_DIR}/serverconfig.txt" ]; then
  echo "---No serverconfig.txt found, downloading...---"
  cd ${SERVER_DIR}
  wget -qi serverconfig.txt "https://raw.githubusercontent.com/ich777/docker-terraria-server/master/config/serverconfig.txt"
fi
if [ ! -d ${SERVER_DIR}/Worlds ]; then
	echo "---No World found, downloading---"
	mkdir ${SERVER_DIR}/Worlds
	cd ${SERVER_DIR}/Worlds
	wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/Worlds/world.zip https://raw.githubusercontent.com/ich777/docker-terraria-server/master/world.zip
    sleep 1
	unzip ${SERVER_DIR}/Worlds/world.zip
    sleep 1
	rm ${SERVER_DIR}/Worlds/world.zip
fi
if [ -d ${SERVER_DIR}/deploy ]; then
    cd ${SERVER_DIR}/deploy
    mv ${SERVER_DIR}/deploy/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/deploy
fi
echo "---Server ready---"
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
screen -wipe 2&>/dev/null

echo "---Start Server---"
cd ${SERVER_DIR}
screen -S Terraria -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m \
    mono-sgen TerrariaServer.exe \
    ${GAME_PARAMS}
sleep 2
if [ "${ENABLE_WEBCONSOLE}" == "true" ]; then
    /opt/scripts/start-gotty.sh 2>/dev/null &
fi
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0