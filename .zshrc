#MOST OF THIS IS NOT MINE, most of the is made by Bread on Penguins
HISTSIZE=1000000
SAVEHIST=1000000
HISTFILE="$XDG_CACHE_HOME/zsh_history"

bindkey -e

setopt auto_menu menu_complete # autocmp first menu match
setopt autocd # type a dir to cd
setopt auto_param_slash # when a dir is completed, add a / instead of a trailing space
setopt no_case_glob no_case_match # make cmp case insensitive
setopt globdots # include dotfiles
setopt extended_glob # match ~ # ^
setopt interactive_comments # allow comments in shell
unsetopt prompt_sp # don't autoclean blanklines

zstyle :compinstall filename '/home/Thirdscreen/.zshrc'

# load modules
zmodload zsh/complist
autoload -Uz compinit && compinit
autoload -Uz colors && colors
# cmp opts
zstyle ':completion:*' menu select # tab opens cmp menu
zstyle ':completion:*' special-dirs true # force . and .. to show in cmp menu
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33 # colorize cmp menu
zstyle ':completion:*' squeeze-slashes false # explicit disable to allow /*/ expansion

alias :wq='exit'
alias cheesesuger='mv ~/.gnome2/cheese/media/* ~/pics/cam/webcam/'
alias du='du -ha -d 1 | sort -h'
alias fan='shutdown -P now'
alias fk='sudo !!'
alias icat='kitten icat'
alias mjuk-omstart='systemctl soft-reboot'
alias mv='mv -i'
alias omstart='shutdown -r now'
alias rm='rm -Iv'
alias vim='nvim'
alias mpvseries='mpv --autocreate-playlist=same'
alias cast-to-tv='go-chromecast -n "Vardagsrum"'


function ffsubtitleextract () {
	ffmpeg -i $1.mkv -map 0:s:0 $1.srt
}

function ffscreenrecord () {
	ffmpeg -video_size 1920x1080 -framerate 30 -f x11grab -i :0.0 ~/vids/screenrecords/$1
}

function y () {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd 
	yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ -n "$cwd" ] && [ "$cwd" != "$PWD" ] && builtin cd -- "$cwd"
	rm -Iv -f -- "$tmp"
}

# Setting prompt and prompt colors
source ~/.cache/wal/colors.sh

NEWLINE=$'\n'
PROMPT="${NEWLINE}%K{"$color1"}%F{"$foreground"} %n %K{"$color9"} %~ %f%k ❯ " # pywal colors, from postrun script
# Programs to run at start
fastfetch
. "/home/Thirdscreen/.deno/env"
