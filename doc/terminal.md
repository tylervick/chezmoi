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
  (plain file) and `dot_claude/` (`settings.json` + `hooks/`).

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
| `scrollback-limit = 10000000` | ~10M lines of scrollback |
| `shell-integration = detect` | Auto-detects the shell for prompt/cwd integration |
| `clipboard-paste-protection`, `clipboard-trim-trailing-spaces` | Guards against unsafe pastes |
| `macos-option-as-alt = true` | Option sends Alt escape sequences |

Intentionally **not** set: font family, `background-opacity`, `background-blur`.

---

## Claude Code

Source: `dot_claude/settings.json` (plain JSON → `~/.claude/settings.json`) and
`dot_claude/hooks/` (`executable_` scripts → `~/.claude/hooks/`).

### Statusline

`settings.json` wires [ccstatusline](https://github.com/sirmalloc/ccstatusline) as
the `statusLine` command:

```json
"statusLine": { "type": "command", "command": "bunx -y ccstatusline@latest", "padding": 0, "refreshInterval": 10 }
```

- Run via **`bunx`** (bun is in the Brewfile) — no global node/npx needed. Swap to
  `npx -y ccstatusline@latest` if bun isn't on PATH.
- `refreshInterval` requires Claude Code ≥ 2.1.97; drop it on older versions.
- It shows context %, model, git branch/worktree + file counts, and PR/CI status.
- Reconfigure the widgets with its TUI: `bunx -y ccstatusline@latest`. Those
  settings are saved to `~/.config/ccstatusline/settings.json` (not yet tracked
  here — track as `dot_config/ccstatusline/settings.json` once tuned).

### Hooks

| Hook | Script | What it does |
|---|---|---|
| `PreToolUse` (Bash) | `hooks/block-dangerous-bash.sh` | Best-effort block of `rm -r` on `/` or `$HOME` and reads of real `.env` files (`.env.example` etc. allowed). Exit 2 blocks. |
| `Stop` | `hooks/notify-stop.sh` | Plays `Glass.aiff` via `afplay` when a turn ends; no-op if `afplay` is absent. |

Both are deliberately conservative belt-and-suspenders checks on top of Claude
Code's own permissions. To disable, remove the hook from `settings.json` or edit
the script.

---

## Related

- [Architecture](./architecture.md) — source layout and chezmoi naming conventions
- [Profiles](./profiles.md) — `work` / `personal` selection
