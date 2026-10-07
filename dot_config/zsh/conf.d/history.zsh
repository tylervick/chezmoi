#
# history: Set better history values
#

HISTSIZE="100000"
SAVEHIST="100000"
# Keep trivial commands out of the history file. zsh's equivalent of bash's
# HISTIGNORE is HISTORY_IGNORE, a pattern (applied when writing the file).
HISTORY_IGNORE="(pwd|ls|cd)"
HISTFILE="$HOME/.zsh_history"
# HISTFILE=${XDG_DATA_HOME:-$HOME/.local/share}/zsh/history

[[ -d ${HISTFILE:h} ]] || mkdir -p ${HISTFILE:h}
