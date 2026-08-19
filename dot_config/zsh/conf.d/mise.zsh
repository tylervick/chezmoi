#
# mise: activate the runtime version manager (replaces the oh-my-zsh mise plugin)
#
# `mise activate zsh` forks `mise hook-env` immediately, which alone costs
# several hundred ms on this machine (exec latency from the corporate
# EDR agent, not mise itself). Deferred via zsh-defer so it runs after the
# first prompt instead of blocking startup; .zshenv already puts mise shims
# on PATH so tool resolution works in the gap. Uses `-c` so the
# `mise activate zsh` subshell itself is deferred, not just the eval of its
# (otherwise immediately-computed) output.
#

if (( $+commands[mise] )); then
  zsh-defer -c 'eval "$(mise activate zsh)"'
fi
