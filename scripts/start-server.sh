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
    rm -R ${SERVER_DIR}/$LAT_V
elif [ "$LAT_V" != "$CUR_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${SERVER_DIR}/terraria-$CUR_V
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

CUR_MOD_V="$(find ${SERVER_DIR} -name tmodloader_* | cut -d '_' -f2)"
LAT_MOD_V="$(curl -s https://api.github.com/repos/tModLoader/tModLoader/releases/latest | grep tag_name | cut -d '"' -f4 | cut -d 'v' -f2)"

echo "---Version Check of tModloader---"
if [ -z "$CUR_MOD_V" ]; then
    echo "---tModloader not found! Downloading...---"
    cd ${SERVER_DIR}
    curl -s https://api.github.com/repos/tModLoader/tModLoader/releases/latest \
    | grep "browser_download_url." \
    | grep "tModLoader.Linux.*" \
    | cut -d ":" -f2,3 \
    | cut -d '"' -f2 \
    | wget -nc --show-progress --progress=bar:force:noscroll -qi -
    unzip -o ${SERVER_DIR}/tModLoader.Linux.v$LAT_MOD_V.zip
    rm ${SERVER_DIR}/tModLoader.Linux.v$LAT_MOD_V.zip
    touch ${SERVER_DIR}/tmodloader_$LAT_MOD_V
elif [ "$LAT_MOD_V" != "$CUR_MOD_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${SERVER_DIR}/tmodloader_$CUR_MOD_V
    cd ${SERVER_DIR}
    curl -s https://api.github.com/repos/tModLoader/tModLoader/releases/latest \
    | grep "browser_download_url." \
    | grep "tModLoader.Linux.*" \
    | cut -d ":" -f2,3 \
    | cut -d '"' -f2 \
    | wget -nc --show-progress --progress=bar:force:noscroll -qi -
    unzip -o ${SERVER_DIR}/tModLoader.Linux.v$LAT_MOD_V.zip
    rm ${SERVER_DIR}/tModLoader.Linux.v$LAT_MOD_V.zip
    touch ${SERVER_DIR}/tmodloader_$LAT_MOD_V
elif [ "$LAT_MOD_V" == "$CUR_MOD_V" ]; then
    echo "---tModloader Version up-to-date---"
else
    echo "---Something went wrong, putting server in sleep mode---"
    sleep infinity
fi

echo "---Prepare Server---"
if [ ! -d ${SERVER_DIR}/TML ]; then
	mkdir ${SERVER_DIR}/TML
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
screen -S Terraria -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m ${SERVER_DIR}/tModLoaderServer -tmlsavedirectory ${SERVER_DIR}/TML ${GAME_PARAMS}
sleep 2
tail -f ${SERVER_DIR}/masterLog.0