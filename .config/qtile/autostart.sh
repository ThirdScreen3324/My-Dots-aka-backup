#!/bin/sh
setxkbmap -layout se
wal -Rq
picom -b
dunst --startup_notification &
spotify-notify &
