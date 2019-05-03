#!/bin/bash
LAT_V="${GAME_VERSION//.}"
CUR_V="$(find $DATA_DIR -name terraria-* | cut -d '-' -f 2,3)"

echo "---Version Check---"
if [ ! -d "${SERVER_DIR}/lib" ]; then
    echo "---Terraria not found, downloading!---"
    cd ${SERVER_DIR}
    wget -q - http://terraria.org/server/terraria-server-$LAT_V.zip
    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
    mv ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/$LAT_V
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
    touch ${DATA_DIR}/terraria-$LAT_V
elif [ "$LAT_V" != "$CUR_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${DATA_DIR}/terraria-$CUR_V
    cd ${SERVER_DIR}
    wget -q - http://terraria.org/server/terraria-server-$LAT_V.zip
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

echo "---Prepare Server---"
if [ ! -f "${SERVER_DIR}/serverconfig.txt" ]; then
  echo "---No serverconfig.txt found, downloading...---"
  cd ${SERVER_DIR}
  wget -qi serverconfig.txt "https://raw.githubusercontent.com/ich777/docker-terraria-server/master/config/serverconfig.txt"
fi
echo "---Server ready---"
chmod -R 770 ${DATA_DIR}

echo "---Start Server---"
cd ${SERVER_DIR}
screen -S Terraria -d -m ${SERVER_DIR}/TerrariaServer.bin.x86_64 ${GAME_PARAMS}
echo "--------------------------------------------------"
echo "       If you want to get detailed logs open      "
echo "a console and type in 'screen -r' (without quotes)"
echo "--------------------------------------------------"
sleep infinity
