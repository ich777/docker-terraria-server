# Terraria Dedicated Server in Docker optimized for Unraid

This Docker will download and install Terraria and run it.

***SERVER PASSWORD: Docker***

Update Notice: The Container will check on every start/restart if there is a newer version of the game available and install it if so.

CONSOLE: To connect to the console open up the terminal on the host machine and type in: 'docker exec -u terraria -ti [Name of your Container] screen -xS Terraria' (without quotes) to exit the screen session press CTRL+A and then CTRL+D or simply close the terminal window in the first place.

## Env params

| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefiles | /serverdata/serverfiles |
| GAME_PARAMS | Commandline startup parameters | -config serverconfig.txt |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

# Run example

docker run --name Terraria -d \
    -p 7777:7777/udp \
    --env 'GAME_PARAMS=-config serverconfig.txt' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/terraria:/serverdata/serverfiles \
    --restart=unless-stopped \
    ich777/terrariaserver:latest

This Docker was mainly created for the use with Unraid, if you don’t use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/