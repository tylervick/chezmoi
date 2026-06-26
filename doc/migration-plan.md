# Migration plan: profile-driven chezmoi + 1Password secrets

Status tracker for reworking this repo with patterns adapted from
[Prevole/chezmoi](https://github.com/Prevole/chezmoi).

## Decisions

- **Profiles:** `work` (Function Health Mac) + `personal`.
- **Secrets:** consolidate to 1Password, drop `age` (Phase 2).
- **Approach:** phased; Phase 1 lands first and is independently safe.

## Target source tree

```
.chezmoi.toml.tmpl            # promptChoiceOnce profile, profile-derived git identity
.chezmoiignore.tmpl           # profile-aware excludes (was empty .chezmoiignore)
.chezmoiexternal.toml         # OPTIONAL: nerd fonts (deferred)
.chezmoiscripts/              # run_* scripts move here (Phase 3)
profiles/                     # render-only, excluded from target state
  work/homebrew/Brewfile.tmpl
  personal/homebrew/Brewfile.tmpl
scripts/                      # OPTIONAL richer bootstrap (deferred)
doc/                          # this folder
dot_config/homebrew/Brewfile.tmpl   # common pkgs + includeTemplate profile
dot_config/git/readonly_config.tmpl # profile-aware identity + signing key
```

## Phase 1 — Profiles  ✅ (this pass)

- [x] `.chezmoi.toml.tmpl`: `promptChoiceOnce` profile (`work`/`personal`),
      `promptStringOnce` for hostname/age keys (no more re-prompting on re-init),
      profile-derived `name`/`email`/`signing_key`, `is_vm` detection.
- [x] `profiles/work/` + `profiles/personal/` Brewfiles.
- [x] `dot_config/homebrew/Brewfile` → `Brewfile.tmpl` (common + `includeTemplate`).
- [x] `run_onchange_darwin-install-packages.sh.tmpl`: hash the *rendered*
      template so profile Brewfile changes re-trigger `brew bundle`.
- [x] `.chezmoiignore` → `.chezmoiignore.tmpl` (ignore `doc`/`profiles`/`scripts`;
      work-only `.aws/config` excluded on personal).
- [x] `dot_config/git/readonly_config.tmpl`: `signingKey` from `.signing_key`.

### Brewfile categorization (correct as needed)

| Bucket | Packages |
|---|---|
| **work** | `awscli`, cask `figma` |
| **personal** | `rclone`, `sysbench`, `yara` |
| **common** | everything else (incl. all GUI casks) |

Removed entirely on request: `openapi-generator`, `session-manager-plugin`,
`goreleaser`, `vhs`.

## Phase 2 — Secrets: right-size encryption, then remove age  ✅

**Audit finding (2026-06):** age was over-applied. An audit of every managed
secret showed almost nothing is actually sensitive:

| File | Genuinely secret? | Disposition |
|---|---|---|
| `jira.zsh` | No — already used an `op://` reference; no longer needed | **Removed** ✅ |
| `git/.../allowed_ssh_signers` | No — public keys | **age → plaintext** (`readonly_`) ✅ |
| `private_1Password/.../agent.toml` | No — just vault/item *names* | **age → plaintext** (`readonly_`) ✅ |
| iStat Menus `*.plist` (main + menubar.7) | **Yes — license keys** | Stay encrypted ⏸ (see below) |
| iStat status/agent, Ice `*.plist` | No license/serial data | Stay encrypted ⏸ (bundled) |

### Done in this pass ✅
- Removed `jira.zsh` (obsolete; was already 1Password-native via `op://`).
- Demoted `allowed_ssh_signers` and `agent.toml` from age to plaintext —
  they contain no secrets. age now encrypts **only** the 5 plists.

### Plist decision — resolved via Option A ✅
The only genuine secrets were iStat Menus **license keys** inside binary plists
that can't be cleanly field-templated — also the "frequently-changing plists"
that caused perpetual drift. Resolution:

- [x] Saved the iStat license to 1Password (personal account, item
      "iStat Menus License").
- [x] Untracked all 5 plists (`git rm` the `encrypted_*.age` files); live
      `~/Library/Preferences/*.plist` left untouched.
- [x] Removed `encryption = "age"` + the `[age]` block from `.chezmoi.toml.tmpl`.
- [ ] **You:** `chezmoi init` (regenerate age-free config) + `rm ~/.config/chezmoi/key.txt`.

> Net: age is gone, no plaintext key on disk, no more plist drift, license safe
> in 1Password. To restore iStat on a new machine, paste the key back from 1P.

## Phase 3 — Structure & docs  ✅

- [x] Moved `run_*` scripts into `.chezmoiscripts/` with numbered names
      (`run_once_before_00-install-homebrew`, `run_onchange_10-brew-bundle`).
- [x] Added `doc/architecture.md`, `doc/profiles.md`, `doc/secrets.md`,
      `doc/README.md` (index); expanded the top-level `README.md`.

## macOS defaults  ✅

Added `.chezmoiscripts/run_onchange_after_osx-*.sh.tmpl` (10-global, 20-dock,
30-finder, 40-trackpad, 50-screenshots, 60-controlcenter, 70-safari). Pattern
adapted from twpayne's own dotfiles (chezmoi author), chosen over Prevole:

- `run_onchange_` (not `run_once_`) so edits re-apply.
- Per-app `trap 'killall <App>' EXIT` — each script restarts only its own app,
  only when it changed. No blanket "restart everything" script.
- `set -eufo pipefail`; gated with `{{ if eq .chezmoi.os "darwin" }}`.

Settings ported from the old nix-config set, verified against macOS 26 Tahoe.
Fixes applied: `AppleKeyboardUIMode` 3→2; `tapBehavior` needs `-currentHost`;
`AppleLanguages` single-element; battery % via `controlcenter`. Dropped as
dead: `QLEnableTextSelection`, `-g AppleShowAllFiles` (wrong domain),
screensaver `askForPassword` (MDM-only now). Safari writes need Full Disk
Access (disclaimed in-script). Old `ssd.sh` power tweaks intentionally skipped.

## Deferred extras

- `scripts/setup.d/` sourced bootstrap pipeline with `_utils.sh` logging.
- `.chezmoiexternal.toml` for nerd fonts.
