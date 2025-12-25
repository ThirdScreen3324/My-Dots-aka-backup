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

export MPD_HOST="127.0.0.1"


# add scripts to path
export PATH="$HOME/scripts:$HOME/.local/bin:$PATH"

wal -Rq
