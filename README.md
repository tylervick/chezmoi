# Dotfiles

Personal macOS dotfiles managed with [chezmoi](https://www.chezmoi.io/),
organized around **profiles** (`work` / `personal`) with age encryption for a
few app plists and 1Password for runtime secrets.

## Install

```sh
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply git@github.com:tylervick/chezmoi.git
```

On `chezmoi init` you'll be prompted once for the machine **profile**. For a
fresh machine, provision the age key first (see
[doc/secrets.md](./doc/secrets.md)).

## Layout at a glance

| Path | Purpose |
|---|---|
| `.chezmoi.toml.tmpl` | Config template — profile choice + derived git identity |
| `.chezmoiscripts/` | Auto-run scripts (install Homebrew, `brew bundle`) |
| `profiles/<profile>/` | Per-profile render-only data (Brewfile) |
| `dot_config/` | XDG configs (zsh, git, homebrew, mise, …) |
| `doc/` | Documentation |

## Documentation

- [Architecture](./doc/architecture.md) — structure and conventions
- [Profiles](./doc/profiles.md) — `work` / `personal` mechanics
- [Secrets](./doc/secrets.md) — age + 1Password
- [Migration plan](./doc/migration-plan.md) — how this setup was reworked

## Common commands

```sh
chezmoi diff                    # preview pending changes
chezmoi apply                   # apply everything
chezmoi apply --include=scripts # run just the run_* scripts (e.g. brew bundle)
chezmoi init                    # re-render config (e.g. to change profile)
```
