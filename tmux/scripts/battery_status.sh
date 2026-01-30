#!/usr/bin/env bash
source ~/dotfiles/theme/generated/shell-colors.sh
# Battery pill for tmux status bar
# Outputs full tmux-formatted pill with dynamic color and icon based on charge level
# Colors use Catppuccin Macchiato palette, gradient from green (full) → red (empty)

BASE="$CATPPUCCIN_BASE"
CRUST="$CATPPUCCIN_CRUST"

get_battery_percent() {
    case $(uname -s) in
        Darwin)
            pmset -g batt 2>/dev/null | grep -o '[0-9]*%' | head -1 | tr -d '%'
            ;;
        Linux)
            if [[ -f /sys/class/power_supply/BAT0/capacity ]]; then
                cat /sys/class/power_supply/BAT0/capacity
            elif [[ -f /sys/class/power_supply/BAT1/capacity ]]; then
                cat /sys/class/power_supply/BAT1/capacity
            fi
            ;;
    esac
}

is_charging() {
    case $(uname -s) in
        Darwin)
            pmset -g batt 2>/dev/null | grep -q 'AC Power'
            ;;
        Linux)
            local status=""
            if [[ -f /sys/class/power_supply/BAT0/status ]]; then
                status=$(cat /sys/class/power_supply/BAT0/status)
            elif [[ -f /sys/class/power_supply/BAT1/status ]]; then
                status=$(cat /sys/class/power_supply/BAT1/status)
            fi
            [[ "$status" == "Charging" || "$status" == "Full" ]]
            ;;
        *)
            return 1
            ;;
    esac
}

get_color() {
    local pct=$1
    if   (( pct >= 80 )); then echo "$CATPPUCCIN_GREEN"
    elif (( pct >= 60 )); then echo "$CATPPUCCIN_YELLOW"
    elif (( pct >= 40 )); then echo "$CATPPUCCIN_PEACH"
    elif (( pct >= 20 )); then echo "$CATPPUCCIN_RED"
    else                       echo "$CATPPUCCIN_MAROON"
    fi
}

get_icon() {
    local pct=$1
    local charging=$2
    if [[ "$charging" == "1" ]]; then
        # Charging icons (Nerd Font md-battery-charging-*)
        if   (( pct >= 90 )); then echo "󰂅"
        elif (( pct >= 80 )); then echo "󰂋"
        elif (( pct >= 60 )); then echo "󰂉"
        elif (( pct >= 40 )); then echo "󰂈"
        elif (( pct >= 20 )); then echo "󰂆"
        else                       echo "󰢜"
        fi
    else
        # Discharging icons (Nerd Font md-battery-*)
        if   (( pct >= 95 )); then echo "󰁹"
        elif (( pct >= 85 )); then echo "󰂂"
        elif (( pct >= 75 )); then echo "󰂁"
        elif (( pct >= 65 )); then echo "󰂀"
        elif (( pct >= 55 )); then echo "󰁿"
        elif (( pct >= 45 )); then echo "󰁾"
        elif (( pct >= 35 )); then echo "󰁽"
        elif (( pct >= 25 )); then echo "󰁼"
        elif (( pct >= 15 )); then echo "󰁻"
        elif (( pct >= 5  )); then echo "󰁺"
        else                       echo "󰂎"
        fi
    fi
}

pct=$(get_battery_percent)
[[ -z "$pct" ]] && exit 0

charging=0
is_charging && charging=1

color=$(get_color "$pct")
icon=$(get_icon "$pct" "$charging")

# Output full tmux-formatted pill: left cap, content, right cap
echo "#[fg=${color},bg=${BASE}]#[fg=${CRUST},bg=${color}] ${icon} ${pct}% #[fg=${color},bg=${BASE}]"
