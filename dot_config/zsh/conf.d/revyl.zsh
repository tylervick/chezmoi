#
# revyl: put the revyl CLI on PATH
#
# The revyl installer hardcodes ~/.revyl (rustup-style; it has no XDG support)
# and appends its PATH line to ~/.zshrc, which ZDOTDIR makes zsh skip entirely.
# Owning the export here means a reinstall can't quietly break `revyl` again.
#

if [[ -d "$HOME/.revyl/bin" ]]; then
  path=("$HOME/.revyl/bin" $path)
fi
