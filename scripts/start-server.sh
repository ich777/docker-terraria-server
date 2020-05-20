#!/bin/bash
LAT_V="${GAME_VERSION//.}"
CUR_V="$(find ${SERVER_DIR} -name terraria-* | cut -d '-' -f 2,3)"
if [ "$LAT_V" -lt "1402" ]; then
	DL_LINK="http://terraria.org/server/"
else
	DL_LINK=https://terraria.org$(curl -sL https://terraria.org/ | grep -Eo $'[^\'"]+terraria-server-[^\'"]+')
	DL_TOP=?${DL_LINK##*\?}
    LAT_V="$(echo ${DL_LINK##*-} | cut -d '.' -f 1)"
    DL_LINK=${DL_LINK%terraria*}
	echo "------------------------------------------------------------------------------------"
	echo "---------------------------------W A R N I N G--------------------------------------"
	echo "---The variable Prefered Version doesn't work anymore for Version 1.4.0.2 and up----"
	echo "---The conatainer will always pull the latest version if set to 1.4.0.2 or higher---"
	echo "------------------------------------------------------------------------------------"
fi

if [ -f ${SERVER_DIR}/terraria-server-$LAT_V.zip ]; then
	if [ -f ${SERVER_DIR}/terraria-$CUR_V ]; then
		rm ${SERVER_DIR}/terraria-$CUR_V
	fi
    cd ${SERVER_DIR}
	echo "---Found Terraria v${GAME_VERSION} locally, installing---"
	unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
    cp -R -f ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
    rm -R ${SERVER_DIR}/$LAT_V
    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
    touch ${SERVER_DIR}/terraria-$LAT_V
else
	echo "---Version Check---"
	if [ ! -d "${SERVER_DIR}/lib" ]; then
    	echo "---Terraria not found, downloading!---"
    	cd ${SERVER_DIR}
    	if wget -q -nc --show-progress --progress=bar:force:noscroll -O terraria-server-$LAT_V.zip "$DL_LINK"terraria-server-$LAT_V.zip"$DL_TOP" ; then
			echo "---Successfully downloaded Terraria v${GAME_VERSION}---"
		else
			echo "------------------------------------------------------------------------------"
			echo "---Can't download Terraria v${GAME_VERSION}, putting server into sleep mode---"
			echo "------You can also place the Terraria Server zip in the main directory to-----"
			echo "---install it manually, don't forget to set it to the right version in your---"
			echo "----------Docker configuration, otherwise it won't find the zip file!---------"
			echo "------------------------------------------------------------------------------"
		fi
	    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
	    cp -R -f ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
	    rm -R ${SERVER_DIR}/$LAT_V
	    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
	    touch ${SERVER_DIR}/terraria-$LAT_V
	elif [ "$LAT_V" != "$CUR_V" ]; then
	    echo "---Newer version found, installing!---"
	    rm ${SERVER_DIR}/terraria-$CUR_V
	    cd ${SERVER_DIR}
	    if wget -q -nc --show-progress --progress=bar:force:noscroll -O terraria-server-$LAT_V.zip "$DL_LINK"terraria-server-$LAT_V.zip"$DL_TOP" ; then
			echo "---Successfully downloaded Terraria v${GAME_VERSION}---"
		else
			echo "------------------------------------------------------------------------------"
			echo "---Can't download Terraria v${GAME_VERSION}, putting server into sleep mode---"
			echo "------You can also place the Terraria Server zip in the main directory to-----"
			echo "---install it manually, don't forget to set it to the right version in your---"
			echo "----------Docker configuration, otherwise it won't find the zip file!---------"
			echo "------------------------------------------------------------------------------"
		fi
	    unzip -q ${SERVER_DIR}/terraria-server-$LAT_V.zip
	    cp -R -f ${SERVER_DIR}/$LAT_V/Linux/* ${SERVER_DIR}
	    rm -R ${SERVER_DIR}/$LAT_V
	    rm -R ${SERVER_DIR}/terraria-server-$LAT_V.zip
	    touch ${SERVER_DIR}/terraria-$LAT_V
	elif [ "$LAT_V" == "$CUR_V" ]; then
	    echo "---Terraria Version up-to-date---"
	else
  	echo "---Something went wrong, putting server in sleep mode---"
  	sleep infinity
	fi
fi


CUR_MOD_V="$(find ${SERVER_DIR} -name tshock_* | cut -d '_' -f2)"
LAT_MOD_V="$(curl -s https://api.github.com/repos/Pryaxis/TShock/releases/latest | grep tag_name | cut -d '"' -f4 | cut -d 'v' -f2)"

echo "---Version Check of TShock Mod---"
if [ -z "$CUR_MOD_V" ]; then
    echo "---TShock Mod not found! Downloading...---"
    cd ${SERVER_DIR}
    curl -s https://api.github.com/repos/Pryaxis/TShock/releases/latest \
    | grep "browser_download_url." \
    | cut -d ":" -f2,3 \
    | cut -d '"' -f2 \
    | wget -qi -
    unzip -qo /serverdata/serverfiles/tshock_$LAT_MOD_V.zip
    mv ${SERVER_DIR}/tshock_$LAT_MOD_V.zip ${SERVER_DIR}/tshock_$LAT_MOD_V
elif [ "$LAT_MOD_V" != "$CUR_MOD_V" ]; then
    echo "---Newer version found, installing!---"
    rm ${SERVER_DIR}/tshock_$CUR_MOD_V
    cd ${SERVER_DIR}
    curl -s https://api.github.com/repos/Pryaxis/TShock/releases/latest \
    | grep "browser_download_url." \
    | cut -d ":" -f2,3 \
    | cut -d '"' -f2 \
    | wget -qi -
    unzip -qo /serverdata/serverfiles/tshock_$LAT_MOD_V.zip
    mv ${SERVER_DIR}/tshock_$LAT_MOD_V.zip ${SERVER_DIR}/tshock_$LAT_MOD_V
elif [ "$LAT_MOD_V" == "$CUR_MOD_V" ]; then
    echo "---TShock Mod Version up-to-date---"
else
    echo "---Something went wrong, putting server in sleep mode---"
    sleep infinity
fi

echo "---Prepare Server---"
if [ -f ${SERVER_DIR}/System.dll ]; then
	rm ${SERVER_DIR}/System.dll
fi
if [ ! -f "${SERVER_DIR}/serverconfig.txt" ]; then
  echo "---No serverconfig.txt found, downloading...---"
  cd ${SERVER_DIR}
  wget -qi serverconfig.txt "https://raw.githubusercontent.com/ich777/docker-terraria-server/master/config/serverconfig.txt"
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
screen -S watchdog -d -m /opt/scripts/start-watchdog.sh
tail -f ${SERVER_DIR}/masterLog.0