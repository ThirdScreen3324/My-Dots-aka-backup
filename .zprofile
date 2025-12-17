#!/bin/sh

export EDITOR="nvim"
export TERM="kitty"
export TERMINAL="kitty"
export BROWSER="firefox"

# follow XDG base dir specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_MUSIC_DIR="$HOME/music/"

export MPD_HOST="$XDG_RUNTIME_DIR/mpd/socket"


# add scripts to path
export PATH="$HOME/scripts:$HOME/.local/bin:$PATH"

wal -Rq
