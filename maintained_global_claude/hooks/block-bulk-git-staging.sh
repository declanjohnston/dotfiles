#!/usr/bin/env zsh
# PreToolUse hook (Bash tool): reject bulk staging so scratch files never reach a commit.
# Blocks: git add -A/--all/-u/--update/. , git commit -a/-am/--all. Exit 2 = block with message.

set -u
input="$(cat)"
cmd="$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)" || exit 0
[[ -z "$cmd" ]] && exit 0

if [[ "$cmd" =~ 'git[[:space:]]+add[[:space:]]+(-A|--all|-u|--update|\.|:/)([[:space:]]|$)' ]] ||
   [[ "$cmd" =~ 'git[[:space:]]+commit[[:space:]]+([^|;&]*[[:space:]])?(-a|-am|-a[[:alpha:]]*|--all)([[:space:]]|$)' ]]; then
  print -u2 "Blocked: bulk staging (git add -A/./-u, commit -a) sweeps in scratch files. Stage explicit paths: git add path/a path/b, then confirm with git diff --cached --name-only."
  exit 2
fi
exit 0
