#
# brew: Set brew env vars
#
# Must be exported — brew runs as a child process and never sees plain shell
# variables. $HOME, not ~: a tilde inside quotes is never expanded.
#

export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_AUTO_UPDATE_SECS=604800
export HOMEBREW_CASK_OPTS="--appdir=$HOME/Applications"
