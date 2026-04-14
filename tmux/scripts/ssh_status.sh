#!/usr/bin/env bash
# SSH status widget for tmux — shows client IP + latency
# Outputs nothing when not in an SSH session (widget hides)

if [[ -z "$SSH_CLIENT" ]]; then
    echo ""
    exit 0
fi

# Display name: $SSH_DISPLAY_NAME (from local/.local_env.sh) > hostname -s > client IP
client_ip="${SSH_CLIENT%% *}"
name="${SSH_DISPLAY_NAME:-$(hostname -s)}"

# Ping client with 1s timeout, single packet
latency=$(ping -c 1 -W 1 "$client_ip" 2>/dev/null \
    | grep -oP 'time=\K[0-9.]+' \
    | head -1)

if [[ -n "$latency" ]]; then
    latency_int=$(printf "%.0f" "$latency")
    echo "${name} ${latency_int}ms"
else
    echo "$name"
fi
