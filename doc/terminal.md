# Terminal & Claude Code

> [← Documentation index](./README.md)

How the terminal (Ghostty) and Claude Code are configured, and the keybinds and
hooks that come with them.

**TL;DR**
- **Ghostty** config is ergonomics-only — no font override, no transparency. It
  adds auto light/dark theming, a quake-style quick terminal, vim split
  navigation, big scrollback, and paste safety.
- **Claude Code** shows a rich statusline via [ccstatusline](https://github.com/sirmalloc/ccstatusline)
  and runs two local hooks: a destructive-command guard and a completion sound.
- Source lives at `private_Library/private_Application Support/com.mitchellh.ghostty/config`
  (plain file) and `dot_claude/` (`modify_private_settings.json.tmpl` + `hooks/`).

---

## Ghostty

Source: `private_Library/private_Application Support/com.mitchellh.ghostty/config`
(deployed to `~/Library/Application Support/com.mitchellh.ghostty/config`). It is
a **plain file** — no profile templating needed. Validate edits with
`ghostty +validate-config`.

### Keybinds

| Keybind | Action |
|---|---|
| `ctrl+\`` | Toggle the quick terminal (quake mode) from any app — global; docks on the left |
| `cmd+enter` | New split to the right |
| `cmd+shift+enter` | New split below |
| `cmd+h` / `cmd+j` / `cmd+k` / `cmd+l` | Focus split left / down / up / right |
| `cmd+shift+r` | Rename the current tab |
| `cmd+k` | Clear screen (sends form-feed `\x0c`) |
| `shift+enter` | Insert a literal newline |

### Behavior

| Setting | Effect |
|---|---|
| `theme = light:Catppuccin Latte,dark:Catppuccin Mocha` + `window-theme = auto` | Follows macOS light/dark appearance |
| `quick-terminal-*` | Docks on the left (`45%` × `50%`), autohides on blur |
| `window-save-state = always`, `window-inherit-working-directory = true` | Restores windows; new splits inherit the cwd. Last `window-save-state` wins — comment `always` and uncomment `never` in the quick-terminal block to forget a saved size, then switch back. |
| `cursor-style-blink = false` | A blinking cursor redraws at the display refresh rate (120Hz): ~10–15% CPU vs ~1% |
| `scrollback-limit = 10000000` | ~10M lines of scrollback |
| `shell-integration = detect` | Auto-detects the shell for prompt/cwd integration |
| `clipboard-paste-protection`, `clipboard-trim-trailing-spaces` | Guards against unsafe pastes |
| `macos-option-as-alt = true` | Option sends Alt escape sequences |

Intentionally **not** set: font family, `background-opacity`, `background-blur`.

---

## Claude Code

Source: `dot_claude/modify_private_settings.json.tmpl` and `dot_claude/hooks/`
(`executable_` scripts → `~/.claude/hooks/`).

`~/.claude/settings.json` has other writers — Claude Code itself (`/model`,
`/config`, `/plugin`), Orca, and herdr (which install hooks on every event) — so
chezmoi doesn't own the whole file. The `modify_` script deep-merges the keys in
`.chezmoitemplates/claude-settings.json` over whatever is on disk, and appends
our hook entries to each event only if missing; everything else is preserved.
`model` is deliberately unmanaged (set it with `/model`). To change a managed
setting, edit `.chezmoitemplates/claude-settings.json`, not the deployed file.

### Statusline

`settings.json` wires [ccstatusline](https://github.com/sirmalloc/ccstatusline) as
the `statusLine` command:

```json
"statusLine": { "type": "command", "command": "bunx ccstatusline@2.2.30", "padding": 0, "refreshInterval": 10 }
```

- Run via **`bunx`** (bun is in the Brewfile) — no global node/npx needed.
- **Pinned**, not `@latest`: it runs every 10s in every open session, and
  `@latest` re-resolves the version against the registry each time. Bump the
  pin deliberately.
- `refreshInterval` requires Claude Code ≥ 2.1.97; drop it on older versions.
- It shows context %, model, git branch/worktree + file counts, and PR/CI status.
- Reconfigure the widgets with its TUI: `bunx ccstatusline@2.2.30`. Those
  settings are saved to `~/.config/ccstatusline/settings.json` (not yet tracked
  here — track as `dot_config/ccstatusline/settings.json` once tuned).

### Hooks

| Hook | Script | What it does |
|---|---|---|
| `PreToolUse` (Bash) | `hooks/block-dangerous-bash.sh` | Best-effort block of `rm -r` on `/` or `$HOME` and reads of real `.env` files (`.env.example` etc. allowed). Exit 2 blocks. |
| `Stop` | `hooks/notify-stop.sh` | Plays `Glass.aiff` via `afplay` when a turn ends; no-op if `afplay` is absent. |

Orca and herdr add their own hooks to most events; those are theirs (see
above) and not listed here.

Both of ours are deliberately conservative belt-and-suspenders checks on top of Claude
Code's own permissions. To disable, remove the hook from `settings.json` or edit
the script.

---

## Related

- [Architecture](./architecture.md) — source layout and chezmoi naming conventions
- [Profiles](./profiles.md) — `work` / `personal` selection
