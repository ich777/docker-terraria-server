#!/bin/bash
CUR_MOD_V="$(find ${SERVER_DIR} -name tshock_* 2>/dev/null | cut -d '_' -f2)" 
LAT_MOD_V="$(wget -qO- https://api.github.com/repos/Pryaxis/TShock/releases | grep tag_name | cut -d '"' -f4 | cut -d 'v' -f2 | sort -V | tail -1)"

rm -rf ${SERVER_DIR}/*-linux-arm-Release.tar

echo "---Version Check of TShock Mod---"
if [ -z "$CUR_MOD_V" ]; then
    echo "---TShock Mod not found! Downloading...---"
    DL_URL="$(wget -qO- https://api.github.com/repos/Pryaxis/TShock/releases/latest | grep "browser_download_url." | grep "linux-x64-Release.zip" | cut -d '"' -f4)"
    cd ${SERVER_DIR}
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/tshock_$LAT_MOD_V.zip "$DL_URL" ; then
        echo "---Successfully downloaded TShock Mod v$LAT_MOD_V---"
    else
        echo "---Something went wrong, can't download TShock Mod v$LAT_MOD_V, putting container into sleep mode!---"
        sleep infinity
    fi
    unzip -qo ${SERVER_DIR}/tshock_$LAT_MOD_V.zip
    tar -C ${SERVER_DIR}/ -xvf TS*-linux-x64-Release.tar
    rm -rf ${SERVER_DIR}/tshock_$LAT_MOD_V.zip ${SERVER_DIR}/TS*-linux-x64-Release.tar
    touch ${SERVER_DIR}/tshock_$CUR_MOD_V
elif [ "$LAT_MOD_V" != "$CUR_MOD_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${SERVER_DIR}/tshock_$CUR_MOD_V
    DL_URL="$(wget -qO- https://api.github.com/repos/Pryaxis/TShock/releases/latest | grep "browser_download_url." | grep "linux-x64-Release.zip" | cut -d '"' -f4)"
    cd ${SERVER_DIR}
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O ${SERVER_DIR}/tshock_$LAT_MOD_V.zip "$DL_URL" ; then
        echo "---Successfully downloaded TShock Mod v$LAT_MOD_V---"
    else
        echo "---Something went wrong, can't download TShock Mod v$LAT_MOD_V, putting container into sleep mode!---"
        sleep infinity
    fi
    unzip -qo ${SERVER_DIR}/tshock_$LAT_MOD_V.zip
    tar -C ${SERVER_DIR}/ -xvf TS*-linux-x64-Release.tar
    rm -rf ${SERVER_DIR}/tshock_$LAT_MOD_V.zip ${SERVER_DIR}/TS*-linux-x64-Release.tar
    touch ${SERVER_DIR}/tshock_$CUR_MOD_V
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
  echo "---No serverconfig.txt found, copying...---"
  cp -f /config/serverconfig.txt ${SERVER_DIR}
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
    ./Tshock.Server \
    ${GAME_PARAMS}
sleep 2
if [ "${ENABLE_WEBCONSOLE}" == "true" ]; then
    /opt/scripts/start-gotty.sh 2>/dev/null &
fi
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0