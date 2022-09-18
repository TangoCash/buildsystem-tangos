#!/bin/sh

if [ $(/bin/pidof /usr/bin/libreader | /usr/bin/wc -w) -ge 1 ] ; then
    exit 0
else
#    while true; do
    /usr/bin/libreader 720p_50
        sleep 1
#    done
fi