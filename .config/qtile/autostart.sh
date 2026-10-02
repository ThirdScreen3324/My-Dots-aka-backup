#!/bin/sh
source /home/Thirdscreen/.profile
setxkbmap -layout se
wal -Rq
picom --animations -b
dunst --startup_notification &
spotify-notify &
