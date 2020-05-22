#!/bin/bash
#set -x

### Only for testing propose ###
#TR_TORRENT_DIR=
#TR_TORRENT_NAME=
################################

echo "$TR_TORRENT_DIR/$TR_TORRENT_NAME $TR_TORRENT_ID" > /tmp/test.transmission

### Telegram Bot Config ###
BOT_TOKEN="YOUR TELEGRAM TOKEN"
CHAT_ID="YOUR TELEGRAM CHAT ID"

### Notification message ###
### If you need a line break, use "%0A" instead of "\n". ###
TORRENT_NAME=$(echo "$TR_TORRENT_NAME" | sed 's/\[/\(/g' | sed 's/\]/\)/g')
Finish="<strong>Download Completed</strong>%0A- ${TORRENT_NAME}%0A"
Nube="<strong>Archivo Movido a la Nube</strong>%0A- ${TORRENT_NAME}%0A"
Almacen="<strong>Archivo Movido al Almacen</strong>%0A- ${TORRENT_NAME}%0A"
DownNube="<strong>Transmission seeding</strong>%0A- ${TORRENT_NAME}%0A"

### Prepares the request payload ###
Finish="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${Finish}&parse_mode=HTML"
PAYLOADNube="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${Nube}&parse_mode=HTML"
PAYLOADAlmacen="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${Almacen}&parse_mode=HTML"
DownNube="https://api.telegram.org/bot${BOT_TOKEN}/sendMessage?chat_id=${CHAT_ID}&text=${DownNube}&parse_mode=HTML"
### Sends the notification to the telegram bot ###
curl -S -X POST "${Finish}" -w "\n\n"

### Move files to directory multimedia and to directory to seed ###
cd $TR_TORRENT_DIR

### This if select if movie file or movie directory and tell rsync for copy on seeder folder or multimedia folder ###
if [[ ! -d "$TR_TORRENT_NAME" ]]

then
        rsync --partial -avhz "$TR_TORRENT_NAME" /mnt/NubeAlmacen/Descargas/
        curl -S -X POST "${PAYLOADNube}" -w "\n\n"
        mv "$TR_TORRENT_NAME" "/srv/dev-disk-by-label-Almacen/Multimedia/HD & 3D/"
        curl -S -X POST "${PAYLOADAlmacen}" -w "\n\n"
else
        echo "$TR_TORRENT_DIR" > /tmp/torrent.dir
        TORRENT_DIR=$(echo "$TR_TORRENT_NAME" | tr -d "/")
        rsync --partial -avhz "$TORRENT_DIR" /mnt/NubeAlmacen/Descargas/
        curl -S -X POST "${PAYLOADNube}" -w "\n\n"
        mv "$TR_TORRENT_NAME/" "/srv/dev-disk-by-label-Almacen/Multimedia/HD\ \&\ 3D/"
        curl -S -X POST "${PAYLOADAlmacen}" -w "\n\n"

fi

### Move location Torrent ###
transmission-remote http://USER:PASSWORD@127.0.0.1:9091/transmission/rpc --torrent "$TR_TORRENT_ID" --move /mnt/NubeAlmacen/Descargas
curl -S -X POST "${DownNube}" -w "\n\n"

exit
