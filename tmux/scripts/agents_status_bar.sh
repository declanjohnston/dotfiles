#!/usr/bin/env bash
# Renders Claude usage metrics as two-tone pills for the agents session
# Called from update_session_status.sh as status-right replacement
# Uses pk_claude_metric.sh to read individual metrics from the shared cache

set -e

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# Separator glyphs (powerline rounded)
L=$(printf '\ue0b6')
R=$(printf '\ue0b4')

# Icon glyphs (Material Design nerd font)
ICON_CLOCK=$(printf '\U000F0954')     # 󰥔 five_hour
ICON_CAL=$(printf '\U000F00ED')       # 󰃭 seven_day
ICON_BRAIN=$(printf '\U000F06E8')     # 󰛨 opus
ICON_BOLT=$(printf '\U000F0E39')      # 󰸹 sonnet
ICON_PKG=$(printf '\U000F0820')       # 󰠠 credits
ICON_TIMER=$(printf '\U000F0996')     # 󰦖 reset

# Catppuccin Mocha palette (matching theme/generated/tmux-colors.conf)
STATUS_BG="#181825"

# Per-metric accent + lighter (25% white-mix), same approach as main status-right
ACCENTS=( "#f9e2af" "#eba0ac" "#b4befe" "#89b4fa" "#94e2d5" "#f2cdcd")
LIGHTERS=("#fbecc6" "#f0b8c1" "#c8ccfe" "#a6c6fb" "#b0eae1" "#f6dcdc")

METRICS=(five_hour seven_day opus sonnet credits reset)
ICONS=("$ICON_CLOCK" "$ICON_CAL" "$ICON_BRAIN" "$ICON_BOLT" "$ICON_PKG" "$ICON_TIMER")

output=""
prev_bg="$STATUS_BG"

for i in "${!METRICS[@]}"; do
    value=$("$SCRIPT_DIR/pk_claude_metric.sh" "${METRICS[$i]}" 2>/dev/null) || true
    [[ -z "$value" ]] && continue

    lighter="${LIGHTERS[$i]}"
    accent="${ACCENTS[$i]}"
    icon="${ICONS[$i]}"

    # Two-tone pill: [lighter: icon][accent: value]
    output+="#[fg=${lighter},bg=${prev_bg}]${L}#[none]"
    output+="#[fg=#000000,bg=${lighter}]${icon} "
    output+="#[fg=${accent},bg=${lighter}]${L}#[none]"
    output+="#[fg=#000000,bg=${accent}] ${value} "

    prev_bg="$accent"
done

# Right cap to close the pill chain
if [[ -n "$output" ]]; then
    output+="#[fg=${prev_bg},bg=${STATUS_BG}]${R}#[none]"
fi

printf '%s' "$output"
