#
# zoxide: smarter cd, with `z` and `zi`. Replaces the oh-my-zsh zoxide plugin /
# the ajeetdsouza/zoxide antidote bundle.
#

if (( $+commands[zoxide] )); then
  eval "$(zoxide init zsh)"
fi
