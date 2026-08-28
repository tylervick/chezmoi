# Profiles

> [← Documentation index](./README.md)

Profile-aware rendering: `work` and `personal`.

**TL;DR**
- The profile is chosen once during `chezmoi init` and stored in
  `~/.config/chezmoi/chezmoi.toml`.
- `profiles/<profile>/` holds per-profile data (Brewfile). It is **read by
  templates** but **not deployed**.
- Templates branch on `.profile` (e.g. `{{ if eq .profile "work" }}…{{ end }}`).

---

## Available profiles

| Profile | Target | Notes |
|---|---|---|
| `work` | Function Health Mac | Work git identity (`tyler.vick@functionhealth.com`), work-only tools (`awscli`, Figma), `~/.aws/config` deployed |
| `personal` | Personal Mac(s) | Personal git identity, personal-only tools, no work config |

---

## Where the profile is stored

`.chezmoi.toml.tmpl` calls `promptChoiceOnce` and writes:

```toml
# ~/.config/chezmoi/chezmoi.toml
[data]
    profile = "work"
```

The `*Once` helpers read any value already present in `chezmoi.toml`, so
re-running `chezmoi init` does **not** re-prompt. To change the profile after
setup, re-run `chezmoi init` and pick a different value (or edit the file).

> **Gotcha:** `promptChoiceOnce`/`promptStringOnce` look up the value under
> `[data].<key>`. Any value you want remembered must be persisted in `[data]`
> with a matching key — otherwise it re-prompts every init.

---

## Profile-derived git identity

`.chezmoi.toml.tmpl` sets `email`/`signing_key` from the profile rather than
prompting:

```go
{{- if eq $profile "work" }}
{{-   $email = "tyler.vick@functionhealth.com" }}
{{-   $signingKey = "ssh-ed25519 AAAA…" }}
{{- else }}
{{-   $email = promptStringOnce . "personal_email" "Personal git email" }}
{{-   $signingKey = promptStringOnce . "personal_signing_key" "…" }}
{{- end }}
```

`dot_config/git/readonly_config.tmpl` then reads `.email` and `.signing_key`.
For the `personal` profile the prompted values are persisted under
`[data].personal_email` / `[data].personal_signing_key` so they aren't asked
again.

---

## `profiles/` directory layout

```
profiles/
├── work/
│   └── homebrew/Brewfile.tmpl     ← work-only Homebrew packages
└── personal/
    └── homebrew/Brewfile.tmpl     ← personal-only Homebrew packages
```

`profiles/` is excluded from the target state via `.chezmoiignore.tmpl`. Its
contents are loaded only when a template explicitly references them.

---

## How templates use the profile

### Brewfile inclusion

`dot_config/homebrew/Brewfile.tmpl` holds the common packages and ends with:

```go
{{ includeTemplate (printf "profiles/%s/homebrew/Brewfile.tmpl" .profile) . }}
```

This renders the matching profile Brewfile inline. Categorization:

| Bucket | Packages |
|---|---|
| **work** | `awscli`, cask `figma` |
| **personal** | `rclone`, `sysbench`, `yara` |
| **common** | everything else, including all GUI casks |

### Conditional ignore

`.chezmoiignore.tmpl` excludes work-only files when the profile isn't `work`:

```go
{{- if ne .profile "work" }}
.aws/config
{{- end }}
```

---

## Adding a new profile

1. Add the value to the `promptChoiceOnce` list in `.chezmoi.toml.tmpl`.
2. Add an identity branch (or prompt) for it in the same file.
3. Create `profiles/<new>/homebrew/Brewfile.tmpl`.
4. Update any template that branches on `.profile`, and `.chezmoiignore.tmpl`
   if some files must be excluded for that profile.

---

## Related

- [Architecture](./architecture.md) — overall structure
- [Secrets](./secrets.md) — 1Password `op://` references
