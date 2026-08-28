# Architecture

> [← Documentation index](./README.md)

How this repository is structured and how chezmoi turns it into a configured
machine.

**TL;DR**
- `.chezmoi.toml.tmpl` prompts once for a **profile** (`work` / `personal`) and
  derives the git identity from it.
- `dot_*` files are deployed to `$HOME`; `profiles/*` is render-only data;
  `.chezmoiignore.tmpl` decides what is *not* deployed.
- `.chezmoiscripts/*` run automatically on `chezmoi apply` (install Homebrew,
  `brew bundle`).
- Nothing is encrypted at rest — everything tracked here is plaintext; runtime
  secrets are 1Password `op://` references resolved by `op run`.

---

## Source layout

| Path | Purpose |
|---|---|
| `.chezmoi.toml.tmpl` | Config template — profile choice, profile-derived git identity |
| `.chezmoiignore.tmpl` | Paths excluded from the target state (profile-aware) |
| `.chezmoiscripts/` | Scripts auto-run on apply (never deployed as files) |
| `profiles/<profile>/` | Per-profile **render-only** data (Brewfile); excluded from target state |
| `dot_config/homebrew/Brewfile.tmpl` | Common Brewfile; appends the profile Brewfile via `includeTemplate` |
| `dot_config/git/readonly_config.tmpl` | Git config — identity/signing key from profile |
| `dot_config/zsh/` | Zsh config (zshrc, aliases, p10k, plugins) + modular `conf.d/*.zsh` |
| `dot_config/…` | Other XDG configs (mise, colima, tmux, pnpm, 1Password SSH agent) |
| `private_Library/private_Application Support/` | macOS app support files (Ghostty config) |
| `readonly_dot_zshenv` | `~/.zshenv` — sets `XDG_CONFIG_HOME` and `ZDOTDIR` |
| `doc/` | This documentation (not deployed) |

---

## Naming conventions (chezmoi attributes)

chezmoi encodes file attributes in the source filename prefix:

| Prefix | Effect on the target |
|---|---|
| `dot_` | Leading `.` (e.g. `dot_config` → `~/.config`) |
| `private_` | `0600`/`0700` permissions |
| `readonly_` | Removes write bits (`0444`/`0555`) |
| `run_` | Executed, not deployed (see scripts below) |
| `*.tmpl` | Rendered through Go's `text/template` |

Prefixes stack, e.g. `dot_config/git/readonly_config.tmpl` → rendered through
`text/template` and deployed read-only (`0444`) to `~/.config/git/config`.

---

## `.chezmoiscripts/` — steady-state pipeline

Scripts run automatically by chezmoi, ordered by name within each trigger type.

| Script | Trigger | Action |
|---|---|---|
| `run_once_before_00-install-homebrew.sh.tmpl` | Once ever, before apply | Install Homebrew if missing (macOS) |
| `run_onchange_10-brew-bundle.sh.tmpl` | When its rendered content changes | `brew bundle` against `~/.config/homebrew/Brewfile` |

The `run_onchange` script embeds `{{ includeTemplate "dot_config/homebrew/Brewfile.tmpl" . | sha256sum }}`
— hashing the **rendered** Brewfile (common + profile) so any package change,
including a profile-specific one, re-triggers `brew bundle`.

Trigger reference:

| Prefix | Trigger |
|---|---|
| `run_once_before_*` | Once ever, before dotfiles are applied |
| `run_once_*` | Once ever (deduped by rendered-content hash) |
| `run_onchange_*` | Re-runs when the rendered script changes |
| `run_*` | Every `chezmoi apply` |

---

## Profiles

The active profile (`work` / `personal`) is chosen once at `chezmoi init`,
stored in `~/.config/chezmoi/chezmoi.toml`, and referenced everywhere as
`.profile`. Per-profile data lives in `profiles/<profile>/` (read by templates,
never deployed). See [profiles.md](./profiles.md).

---

## Secrets

Nothing in this repo is encrypted at rest — there is no age key and no
encrypted files. The repo is public, so everything tracked here is assumed
public. Runtime secrets (e.g. API tokens) use 1Password `op://` references
resolved by `op run`. See [secrets.md](./secrets.md).

---

## Related

- [Profiles](./profiles.md) — profile selection mechanics
- [Secrets](./secrets.md) — 1Password `op://` references
- [Migration plan](./migration-plan.md) — the phased rework this structure came from
