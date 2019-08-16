# Terraria Dedicated Server in Docker optimized for Unraid

This Docker will download and install Terraria and run it.
***SERVER PASSWORD: Docker***

Update Notice: Change the game version to whatever version do you want and restart the docker.

## Env params

| Name | Value | Example |
| --- | --- | --- |
| SERVER_DIR | Folder for gamefiles | /serverdata/serverfiles |
| GAME_PARAMS | Commandline startup parameters | -config serverconfig.txt |
| GAME_VERSION | Preferred Game version | 1.3.5.3 |
| UID | User Identifier | 99 |
| GID | Group Identifier | 100 |

# Run example

docker run --name Terraria -d \
    -p 36963:36963/udp \
    --env 'GAME_PARAMS=-config serverconfig.txt' \
    --env 'GAME_VERSION=1.3.5.3' \
    --env 'UID=99' \
    --env 'GID=100' \
    --volume /mnt/user/appdata/terraria:/serverdata/serverfiles \
    --restart=unless-stopped \
    ich777/terrariaserver:latest

This Docker was mainly created for the use with Unraid, if you don’t use Unraid you should definitely try it!

#### Support Thread: https://forums.unraid.net/topic/79530-support-ich777-gameserver-dockers/