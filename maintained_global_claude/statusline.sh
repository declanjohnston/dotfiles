#!/bin/zsh

# Claude Code Status Line - Converted from Powerlevel10k config
# Shows: directory, git branch/status, and context window usage
# Uses Catppuccin Macchiato color palette

# Read JSON input from stdin
input=$(cat)

# Catppuccin Macchiato colors (from p10k config)
COLOR_BLUE="#8aadf4"
COLOR_TEAL="#8bd5ca"
COLOR_GREEN="#a6da95"
COLOR_YELLOW="#eed49f"
COLOR_PEACH="#f5a97f"
COLOR_RED="#ed8796"
COLOR_MAUVE="#c6a0f6"
COLOR_TEXT="#cad3f5"
COLOR_OVERLAY0="#6e738d"

# Extract data from JSON
cwd=$(echo "$input" | jq -r '.workspace.current_dir')
remaining=$(echo "$input" | jq -r '.context_window.remaining_percentage // empty')

# Shorten home directory
display_dir="${cwd/#$HOME/~}"

# Get git info (skip locks for status line)
git_info=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    branch=$(git --no-optional-locks branch --show-current 2>/dev/null || echo "detached")

    # Check if dirty (skip locks)
    if ! git --no-optional-locks diff --quiet 2>/dev/null || \
       ! git --no-optional-locks diff --cached --quiet 2>/dev/null; then
        dirty="*"
        git_color="$COLOR_YELLOW"
    else
        dirty=""
        git_color="$COLOR_GREEN"
    fi

    git_info=$(printf " \033[38;2;%d;%d;%dm \033[0m \033[38;2;%d;%d;%dm%s%s\033[0m" \
        $((16#${COLOR_OVERLAY0:1:2})) $((16#${COLOR_OVERLAY0:3:2})) $((16#${COLOR_OVERLAY0:5:2})) \
        $((16#${git_color:1:2})) $((16#${git_color:3:2})) $((16#${git_color:5:2})) \
        "$branch" "$dirty")
fi

# Context indicator
context_info=""
if [ -n "$remaining" ]; then
    if (( $(echo "$remaining < 20" | bc -l 2>/dev/null || echo 0) )); then
        ctx_color="$COLOR_RED"
    elif (( $(echo "$remaining < 50" | bc -l 2>/dev/null || echo 0) )); then
        ctx_color="$COLOR_YELLOW"
    else
        ctx_color="$COLOR_GREEN"
    fi

    context_info=$(printf " \033[38;2;%d;%d;%dm \033[0m \033[38;2;%d;%d;%dm%.0f%%\033[0m" \
        $((16#${COLOR_OVERLAY0:1:2})) $((16#${COLOR_OVERLAY0:3:2})) $((16#${COLOR_OVERLAY0:5:2})) \
        $((16#${ctx_color:1:2})) $((16#${ctx_color:3:2})) $((16#${ctx_color:5:2})) \
        "$remaining")
fi

# Build status line: dir  git-info  context
printf "\033[38;2;%d;%d;%dm%s\033[0m%s%s" \
    $((16#${COLOR_BLUE:1:2})) $((16#${COLOR_BLUE:3:2})) $((16#${COLOR_BLUE:5:2})) \
    "$display_dir" \
    "$git_info" \
    "$context_info"