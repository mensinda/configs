# Path to your oh-my-zsh configuration.
ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
DEFAULT_USER="daniel"
BULLETTRAIN_TIME_BG='cyan'
BULLETTRAIN_GIT_BG='green'

POWERLEVEL9K_TIME_FORMAT="%D{%H:%M:%S %d.%m}"

POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir rbenv vcs)
POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status battery time)

POWERLEVEL9K_DIR_HOME_FOREGROUND='black'
POWERLEVEL9K_DIR_HOME_BACKGROUND='cyan'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_FOREGROUND='white'
POWERLEVEL9K_DIR_HOME_SUBFOLDER_BACKGROUND='blue'
POWERLEVEL9K_DIR_DEFAULT_FOREGROUND='white'
POWERLEVEL9K_DIR_DEFAULT_BACKGROUND='blue'

POWERLEVEL9K_STATUS_ERROR_FOREGROUND='black'
POWERLEVEL9K_STATUS_ERROR_BACKGROUND='red'
POWERLEVEL9K_STATUS_OK_FOREGROUND='green'
POWERLEVEL9K_STATUS_OK_BACKGROUND='240'

POWERLEVEL9K_TIME_BACKGROUND='247'

#ZSH_THEME="bullet-train/bullet-train"
if [[ "$(tty)" == "/dev/pts/"* ]]; then
  ZSH_THEME="powerlevel9k/powerlevel9k"
else
  ZSH_THEME="hackersaurus/hackersaurus"
fi

# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

# Set to this to use case-sensitive completion
# CASE_SENSITIVE="true"

# Uncomment this to disable bi-weekly auto-update checks
# DISABLE_AUTO_UPDATE="true"

# Uncomment to change how often before auto-updates occur? (in days)
# export UPDATE_ZSH_DAYS=13

# Uncomment following line if you want to disable colors in ls
# DISABLE_LS_COLORS="true"

# Uncomment following line if you want to disable autosetting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment following line if you want to disable command autocorrection
# DISABLE_CORRECTION="true"

# Uncomment following line if you want red dots to be displayed while waiting for completion
# COMPLETION_WAITING_DOTS="true"

# Uncomment following line if you want to disable marking untracked files under
# VCS as dirty. This makes repository status check for large repositories much,
# much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git git-extras archlinux bgnotify coffee command-not-found compleat dirhistory jsontools sudo systemd)

source $ZSH/oh-my-zsh.sh

# Customize to your needs...

# The following lines were added by compinstall

#setfont Lat2-Terminus16

zstyle ':completion:*' completer _expand _complete _ignored _approximate
zstyle ':completion:*' matcher-list '' 'm:{[:lower:]}={[:upper:]}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle :compinstall filename '/home/daniel/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

if [ -d $HOME/bin ]; then
    PATH=$PATH:$HOME/bin
fi

if [ -d /opt/projects/bin ]; then
    PATH=$PATH:/opt/projects/bin
fi

if [ -d /home/daniel/.gem/ruby/2.2.0/bin ]; then
    PATH=$PATH:/home/daniel/.gem/ruby/2.2.0/bin
fi

man() {
    env LESS_TERMCAP_mb=$'\E[01;31m' \
    LESS_TERMCAP_md=$'\E[01;38;5;74m' \
    LESS_TERMCAP_me=$'\E[0m' \
    LESS_TERMCAP_se=$'\E[0m' \
    LESS_TERMCAP_so=$'\E[38;5;246m' \
    LESS_TERMCAP_ue=$'\E[0m' \
    LESS_TERMCAP_us=$'\E[04;38;5;146m' \
    man "$@"
}

function findAudioStreams {
  _ARGC=$#
  _ARGV=$*

  if (( _ARGC != 1 )); then
    echo "ERROR needs exactly 1 argument"
    return 1
  fi

  which mplayer &> /dev/null
  RET=$?

  if (( RET != 0 )); then
    echo "ERROR: Mplayer not found!"
    return 2
  fi

  mplayer -vf cropdetect $_ARGV

  printf "\n\n\n"

  mplayer -frames 0 -v $_ARGV &>1 | grep --color=never stream:

  return 0
}


SSH_ENV="$HOME/.ssh/environment"

function start_agent {
     /usr/bin/ssh-agent | sed 's/^echo/#echo/' > ${SSH_ENV}
     chmod 600 "${SSH_ENV}"
     . "${SSH_ENV}" > /dev/null
     $HOME/bin/ssh_unlock.sh &> /dev/null
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
     . "${SSH_ENV}" > /dev/null
     #ps ${SSH_AGENT_PID} doesn't work under cywgin
     ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
         start_agent;
     }
else
     start_agent;
fi


if [ -x ${HOME}/bin/zsh/init.sh ]; then
  fpath+=("${HOME}/bin/zsh/")
  source ${HOME}/bin/zsh/init.sh
fi

#alias diff='colordiff'
alias grep='grep --color=auto'
alias more='less'
alias df='df -h'
alias du='du -c -h'
alias mkdir='mkdir -p'
alias nano='nano -w'
alias ping='ping -c 5'
alias dmesg='dmesg -HL -w'

alias ls='LC_COLLATE=C ls -lhF --color=auto --group-directories-first'

alias cp='cp -i'
alias mv='mv -i'
#alias rm='rm -I'

alias cls='echo -ne "\033c"'


alias cd..='cd ..'

alias shred_4='shred -zvun 4'
alias shred_8='shred -zvun 8'
alias shred_16='shred -zvun 16'
alias shred_32='shred -zvun 32'

alias steam='STEAM_FRAME_FORCE_CLOSE=1 steam'

alias yt="youtube-viewer --resolution=1080"

alias gnomew="gnome-session --session=gnome-wayland"

alias GAMES='cat games.txt | grep -i '

alias pacman-disowned-dirs="comm -23 <(sudo find / \( -path '/dev' -o -path '/sys' -o -path '/run' -o -path '/tmp' -o -path '/mnt' -o -path '/srv' -o -path '/proc' -o -path '/boot' -o -path '/home' -o -path '/root' -o -path '/media' -o -path '/var/lib/pacman' -o -path '/var/cache/pacman' \) -prune -o -type d -print | sed 's/\([^/]\)$/\1\//' | sort -u) <(pacman -Qlq | sort -u)"
alias pacman-disowned-files="comm -23 <(sudo find / \( -path '/dev' -o -path '/sys' -o -path '/run' -o -path '/tmp' -o -path '/mnt' -o -path '/srv' -o -path '/proc' -o -path '/boot' -o -path '/home' -o -path '/root' -o -path '/media' -o -path '/var/lib/pacman' -o -path '/var/cache/pacman' \) -prune -o -type f -print | sort -u) <(pacman -Qlq | sort -u)"
alias pacman-changed-files="pacman -Qii | awk '/^MODIFIED/ {print \$2}'"

alias update-grub="sudo mkinitcpio -p linux; sudo grub-mkconfig -o /boot/grub/grub.cfg"

alias uplink="xrandr --output DVI-I-1 --off && xrandr --output HDMI-0 --mode $(xrandr --verbose | grep 800x600 | sed 's/^[ 0-9x]*(//g' | sed 's/)[0-9a-zA-Z\.\+ ]*$//g') && $HOME/Uplink/uplink; randr_reset.sh asd"

alias cpuFreq="RUNNING=1; __sigc() { RUNNING=0; }; trap __sigc SIGINT; setterm -cursor off; while (( RUNNING == 1 )); do echo -ne '\x1B[2K'; cpupower frequency-info | grep 'momentane Taktfrequenz' | sed 's/^[ a-zA-Z]*//g'; echo -ne '\x1B[F'; sleep 1; done; setterm -cursor on"

alias gitMount='sudo truecrypt --mount /home/daniel/Daten/daniel/.git /home/daniel/Daten/git -p $(cat /home/daniel/GIT.pw)'
alias gitUMount'sudo truecrypt -d  /home/daniel/Daten/daniel/.git'

export EDITOR="mcedit"

export DISTCC_HOSTS="127.0.0.1 192.168.1.100"

alias BEEP="beep -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 && beep -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 && beep -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 && beep -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 && beep -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 && beep -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 && beep -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 370 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 587.3 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 415.3 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 784 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 493.9 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 659.3 -l 122 -d 0 -n -f 440 -l 122 -d 0 -n -f 554.4 -l 122 -d 0 -n -f 440 -l 122 -d 0 && beep -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 && beep -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 740 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1174.7 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 830.6 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1568 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 987.8 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1318.5 -l 122 -d 0 -n -f 880 -l 122 -d 0 -n -f 1108.7 -l 122 -d 0 -n -f 880 -l 122 -d 0"

ytM() {
    youtube-dl $1 -o - | mplayer -cache 8192 -
}

cd $HOME

fOK() {
  if (( $# != 2 )); then
    return 1
  fi
  find $1 -name "*-$2*" -print -exec eog {} \;
}

MQR() {
  echo "$*" | ttyqr
}

export PATH="/usr/lib/ccache/bin/:$PATH"

# added by travis gem
[ -f /home/daniel/.travis/travis.sh ] && source /home/daniel/.travis/travis.sh
