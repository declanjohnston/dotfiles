#!/usr/bin/env bash
# Per-session status bar customization for the `agents` session.
#
# IMPORTANT: every option set here is scoped to the current session with
# `-t "$session_name"`. The `else` branch unsets each of those options
# (with `-u`) so they revert to the server-global defaults configured in
# .tmux.conf. Without this, switching out of `agents` would leave the
# agents-themed status bar applied to every other session.

source ~/dotfiles/theme/generated/shell-colors.sh

session_name=$(tmux display-message -p '#S')

# Options touched by this script. Listed once so the agents and default
# branches stay in sync.
session_scoped_opts=(
    status-style
    status-justify
    status-left
    status-left-length
    status-right
    status-right-length
    window-status-format
    window-status-current-format
    window-status-separator
    pane-border-status
)

if [[ "$session_name" == "agents" ]]; then
    dir="$HOME/dotfiles/tmux/scripts"

    base="$CATPPUCCIN_BASE"
    crust="$CATPPUCCIN_CRUST"
    peach="$CATPPUCCIN_PEACH"
    yellow="$CATPPUCCIN_YELLOW"
    left_cap=""
    right_cap=""

    # Enable pane borders with titles for agents session
    tmux set-option -t "$session_name" pane-border-status top

    tmux set-option -t "$session_name" status-style "bg=$base,fg=$CATPPUCCIN_TEXT"
    tmux set-option -t "$session_name" status-justify centre
    tmux set-option -t "$session_name" status-left-length 30
    tmux set-option -t "$session_name" status-right-length 200

    # Left: Crab pill (peach, yellow on prefix)
    tmux set-option -t "$session_name" status-left "\
#[fg=$peach,bg=$base]#{?client_prefix,#[fg=$yellow],}$left_cap\
#[fg=$crust,bg=$peach]#{?client_prefix,#[bg=$yellow],} 🦀 \
#[fg=$peach,bg=$base]#{?client_prefix,#[fg=$yellow],}$right_cap"

    # Right: Claude usage metrics (two-tone pills: 5h, 7d, opus, sonnet, credits, reset)
    tmux set-option -t "$session_name" status-right "#($dir/agents_status_bar.sh)"

    # Window list: non-current windows muted
    tmux set-option -t "$session_name" window-status-format "#[fg=$CATPPUCCIN_SURFACE2] #W "

    # Current window: Orange pill with icon, window name + agent count (bold)
    tmux set-option -t "$session_name" window-status-current-format "\
#[fg=$peach,bg=$base]$left_cap\
#[fg=$crust,bg=$peach,bold] #W · 󰚩 #($dir/agents_count.sh) \
#[fg=$peach,bg=$base]$right_cap"

    tmux set-option -t "$session_name" window-status-separator ""
else
    # Revert every agents-scoped option so this session inherits the
    # server-global defaults from .tmux.conf instead of leftover agents styling.
    for opt in "${session_scoped_opts[@]}"; do
        tmux set-option -u -t "$session_name" "$opt" 2>/dev/null
    done
fi
