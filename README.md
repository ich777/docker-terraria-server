# Terraria-tModLoader64 Dedicated Server in Docker optimized for Unraid

This Docker will download and install Terraria and tModLoader64 and run it. 

***SERVER PASSWORD: Docker***

Update Notice: Change the game version to whatever version do you want and restart the docker.

WEB CONSOLE: You can connect to the Terraria console by opening your browser and go to HOSTIP:9013 (eg: 192.168.1.1:9013) or click on WebUI on the Docker page within Unraid.

## Env params

| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefiles | /serverdata/serverfiles |
| GAME_PARAMS | Commandline startup parameters | -config serverconfig.txt |
| GAME_VERSION | Preferred Game version | 1.3.5.3 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

# Run example

```
docker run --name Terraria-tModLoader64 -d \
    -p 7777:7777/udp -p 9013:8080 \
    --env 'GAME_PARAMS=-config serverconfig.txt' \
    --env 'GAME_VERSION=1.3.5.3' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/terraria-tmodloader64:/serverdata/serverfiles \
    --restart=unless-stopped \
    ich777/terrariaserver:tmodloader64
```

This Docker was mainly created for the use with Unraid, if you don’t use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/