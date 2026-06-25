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

## Phase 2 — Secrets: age → 1Password  ⬜ (next)

Prereq: a dedicated 1Password vault (e.g. `chezmoi`), `op` CLI signed in.

| Current `*.age` file | Contents | Plan |
|---|---|---|
| `git/encrypted_allowed_ssh_signers.age` | Public SSH keys | **Demote to plaintext** — not secret |
| `private_1Password/.../encrypted_readonly_agent.toml.age` | SSH-agent vault config | **Plaintext / light template** — not a credential |
| iStat Menus `*.plist` (4) | App prefs incl. license | **1P document** → `onepasswordDocument` template |
| Ice `.plist` | App prefs | **1P document** (or plaintext if no secret) |

Then remove `encryption = "age"` + `[age]` block and the age prompts from
`.chezmoi.toml.tmpl`.

⚠️ Seed 1P items **before** deleting `.age` files; verify
`chezmoi apply --dry-run` resolves every `onepasswordDocument` first.

## Phase 3 — Structure & docs  ⬜

- Move `run_*` scripts into `.chezmoiscripts/` with numbered names.
- Add `doc/architecture.md`, `doc/profiles.md`, `doc/secrets.md`; expand README.

## Deferred extras

- `scripts/setup.d/` sourced bootstrap pipeline with `_utils.sh` logging.
- `run_once_osx-*` macOS `defaults write` scripts.
- `.chezmoiexternal.toml` for nerd fonts.
