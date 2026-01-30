# Catppuccin Theming Standardization

**Date:** 2026-01-30
**Status:** Approved

## Overview

Standardize Catppuccin theming across all dev tools (tmux, p10k, fzf, iTerm, Cursor) with a custom Mocha palette. Currently the codebase has a mix of Mocha and Macchiato with ~30+ hardcoded hex values scattered across config files.

## Goals

1. Standardize on Catppuccin Mocha everywhere
2. Customize the base colors for better readability (darker backgrounds)
3. Single source of truth for all colors
4. Automatic theme generation for all tools
5. Clean integration with `setup.sh`

## Custom Color Modifications

Standard Catppuccin Mocha base colors:
- Base: `#1e1e2e`
- Mantle: `#181825`
- Crust: `#11111b`

Custom modifications (darker for better text readability):
- **Base**: `#181825` (shifted to current Mantle)
- **Mantle**: `#141420` (average of Mantle and Crust)
- **Crust**: `#11111b` (unchanged)

All accent colors (rosewater through lavender) remain standard Mocha.

## Architecture

### Source of Truth

```
theme/
  colors.json                    # Canonical color definitions
  generate-theme.sh              # Generates all tool-specific configs
  generated/                     # Output directory (committed to git)
    shell-colors.sh              # Exports for shell scripts, fzf
    p10k-colors.zsh              # Powerlevel10k variables
    tmux-colors.conf             # Tmux user options
    iterm-profile.json           # iTerm dynamic profile
    cursor-overrides.json        # Cursor workbench.colorCustomizations
```

### colors.json Format

```json
{
  "base": "#181825",
  "mantle": "#141420",
  "crust": "#11111b",
  "text": "#cdd6f4",
  "subtext1": "#bac2de",
  "subtext0": "#a6adc8",
  "overlay2": "#9399b2",
  "overlay1": "#7f849c",
  "overlay0": "#6c7086",
  "surface2": "#585b70",
  "surface1": "#45475a",
  "surface0": "#313244",
  "rosewater": "#f5e0dc",
  "flamingo": "#f2cdcd",
  "pink": "#f5c2e7",
  "mauve": "#cba6f7",
  "red": "#f38ba8",
  "maroon": "#eba0ac",
  "peach": "#fab387",
  "yellow": "#f9e2af",
  "green": "#a6e3a1",
  "teal": "#94e2d5",
  "sky": "#89dceb",
  "sapphire": "#74c7ec",
  "blue": "#89b4fa",
  "lavender": "#b4befe"
}
```

### Generator Script

`theme/generate-theme.sh` uses `jq` to parse `colors.json` and output tool-specific formats:

```bash
#!/usr/bin/env zsh
set -e

THEME_DIR="$(cd "$(dirname "$0")" && pwd)"
COLORS_JSON="$THEME_DIR/colors.json"
OUT_DIR="$THEME_DIR/generated"

mkdir -p "$OUT_DIR"

# Shell colors (for scripts, fzf)
jq -r 'to_entries | .[] | "export CATPPUCCIN_\(.key | ascii_upcase)=\"\(.value)\""' \
    "$COLORS_JSON" > "$OUT_DIR/shell-colors.sh"

# p10k colors
jq -r 'to_entries | .[] | "typeset -g P10K_COLOR_\(.key | ascii_upcase)=\"\(.value)\""' \
    "$COLORS_JSON" > "$OUT_DIR/p10k-colors.zsh"

# Tmux colors
jq -r 'to_entries | .[] | "set -g @thm_\(.key) \"\(.value)\""' \
    "$COLORS_JSON" > "$OUT_DIR/tmux-colors.conf"

# iTerm profile (complex - uses template)
generate_iterm_profile

# Cursor overrides
generate_cursor_overrides
```

## Tool Integration Details

### Tmux

**Changes to `.tmux.conf`:**
1. Add at top: `source-file ~/dotfiles/theme/generated/tmux-colors.conf`
2. Replace all hardcoded hex values with `#{@thm_*}` variable references
3. Change `@catppuccin_flavor` from `'macchiato'` to `'mocha'`
4. Remove the Macchiato color block (lines 154-158)

**Example replacements:**
- `#24273a` → `#{@thm_base}`
- `#181926` → `#{@thm_crust}`
- `#b7bdf8` → `#{@thm_lavender}`

**Status bar scripts** (`battery_status.sh`, `update_session_status.sh`):
- Source `theme/generated/shell-colors.sh`
- Replace hardcoded values with `$CATPPUCCIN_*` variables

### Powerlevel10k

**Changes to `.p10k.zsh`:**
- Replace the color definition block (lines 25-58) with:
  ```zsh
  source ~/dotfiles/theme/generated/p10k-colors.zsh
  ```
- All existing `$P10K_COLOR_*` references continue to work

### Shell and fzf

**Changes to `.zshrc`:**
- Add early: `source ~/dotfiles/theme/generated/shell-colors.sh`

**Changes to `fzf/.fzf-env.zsh`:**
- Update `--color` options to use `$CATPPUCCIN_*` variables
- Generator exports `$FZF_CATPPUCCIN_COLORS` with the full color string

### iTerm

**Generated:** `theme/generated/iterm-profile.json`
- Full dynamic profile with all 16 ANSI colors + UI colors
- Colors converted from hex to iTerm's RGB float format

**setup.sh integration:**
```bash
mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
ln -sf "$DOTFILES/theme/generated/iterm-profile.json" \
    "$HOME/Library/Application Support/iTerm2/DynamicProfiles/"
```

**User action:** Select "Catppuccin Mocha Custom" as default profile in iTerm preferences (one-time).

### Cursor

**Generated:** `theme/generated/cursor-overrides.json`
```json
{
  "workbench.colorCustomizations": {
    "[Catppuccin Mocha]": {
      "editor.background": "#181825",
      "sideBar.background": "#141420",
      "terminal.background": "#181825",
      "titleBar.activeBackground": "#141420"
    }
  }
}
```

**setup.sh integration:**
```bash
cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"

if [[ -f "$cursor_settings" ]]; then
    # Merge color overrides (idempotent)
    jq -s '.[0] * .[1]' "$cursor_settings" \
        "$DOTFILES/theme/generated/cursor-overrides.json" > tmp \
        && mv tmp "$cursor_settings"
else
    gum_dim "Cursor not installed - skipping color overrides"
fi
```

**Note:** Overrides are scoped to `[Catppuccin Mocha]` theme. Safe to apply before installing the Catppuccin extension - they sit dormant until the theme is active.

## setup.sh Changes

```bash
# === Theme Generation (early, before symlinks) ===
gum_info "Generating theme files..."
"$DOTFILES/theme/generate-theme.sh"

# === In symlink section ===
# iTerm dynamic profile
mkdir -p "$HOME/Library/Application Support/iTerm2/DynamicProfiles"
ln -sf "$DOTFILES/theme/generated/iterm-profile.json" \
    "$HOME/Library/Application Support/iTerm2/DynamicProfiles/catppuccin-mocha-custom.json"

# === After app installs ===
merge_cursor_colors() {
    local cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"
    if [[ -f "$cursor_settings" ]]; then
        gum_info "Merging Catppuccin colors into Cursor settings..."
        jq -s '.[0] * .[1]' "$cursor_settings" \
            "$DOTFILES/theme/generated/cursor-overrides.json" > tmp \
            && mv tmp "$cursor_settings"
        gum_success "Cursor colors updated"
    else
        gum_dim "Cursor not installed - skipping color overrides"
    fi
}

merge_cursor_colors
```

## Files Changed Summary

### New Files
| File | Purpose |
|------|---------|
| `theme/colors.json` | Source of truth |
| `theme/generate-theme.sh` | Generator script |
| `theme/generated/shell-colors.sh` | Shell/fzf colors |
| `theme/generated/p10k-colors.zsh` | Powerlevel10k colors |
| `theme/generated/tmux-colors.conf` | Tmux colors |
| `theme/generated/iterm-profile.json` | iTerm dynamic profile |
| `theme/generated/cursor-overrides.json` | Cursor overrides |

### Modified Files
| File | Change |
|------|--------|
| `setup.sh` | Add theme generation, iTerm symlink, Cursor merge |
| `shell/.zshrc` | Source `shell-colors.sh` |
| `shell/.p10k.zsh` | Replace color block with source statement |
| `tmux/.tmux.conf` | Source colors, replace ~30 hex values, switch to mocha |
| `tmux/scripts/battery_status.sh` | Use `$CATPPUCCIN_*` variables |
| `tmux/scripts/update_session_status.sh` | Use `$CATPPUCCIN_*` variables |
| `fzf/.fzf-env.zsh` | Update `--color` to use variables |
| `install/install_functions.sh` | Add symlinks for theme files |

### Unchanged
| File | Reason |
|------|--------|
| `shell/lscolors.sh` | Already uses vivid with standard Mocha |

## Edge Cases

1. **Fresh machine, no Cursor:** setup.sh skips merge with informational message
2. **Fresh machine, no iTerm launched yet:** setup.sh creates DynamicProfiles directory
3. **Catppuccin extension not installed in Cursor:** Overrides sit dormant until theme is selected
4. **Running setup.sh multiple times:** All operations are idempotent

## Testing Plan

1. Run `theme/generate-theme.sh` and verify all files generated correctly
2. Run `setup.sh` on current machine, verify no errors
3. Source `.zshrc`, verify p10k and fzf colors correct
4. Open tmux, verify status bar colors correct
5. Open iTerm, select new profile, verify colors
6. Open Cursor, verify background colors match custom values
7. Test on fresh VM to verify edge cases
