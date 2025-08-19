#
# User configuration sourced by all invocations of the shell
#

# Define Zim location
ZIM_HOME=${ZDOTDIR:-${HOME}}/.zim

# OS type
case "$OSTYPE" in
    linux*)     OS=Linux;;
    darwin*)    OS=Mac;;
    cygwin*)    OS=Cygwin;;
    *)          OS="unknow:${OSTYPE}"
esac

if [ "$OS" = 'Mac' ]; then
path=('/opt/homebrew/bin' $path)
export PATH
export HOMEBREW_NO_AUTO_UPDATE=1
alias ls='gls'
fi

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$HOME/.emacs.d/bin:$PYENV_ROOT/bin:$HOME/local/bin:$PATH"

# lc type
export LC_CTYPE=en_US.UTF-8
export LC_ALL=en_US.UTF-8

# export TERM='xterm-256color'
# export TERM='screen-256color'
# export TERM='dvtm-256color'
# export TERM='vt100'
# export TERM='~/local/share/terminfo/d/dvtm-256color'

export EDITOR='vim'

# https://stackoverflow.com/questions/5947742/how-to-change-the-output-color-of-echo-in-linux
# example : echo -e "I ${RED}love${CR} Stack Overflow"

# Reset
CR='\033[0m'              # Color Reset

# Regular Colors
export BLACK='\033[0;30m'        # Black
export RED='\033[0;31m'          # Red
export GREEN='\033[0;32m'        # Green
export YELLOW='\033[0;33m'       # Yellow
export BLUE='\033[0;34m'         # Blue
export PURPLE='\033[0;35m'       # Purple
export CYAN='\033[0;36m'         # Cyan
export WHITE='\033[0;37m'        # White

# Background
export BG_BLACK='\033[40m'       # Black
export BG_RED='\033[41m'         # Red
export BG_GREEN='\033[42m'       # Green
export BG_YELLOW='\033[43m'      # Yellow
export BG_BLUE='\033[44m'        # Blue
export BG_PURPLE='\033[45m'      # Purple
export BG_CYAN='\033[46m'        # Cyan
export BG_WHITE='\033[47m'       # White

# skip Completion in /etc/zshrc
skip_global_compinit=1

