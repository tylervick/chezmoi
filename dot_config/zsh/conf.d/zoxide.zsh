#
# zoxide: smarter cd, with `z` and `zi`. Replaces the oh-my-zsh zoxide plugin /
# the ajeetdsouza/zoxide antidote bundle.
#
# Deferred via zsh-defer (see conf.d/mise.zsh for why) — `z`/`zi` aren't
# needed in the first fraction of a second, and zsh-defer replays buffered
# keystrokes once it's done, same as the already-deferred autosuggestions
# plugin.
#

if (( $+commands[zoxide] )); then
  zsh-defer -c 'eval "$(zoxide init zsh)"'
fi
