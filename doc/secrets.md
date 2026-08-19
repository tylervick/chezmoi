# Secrets

> [← Documentation index](./README.md)

How sensitive data is handled in this repo.

**TL;DR**
- **Nothing is encrypted at rest in this repo** — there is no age/GPG key, and
  no secret values are committed.
- The repo is **public**, so anything tracked here is assumed public.
- App license keys live in **1Password**, not in the repo.
- Runtime secrets (API tokens) use 1Password `op://` references resolved by
  `op run` — values are never stored.

---

## No encryption

This repo previously used age to encrypt a few macOS app plists (they carried
an iStat Menus license key). That was removed: the license was moved into
1Password and the volatile plists are no longer tracked. See
[migration-plan.md](./migration-plan.md) for the full rationale.

There is consequently **no** `encryption` setting in `.chezmoi.toml.tmpl`, no
`[age]` block, and no `~/.config/chezmoi/key.txt`.

## What's tracked here (all plaintext, all non-secret)

- `dot_config/git/readonly_allowed_ssh_signers` — public SSH keys.
- `dot_config/private_1Password/private_ssh/readonly_agent.toml` — 1Password SSH
  agent config; references vault/item *names* only, no credentials.
- `dot_aws/private_config` — AWS SSO/profile config, no static credentials.

## App licenses

iStat Menus' license is stored in 1Password (personal account,
`my.1password.com`, item **"iStat Menus License"**) — not in this repo. On a new
machine, install iStat and paste the key back from 1Password. The app's
preference plists are intentionally **not** managed by chezmoi (they change
constantly and would otherwise show as perpetual drift).

## Runtime secrets — 1Password `op://`

Secrets needed at runtime are referenced, never stored:

```sh
export SOME_API_TOKEN="op://<vault>/<item>/<field>"
```

Run the consuming command under `op run -- <command>` to resolve the references.

> Multiple accounts: pass `--account <url-or-id>` to `op` (e.g.
> `--account my.1password.com`) when more than one account is signed in.

---

## Related

- [Migration plan](./migration-plan.md) — the secrets audit and the age removal
- [Architecture](./architecture.md) — overall structure
