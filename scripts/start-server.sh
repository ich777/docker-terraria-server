#!/bin/bash
CUR_V="$(grep "Version" /serverdata/serverfiles/changelog.txt 2>/dev/null | head -1 | cut -d ' ' -f 2)"
# Deprecated since Terraria changed how to get the download URL again
#DL_LINK=https://terraria.org$(curl -sL https://terraria.org/ | grep -Eo $'[^\'"]+terraria-server-[^\'"]+')
#DL_TOP=?${DL_LINK##*\?}
#LAT_V="$(echo ${DL_LINK##*-} | cut -d '.' -f 1)"
#DL_LINK=${DL_LINK%terraria*}

rm -rf ${SERVER_DIR}/Terraria-Mobile-Server-*.zip

echo "---Version Check---"
if [ ! -d "${SERVER_DIR}/lib" ]; then
	echo "---Terraria Mobile not found, downloading!---"
   	cd ${SERVER_DIR}
   	if wget -q -nc --show-progress --progress=bar:force:noscroll -O Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V.zip "https://www.terraria.org/api/download/mobile-dedicated-server/Terraria-Mobile-Server-${TERRARIA_MOBILE_SRV_V}.zip" ; then
		echo "---Successfully downloaded Terraria Mobile---"
	else
		echo "------------------------------------------------------------------------------"
		echo "--------Can't download Terraria Mobile, putting server into sleep mode--------"
		echo "------------------------------------------------------------------------------"
		sleep infinity
	fi
    unzip -qo ${SERVER_DIR}/Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V.zip
    cp -R -f ${SERVER_DIR}/Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V/Linux/* ${SERVER_DIR}/
    rm -R ${SERVER_DIR}/Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V.zip ${SERVER_DIR}/Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V
elif [ "$TERRARIA_MOBILE_SRV_V" != "$CUR_V" ]; then
    echo "---Newer version found, installing!---"
   	cd ${SERVER_DIR}
   	if wget -q -nc --show-progress --progress=bar:force:noscroll -O Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V.zip "https://www.terraria.org/api/download/mobile-dedicated-server/Terraria-Mobile-Server-${TERRARIA_MOBILE_SRV_V}.zip" ; then
		echo "---Successfully downloaded Terraria Mobile---"
	else
		echo "------------------------------------------------------------------------------"
		echo "--------Can't download Terraria Mobile, putting server into sleep mode--------"
		echo "------------------------------------------------------------------------------"
		sleep infinity
	fi
    unzip -qo ${SERVER_DIR}/Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V.zip
    cp -R -f ${SERVER_DIR}/Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V/Linux/* ${SERVER_DIR}/
    rm -R ${SERVER_DIR}/Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V.zip ${SERVER_DIR}/Terraria-Mobile-Server-$TERRARIA_MOBILE_SRV_V
elif [ "$TERRARIA_MOBILE_SRV_V" == "$CUR_V" ]; then
    echo "---Terraria Mobile Server v$TERRARIA_MOBILE_SRV_V up-to-date---"
	echo "---If you want to change the version add a Variable with the Key: 'TERRARIA_MOBILE_SRV_V' and the Value eg: '1.4.2.3'."
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
echo "---Server ready---"
chmod -R ${DATA_PERM} ${DATA_DIR}
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;
screen -wipe 2&>/dev/null

echo "---Start Server---"
cd ${SERVER_DIR}
screen -S Terraria -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/TerrariaServer.bin.x86_64 ${GAME_PARAMS}
sleep 2
if [ "${ENABLE_WEBCONSOLE}" == "true" ]; then
    /opt/scripts/start-gotty.sh 2>/dev/null &
fi
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0
