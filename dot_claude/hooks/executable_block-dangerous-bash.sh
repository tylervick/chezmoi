#!/usr/bin/env bash
# PreToolUse(Bash) guard — best-effort block of obviously destructive commands.
# Receives the tool call as JSON on stdin. Exit 2 blocks the call (stderr is
# shown to Claude); exit 0 allows it. This is a belt-and-suspenders check on top
# of Claude Code's own permissions, deliberately conservative to avoid false
# positives. To disable, remove the PreToolUse hook from ~/.claude/settings.json.
set -uo pipefail

input="$(cat)"

# Extract the command string; fall back to the raw payload if jq is unavailable.
if command -v jq >/dev/null 2>&1; then
  cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty')"
else
  cmd="$input"
fi
[ -z "$cmd" ] && exit 0

# Collapse whitespace for simpler matching.
norm="$(printf '%s' "$cmd" | tr -s '[:space:]' ' ')"

# 1) Recursive delete (rm -r / -R, in any flag order) targeting / or $HOME.
if printf '%s' "$norm" | grep -Eq 'rm ([^|;&]* )?-[a-zA-Z]*[rR]' \
   && printf '%s' "$norm" | grep -Eq '(^| )(/|/\*|~|~/\*?|\$HOME|\$HOME/\*?)( |$)'; then
  echo "Blocked: 'rm -r' targeting / or \$HOME. Edit ~/.claude/hooks/block-dangerous-bash.sh to override." >&2
  exit 2
fi

# 2) Reading/exfiltrating a real .env file (ignores .env.example/.sample/.template/.dist).
if printf '%s' "$norm" | grep -Eqi '(^| )(cat|less|more|head|tail|bat|xxd|od|strings|cp|mv|scp|rsync|curl|wget|tee|nc) ' \
   && printf '%s' "$norm" | grep -Eq '(^| |/|=)\.env([.][a-zA-Z0-9_-]+)?( |$|["'\''>])' \
   && ! printf '%s' "$norm" | grep -Eq '\.env\.(example|sample|template|dist)'; then
  echo "Blocked: command appears to read/copy a .env secrets file. Edit ~/.claude/hooks/block-dangerous-bash.sh to override." >&2
  exit 2
fi

exit 0
