# Terraria Mobile Dedicated Server in Docker optimized for Unraid

This Docker will download and install the Terraria Mobile Server and run it.

Update Notice: The Container will check on every start/restart if there is a newer version of the game available and install it if so.

WEB CONSOLE: You can connect to the Terraria Mobile Server console by opening your browser and go to HOSTIP:9013 (eg: 192.168.1.1:9013) or click on WebUI on the Docker page within Unraid.

## Env params

| Name        | Value                          | Example                  |
| ----------- | ------------------------------ | ------------------------ |
| SERVER_DIR  | Folder for gamefiles           | /serverdata/serverfiles  |
| GAME_PARAMS | Commandline startup parameters | -config serverconfig.txt |
| UID         | User Identifier                | 99                       |
| GID         | Group Identifier               | 100                      |

# Run example

```bash
docker run --name TerrariaMobile -d \
    -p 7777:7777/udp -p 9013:8080 \
    --env 'GAME_PARAMS=-config serverconfig.txt' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /path/to/terraria-mobile:/serverdata/serverfiles \
    --restart=unless-stopped \
    ich777/terrariaserver:mobile
```

This Docker was mainly created for the use with Unraid, if you don’t use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/
