# Terraria-tModLoader Dedicated Server in Docker optimized for Unraid

This Docker will download and install Terraria and tModLoader64 and run it. 

***SERVER PASSWORD: Docker***

Update Notice: Change the game version to whatever version do you want and restart the docker.

WEB CONSOLE: You can connect to the Terraria console by opening your browser and go to HOSTIP:9013 (eg: 192.168.1.1:9013) or click on WebUI on the Docker page within Unraid.

## Usage
```
docker run --name Terraria-tModLoader -d \
    -p 7777:7777 -p 9013:8080 \
    --env 'GAME_PARAMS=-config serverconfig.txt' \
    --env 'GAME_VERSION=1.4.2.3' \
    --env 'ENABLE_WEBCONSOLE=true' \
    --env 'ENABLE_TML64=false' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/terraria-tmodloader:/serverdata/serverfiles \
    --restart=unless-stopped \
    ich777/terrariaserver:tmodloader
```

## Params
The following is a list of all the parameters and what they do.

### Ports
| Name             | Port   | Example |
| ---------------- | ------ | ------- |
| Game Port        | `7777` | `7777`  |
| Web Console Port | `8080` | `9013`  |

### Environment Variables
| Name               | Key                 | Example                    |
| ------------------ | ------------------- | -------------------------- |
| Server Arguments   | `GAME_PARAMS`       | `-config serverconfig.txt` |
| Server Version     | `GAME_VERSION`      | `1.4.2.3`                  |
| Enable Web Console | `ENABLE_WEBCONSOLE` | `true`                     |
| Enable 64-bit TML  | `ENABLE_TML64`      | `false`                    |
| User Identifier    | `UID`               | `99`                       |
| Group Identifier   | `GID`               | `100`                      |

### Volumes
| Name         | Container Path            | Example                                 |
| ------------ | ------------------------- | --------------------------------------- |
| Server Files | `/serverdata/serverfiles` | `/mnt/user/appdata/terraria-tmodloader` |

This Docker was mainly created for the use with Unraid, if you don’t use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/