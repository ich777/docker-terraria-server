#!/bin/bash
CUR_V="$(grep "Version" /serverdata/serverfiles/changelog.txt 2>/dev/null | head -1 | cut -d ' ' -f 2)"
CUR_V="${CUR_V//./}"
DL_LINK=https://terraria.org$(curl -sL https://terraria.org/ | grep -Eo $'[^\'"]+terraria-server-[^\'"]+')
DL_TOP=?${DL_LINK##*\?}
LAT_V="$(echo ${DL_LINK##*-} | cut -d '.' -f 1)"
DL_LINK=${DL_LINK%terraria*}

echo "---Version Check---"
if [ ! -d "${SERVER_DIR}/lib" ]; then
   	echo "---Terraria not found, downloading!---"
   	cd ${SERVER_DIR}
   	if wget -q -nc --show-progress --progress=bar:force:noscroll -O terraria-server-$LAT_V.zip "$DL_LINK"terraria-server-$LAT_V.zip"$DL_TOP" ; then
		echo "---Successfully downloaded Terraria---"
	else
		echo "------------------------------------------------------------------------------"
		echo "------------Can't download Terraria, putting server into sleep mode-----------"
		echo "------------------------------------------------------------------------------"
	fi
    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
    cp -R -f ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
elif [ "$LAT_V" != "$CUR_V" ]; then
    echo "---Newer version found, installing!---"
    cd ${SERVER_DIR}
    if wget -q -nc --show-progress --progress=bar:force:noscroll -O terraria-server-$LAT_V.zip "$DL_LINK"terraria-server-$LAT_V.zip"$DL_TOP" ; then
		echo "---Successfully downloaded Terraria---"
	else
		echo "------------------------------------------------------------------------------"
		echo "------------Can't download Terraria, putting server into sleep mode-----------"
		echo "------------------------------------------------------------------------------"
	fi
    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
    cp -R -f ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/$LAT_V
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
elif [ "$LAT_V" == "$CUR_V" ]; then
    echo "---Terraria Version up-to-date---"
else
 	echo "---Something went wrong, putting server in sleep mode---"
 	sleep infinity
fi

echo "---Prepare Server---"
if [ ! -f "${SERVER_DIR}/serverconfig.txt" ]; then
  echo "---No serverconfig.txt found, downloading...---"
  cd ${SERVER_DIR}
  wget -qi serverconfig.txt "https://raw.githubusercontent.com/ich777/docker-terraria-server/master/config/serverconfig.txt"
fi
if [ ! -d ${SERVER_DIR}/Worlds ]; then
	echo "---No World found, downloading---"
	mkdir ${SERVER_DIR}/Worlds
	cd ${SERVER_DIR}/Worlds
	wget -qi ${SERVER_DIR}/Worlds/world.zip "https://raw.githubusercontent.com/ich777/docker-terraria-server/master/world.zip"
	unzip ${SERVER_DIR}/Worlds/world.zip
	rm ${SERVER_DIR}/Worlds/world.zip
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
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0