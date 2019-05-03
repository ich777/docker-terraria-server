#!/bin/bash
LAT_V="${GAME_VERSION//.}
CUR_V="$(find $DATA_DIR -name terraria-* | cut -d '-' -f 2,3)"

echo "---Version Check---"
if [ ! -f "${SERVER_DIR}/TerrariaServer.bin.x86_64" ]; then
    echo "---Terraria not found, downloading!---"
    cd ${SERVER_DIR}
    wget -q - http://terraria.org/server/terraria-server-$LAT_V.zip --show-progress
    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
    mv ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/$LAT_V
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
    touch ${DATA_DIR}/terraria-$LAT_V
elif [ "$LAT_V" != "$CUR_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${DATA_DIR}/terraria-$CUR_V
    cd ${SERVER_DIR}
    wget -q - http://terraria.org/server/terraria-server-$LAT_V.zip --show-progress
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


if [ "${GAME_MOD}" == "tshock" ]; then
    CUR_MOD_V="$(find ${DATA_DIR} -name tshock* | cut -d '_' -f 2)"
    LAT_MOD_V="$(curl -s https://api.github.com/repos/Pryaxis/TShock/releases/latest | grep tag_name | cut -d '"' -f4 | cut -d 'v' -f2)"

echo "---Version Check of TShock Mod---"
    if [ -z "$CUR_MOD_V" ]; then
       echo "---TShock Mod not found!---"
       cd ${SERVER_DIR}
       curl -s https://api.github.com/repos/Pryaxis/TShock/releases/latest \
       | grep "browser_download_url." \
       | cut -d ":" -f2,3 \
       | cut -d '"' -f2 \
       | wget -qi -
       unzip -q /serverdata/serverfiles/tshock_$LAT_MOD_V.zip
       mv ${SERVER_DIR}/tshock_$LAT_MOD_V.zip ${DATA_DIR}/tshock_$LAT_MOD_V
    elif [ "$LAT_MOD_V" != "$CUR_MOD_V" ]; then
       echo "---Newer version found, installing!---"
       rm ${DATA_DIR}/tshock_$CUR_MOD_V
       cd ${SERVER_DIR}
       curl -s https://api.github.com/repos/Pryaxis/TShock/releases/latest \
       | grep "browser_download_url." \
       | cut -d ":" -f2,3 \
       | cut -d '"' -f2 \
       | wget -qi -
       unzip -q /serverdata/serverfiles/tshock_$LAT_MOD_V.zip
       mv ${SERVER_DIR}/tshock_$LAT_MOD_V.zip ${DATA_DIR}/tshock_$LAT_MOD_V
    elif [ "$LAT_MOD_V" == "$CUR_MOD_V" ]; then
       echo "---TShock Mod Version up-to-date---"
    else
       echo "---Something went wrong, putting server in sleep mode---"
       sleep infinity
    fi
fi

echo "---Prepare Server---"
if [ ! -f "${SERVER_DIR}/serverconfig.txt" ]; then
  echo "---No serverconfig.txt found, downloading...---"
  cd ${SERVER_DIR}
  wget -qi serverconfig.txt "https://raw.githubusercontent.com/ich777/docker-terraria-server/master/config/serverconfig.txt"
fi
echo "---Server ready---"
chmod -R 770 ${DATA_DIR}

if [ "${GAME_MOD}" == "tshock" ]; then
    echo "---Start Server---"
    cd ${SERVER_DIR}
    screen -S Terraria -m \
        mono-sgen TerrariaServer.exe \
        ${GAME_PARAMS}
else
    echo "---Start Server---"
    cd ${SERVER_DIR}
    screen -S Terraria -m ./TerrariaServer.bin.x86_64 ${GAME_PARAMS}
