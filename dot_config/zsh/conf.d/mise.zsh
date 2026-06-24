#
# mise: activate the runtime version manager (replaces the oh-my-zsh mise plugin)
#

if (( $+commands[mise] )); then
  eval "$(mise activate zsh)"
fi
