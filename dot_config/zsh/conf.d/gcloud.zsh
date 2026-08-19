#
# gcloud: shell completion for the Google Cloud SDK (work profile).
#
# The Homebrew cask symlinks gcloud/gsutil/bq into $HOMEBREW_PREFIX/bin, so PATH
# needs no help (skip path.zsh.inc). Completions, however, aren't a native zsh
# _gcloud function on fpath — the SDK ships a bashcompinit/argcomplete script we
# must source explicitly. It relies on compinit having already run, which holds
# because conf.d snippets load after ez-compinit in .zsh_plugins.txt.
#
if (( $+commands[gcloud] )); then
  gcloud_inc="${HOMEBREW_PREFIX:-/opt/homebrew}/share/google-cloud-sdk/completion.zsh.inc"
  # Deferred via zsh-defer (see conf.d/mise.zsh) — completion isn't needed
  # before the first prompt.
  [[ -r "$gcloud_inc" ]] && zsh-defer source "$gcloud_inc"
  unset gcloud_inc
fi
