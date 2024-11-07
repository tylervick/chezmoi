#
# history: Set better history values
#

HISTSIZE="100000"
SAVEHIST="100000"
# Remove history data we don't want to see
HISTIGNORE="pwd:ls:cd"
HISTFILE="$HOME/.zsh_history"
# HISTFILE=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history

[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
