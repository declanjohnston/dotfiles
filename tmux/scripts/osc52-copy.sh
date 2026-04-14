#!/usr/bin/env bash
# OSC 52 clipboard copy that works from nested tmux (popups, agents session)
# Reads stdin, base64-encodes it, and writes OSC 52 escape to ALL tmux client
# TTYs. The outer client (iTerm2) acts on it; inner/popup clients ignore it.

buf=$(cat | base64 | tr -d '\n')

for tty in $(tmux list-clients -F '#{client_tty}'); do
    [[ -w "$tty" ]] && printf '\033]52;c;%s\a' "$buf" > "$tty" 2>/dev/null
done
