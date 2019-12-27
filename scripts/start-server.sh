#!/bin/bash
LAT_V="${GAME_VERSION//.}"
CUR_V="$(find $DATA_DIR -name terraria-* | cut -d '-' -f 2,3)"
echo "---Setting umask to ${UMASK}---"
umask ${UMASK}

echo "---Checking for 'runtime' folder---"
if [ ! -d ${SERVER_DIR}/runtime ]; then
	echo "---'runtime' folder not found, creating...---"
	mkdir ${SERVER_DIR}/runtime
else
	echo "---"runtime" folder found---"
fi

echo "---Checking if Runtime is installed---"
if [ -z "$(find ${SERVER_DIR}/runtime -name jre*)" ]; then
    if [ "${RUNTIME_NAME}" == "basicjre" ]; then
    	echo "---Downloading and installing Runtime---"
		cd ${SERVER_DIR}/runtime
		if wget -q -nc --show-progress --progress=bar:force:noscroll https://github.com/ich777/runtimes/raw/master/jre/basicjre.tar.gz ; then
			echo "---Successfully downloaded Runtime!---"
		else
			echo "---Something went wrong, can't download Runtime, putting server in sleep mode---"
			sleep infinity
		fi
        tar --directory ${SERVER_DIR}/runtime -xvzf ${SERVER_DIR}/runtime/basicjre.tar.gz
        rm -R ${SERVER_DIR}/runtime/basicjre.tar.gz
    else
    	if [ ! -d ${SERVER_DIR}/runtime/${RUNTIME_NAME} ]; then
        	echo "---------------------------------------------------------------------------------------------"
        	echo "---Runtime not found in folder 'runtime' please check again! Putting server in sleep mode!---"
        	echo "---------------------------------------------------------------------------------------------"
        	sleep infinity
        fi
    fi
else
	echo "---Runtime found---"
fi


echo "---Version Check---"
if [ ! -d "${SERVER_DIR}/lib" ]; then
    echo "---Terraria not found, downloading!---"
    cd ${SERVER_DIR}
    wget -nc --show-progress --progress=bar:force:noscroll -q - http://terraria.org/server/terraria-server-$LAT_V.zip
    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
    mv ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/$LAT_V
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
    touch ${DATA_DIR}/terraria-$LAT_V
elif [ "$LAT_V" != "$CUR_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${DATA_DIR}/terraria-$CUR_V
    cd ${SERVER_DIR}
    wget -nc --show-progress --progress=bar:force:noscroll -q - http://terraria.org/server/terraria-server-$LAT_V.zip
    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
    mv ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/$LAT_V
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
    touch ${DATA_DIR}/terraria-$LAT_V
elif [ "$LAT_V" == "$CUR_V" ]; then
    echo "---Terraria Version up-to-date---"
else
  echo "---Something went wrong, putting server in sleep mode---"
  sleep infinity
fi

echo "---sleep---"
sleep infinity

CUR_MOD_V="$(find ${DATA_DIR} -name tmodloader_* | cut -d '_' -f2)"
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
    tar --overwrite -xvf ${SERVER_DIR}/tModLoader.Linux.v$LAT_MOD_V.tar.gz
    rm ${SERVER_DIR}/tModLoader.Linux.v$LAT_MOD_V.tar.gz
    touch ${DATA_DIR}/tmodloader_$LAT_MOD_V
elif [ "$LAT_MOD_V" != "$CUR_MOD_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${DATA_DIR}/tmodloader_$CUR_MOD_V
    cd ${SERVER_DIR}
    curl -s https://api.github.com/repos/tModLoader/tModLoader/releases/latest \
    | grep "browser_download_url." \
    | grep "tModLoader.Linux.*" \
    | cut -d ":" -f2,3 \
    | cut -d '"' -f2 \
    | wget -nc --show-progress --progress=bar:force:noscroll -qi -
    tar --overwrite -xvf ${SERVER_DIR}/tModLoader.Linux.v$LAT_MOD_V.tar.gz
    rm ${SERVER_DIR}/tModLoader.Linux.v$LAT_MOD_V.tar.gz
    touch ${DATA_DIR}/tmodloader_$LAT_MOD_V
elif [ "$LAT_MOD_V" == "$CUR_MOD_V" ]; then
    echo "---tModloader Version up-to-date---"
else
    echo "---Something went wrong, putting server in sleep mode---"
    sleep infinity
fi


echo "---Prepare Server---"
if [ ! -f "${SERVER_DIR}/serverconfig.txt" ]; then
  echo "---No serverconfig.txt found, downloading...---"
  cd ${SERVER_DIR}
  wget -nc --show-progress --progress=bar:force:noscroll -qi serverconfig.txt "https://raw.githubusercontent.com/ich777/docker-terraria-server/master/config/serverconfig.txt"
fi
echo "---Server ready---"
chmod -R 777 ${DATA_DIR}
echo "---Checking for old logs---"
find ${SERVER_DIR} -name "masterLog.*" -exec rm -f {} \;


echo "---Start Server---"
cd ${SERVER_DIR}
screen -S Terraria -L -Logfile ${SERVER_DIR}/masterLog.0 -d -m \
    mono-sgen TerrariaServer.exe \
    ${GAME_PARAMS}
sleep 2
tail -f ${SERVER_DIR}/masterLog.0