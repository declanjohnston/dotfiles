# Catppuccin Theming Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Standardize Catppuccin Mocha theming across all dev tools with a single source of truth.

**Architecture:** JSON color definitions generate tool-specific configs (shell, tmux, p10k, iTerm, Cursor). All generated files committed to repo. setup.sh runs generator and handles symlinks/merges.

**Tech Stack:** jq for JSON parsing, zsh/bash scripts, tmux user options, iTerm Dynamic Profiles, Cursor workbench.colorCustomizations

---

## Task 1: Create Source of Truth (colors.json)

**Files:**
- Create: `theme/colors.json`

**Step 1: Create theme directory**

```bash
mkdir -p theme/generated
```

**Step 2: Create colors.json with custom Mocha palette**

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

**Step 3: Verify JSON is valid**

Run: `jq . theme/colors.json`
Expected: Pretty-printed JSON output without errors

**Step 4: Commit**

```bash
git add theme/colors.json
git commit -m "feat(theme): add custom Catppuccin Mocha color definitions

Custom palette with darker backgrounds for better text readability:
- Base shifted to #181825 (was Mantle)
- Mantle now #141420 (avg of old Mantle/Crust)
- Crust unchanged at #11111b"
```

---

## Task 2: Create Generator Script

**Files:**
- Create: `theme/generate-theme.sh`

**Step 1: Create the generator script**

```bash
#!/usr/bin/env zsh
set -e

# Resolve script directory
THEME_DIR="$(cd "$(dirname "$0")" && pwd)"
COLORS_JSON="$THEME_DIR/colors.json"
OUT_DIR="$THEME_DIR/generated"

# Source gum utilities if available
[[ -f "$HOME/dotfiles/shell/gum_utils.sh" ]] && source "$HOME/dotfiles/shell/gum_utils.sh"

mkdir -p "$OUT_DIR"

# ============================================
# Shell colors (for scripts, fzf)
# ============================================
gum_info "Generating shell-colors.sh..." 2>/dev/null || echo "Generating shell-colors.sh..."

cat > "$OUT_DIR/shell-colors.sh" << 'HEADER'
# Auto-generated from theme/colors.json - do not edit directly
# Source this file to get CATPPUCCIN_* environment variables
HEADER

jq -r 'to_entries | .[] | "export CATPPUCCIN_\(.key | ascii_upcase)=\"\(.value)\""' \
    "$COLORS_JSON" >> "$OUT_DIR/shell-colors.sh"

# Add FZF color string
cat >> "$OUT_DIR/shell-colors.sh" << 'FZF_COLORS'

# FZF Catppuccin color scheme
export FZF_CATPPUCCIN_COLORS="--color=bg+:$CATPPUCCIN_SURFACE0,bg:$CATPPUCCIN_BASE,spinner:$CATPPUCCIN_ROSEWATER,hl:$CATPPUCCIN_RED,fg:$CATPPUCCIN_TEXT,header:$CATPPUCCIN_RED,info:$CATPPUCCIN_MAUVE,pointer:$CATPPUCCIN_ROSEWATER,marker:$CATPPUCCIN_ROSEWATER,fg+:$CATPPUCCIN_TEXT,prompt:$CATPPUCCIN_MAUVE,hl+:$CATPPUCCIN_RED,border:$CATPPUCCIN_SURFACE1"
FZF_COLORS

# ============================================
# p10k colors
# ============================================
gum_info "Generating p10k-colors.zsh..." 2>/dev/null || echo "Generating p10k-colors.zsh..."

cat > "$OUT_DIR/p10k-colors.zsh" << 'HEADER'
# Auto-generated from theme/colors.json - do not edit directly
# Catppuccin Mocha (Custom) Palette for Powerlevel10k
HEADER

jq -r 'to_entries | .[] | "typeset -g P10K_COLOR_\(.key | ascii_upcase)=\"\(.value)\""' \
    "$COLORS_JSON" >> "$OUT_DIR/p10k-colors.zsh"

# ============================================
# Tmux colors
# ============================================
gum_info "Generating tmux-colors.conf..." 2>/dev/null || echo "Generating tmux-colors.conf..."

cat > "$OUT_DIR/tmux-colors.conf" << 'HEADER'
# Auto-generated from theme/colors.json - do not edit directly
# Source this file at the top of .tmux.conf before loading catppuccin plugin
HEADER

jq -r 'to_entries | .[] | "set -g @thm_\(.key) \"\(.value)\""' \
    "$COLORS_JSON" >> "$OUT_DIR/tmux-colors.conf"

# ============================================
# iTerm Dynamic Profile
# ============================================
gum_info "Generating iterm-profile.json..." 2>/dev/null || echo "Generating iterm-profile.json..."

# Helper function to convert hex to iTerm RGB floats
hex_to_iterm_rgb() {
    local hex="${1#\#}"
    local r=$((16#${hex:0:2}))
    local g=$((16#${hex:2:2}))
    local b=$((16#${hex:4:2}))
    printf '{"Red Component": %.6f, "Green Component": %.6f, "Blue Component": %.6f, "Color Space": "sRGB"}' \
        "$(echo "scale=6; $r/255" | bc)" \
        "$(echo "scale=6; $g/255" | bc)" \
        "$(echo "scale=6; $b/255" | bc)"
}

# Read colors from JSON
base=$(jq -r '.base' "$COLORS_JSON")
text=$(jq -r '.text' "$COLORS_JSON")
crust=$(jq -r '.crust' "$COLORS_JSON")
surface0=$(jq -r '.surface0' "$COLORS_JSON")
surface1=$(jq -r '.surface1' "$COLORS_JSON")
surface2=$(jq -r '.surface2' "$COLORS_JSON")
red=$(jq -r '.red' "$COLORS_JSON")
green=$(jq -r '.green' "$COLORS_JSON")
yellow=$(jq -r '.yellow' "$COLORS_JSON")
blue=$(jq -r '.blue' "$COLORS_JSON")
pink=$(jq -r '.pink' "$COLORS_JSON")
teal=$(jq -r '.teal' "$COLORS_JSON")
lavender=$(jq -r '.lavender' "$COLORS_JSON")
peach=$(jq -r '.peach' "$COLORS_JSON")
rosewater=$(jq -r '.rosewater' "$COLORS_JSON")
flamingo=$(jq -r '.flamingo' "$COLORS_JSON")
mauve=$(jq -r '.mauve' "$COLORS_JSON")
maroon=$(jq -r '.maroon' "$COLORS_JSON")
sky=$(jq -r '.sky' "$COLORS_JSON")
sapphire=$(jq -r '.sapphire' "$COLORS_JSON")

cat > "$OUT_DIR/iterm-profile.json" << EOF
{
  "Profiles": [
    {
      "Name": "Catppuccin Mocha Custom",
      "Guid": "catppuccin-mocha-custom-$(date +%s)",
      "Badge Color": $(hex_to_iterm_rgb "$rosewater"),
      "Background Color": $(hex_to_iterm_rgb "$base"),
      "Foreground Color": $(hex_to_iterm_rgb "$text"),
      "Bold Color": $(hex_to_iterm_rgb "$text"),
      "Cursor Color": $(hex_to_iterm_rgb "$rosewater"),
      "Cursor Text Color": $(hex_to_iterm_rgb "$crust"),
      "Selection Color": $(hex_to_iterm_rgb "$surface2"),
      "Selected Text Color": $(hex_to_iterm_rgb "$text"),
      "Link Color": $(hex_to_iterm_rgb "$blue"),
      "Ansi 0 Color": $(hex_to_iterm_rgb "$surface1"),
      "Ansi 1 Color": $(hex_to_iterm_rgb "$red"),
      "Ansi 2 Color": $(hex_to_iterm_rgb "$green"),
      "Ansi 3 Color": $(hex_to_iterm_rgb "$yellow"),
      "Ansi 4 Color": $(hex_to_iterm_rgb "$blue"),
      "Ansi 5 Color": $(hex_to_iterm_rgb "$pink"),
      "Ansi 6 Color": $(hex_to_iterm_rgb "$teal"),
      "Ansi 7 Color": $(hex_to_iterm_rgb "$surface2"),
      "Ansi 8 Color": $(hex_to_iterm_rgb "$surface2"),
      "Ansi 9 Color": $(hex_to_iterm_rgb "$red"),
      "Ansi 10 Color": $(hex_to_iterm_rgb "$green"),
      "Ansi 11 Color": $(hex_to_iterm_rgb "$yellow"),
      "Ansi 12 Color": $(hex_to_iterm_rgb "$blue"),
      "Ansi 13 Color": $(hex_to_iterm_rgb "$pink"),
      "Ansi 14 Color": $(hex_to_iterm_rgb "$teal"),
      "Ansi 15 Color": $(hex_to_iterm_rgb "$lavender")
    }
  ]
}
EOF

# ============================================
# Cursor overrides
# ============================================
gum_info "Generating cursor-overrides.json..." 2>/dev/null || echo "Generating cursor-overrides.json..."

mantle=$(jq -r '.mantle' "$COLORS_JSON")

cat > "$OUT_DIR/cursor-overrides.json" << EOF
{
  "workbench.colorCustomizations": {
    "[Catppuccin Mocha]": {
      "editor.background": "$base",
      "sideBar.background": "$mantle",
      "sideBarSectionHeader.background": "$mantle",
      "terminal.background": "$base",
      "titleBar.activeBackground": "$mantle",
      "titleBar.inactiveBackground": "$mantle",
      "panel.background": "$base",
      "activityBar.background": "$mantle",
      "statusBar.background": "$mantle",
      "tab.inactiveBackground": "$mantle",
      "editorGroupHeader.tabsBackground": "$mantle"
    }
  }
}
EOF

gum_success "Theme files generated in $OUT_DIR" 2>/dev/null || echo "Theme files generated in $OUT_DIR"
```

**Step 2: Make script executable**

Run: `chmod +x theme/generate-theme.sh`

**Step 3: Run generator and verify outputs**

Run: `./theme/generate-theme.sh`
Expected: 5 files created in `theme/generated/`

**Step 4: Verify generated files exist and have content**

Run: `ls -la theme/generated/`
Expected: shell-colors.sh, p10k-colors.zsh, tmux-colors.conf, iterm-profile.json, cursor-overrides.json

Run: `head -5 theme/generated/shell-colors.sh`
Expected: Header comment and CATPPUCCIN_BASE export

**Step 5: Commit**

```bash
git add theme/generate-theme.sh theme/generated/
git commit -m "feat(theme): add generator script and generated configs

Creates tool-specific color configs from colors.json:
- shell-colors.sh for shell scripts and fzf
- p10k-colors.zsh for Powerlevel10k
- tmux-colors.conf for tmux
- iterm-profile.json for iTerm Dynamic Profiles
- cursor-overrides.json for Cursor editor"
```

---

## Task 3: Update .zshrc to Source Shell Colors

**Files:**
- Modify: `shell/.zshrc:40-45`

**Step 1: Add shell colors source line**

Add after line 41 (after `source ~/gum_utils.sh`):
```zsh
source ~/dotfiles/theme/generated/shell-colors.sh
```

The block should become:
```zsh
# Source Core Configuration Files
source ~/helper_functions.sh
source ~/gum_utils.sh
source ~/dotfiles/theme/generated/shell-colors.sh
source ~/lscolors.sh
source ~/.aliases-and-envs.zsh
```

**Step 2: Verify syntax**

Run: `zsh -n shell/.zshrc`
Expected: No output (no syntax errors)

**Step 3: Commit**

```bash
git add shell/.zshrc
git commit -m "feat(shell): source generated Catppuccin colors in zshrc"
```

---

## Task 4: Update p10k to Use Generated Colors

**Files:**
- Modify: `shell/.p10k.zsh:21-58`

**Step 1: Replace color definition block**

Replace lines 21-58 (the Catppuccin Macchiato Palette section) with:
```zsh
  # Catppuccin Mocha (Custom) Palette - sourced from generated file
  source ~/dotfiles/theme/generated/p10k-colors.zsh
```

**Step 2: Update comment on line 1**

Change:
```zsh
# Config for Powerlevel10k with rainbow (Catppuccin Macchiato) prompt style.
```
To:
```zsh
# Config for Powerlevel10k with rainbow (Catppuccin Mocha Custom) prompt style.
```

**Step 3: Verify the file still loads**

Run: `zsh -c 'source shell/.p10k.zsh && echo "P10K_COLOR_BASE=$P10K_COLOR_BASE"'`
Expected: P10K_COLOR_BASE=#181825

**Step 4: Commit**

```bash
git add shell/.p10k.zsh
git commit -m "refactor(p10k): source colors from generated file

Replaces inline Macchiato color definitions with source from
theme/generated/p10k-colors.zsh for single source of truth."
```

---

## Task 5: Update tmux.conf to Use Generated Colors

**Files:**
- Modify: `tmux/.tmux.conf`

**Step 1: Add source line near top (after line 6)**

Add after the comment block:
```tmux
# Source custom Catppuccin colors (must be before catppuccin plugin)
source-file ~/dotfiles/theme/generated/tmux-colors.conf
```

**Step 2: Change catppuccin flavor from macchiato to mocha (line 186)**

Change:
```tmux
set -g @catppuccin_flavor 'macchiato'
```
To:
```tmux
set -g @catppuccin_flavor 'mocha'
```

**Step 3: Remove the hardcoded Macchiato color block (lines 152-158)**

Delete these lines:
```tmux
# ===================================================================
# Key Table Variables (for F12 toggle functionality)
# Catppuccin Macchiato colors
# ===================================================================
color_status_text="#a5adcb"           # subtext0
color_window_off_status_bg="#363a4f"  # surface0
color_light="#cad3f5"                 # text
color_dark="#24273a"                  # base
color_window_off_status_current_bg="#5b6078"  # surface2
```

**Step 4: Update F12 key table to use theme variables**

Replace the color references in F12 bindings with:
```tmux
color_status_text="#{@thm_subtext0}"
color_window_off_status_bg="#{@thm_surface0}"
color_light="#{@thm_text}"
color_dark="#{@thm_base}"
color_window_off_status_current_bg="#{@thm_surface2}"
```

**Step 5: Update status-right hardcoded colors**

Replace all hex colors in status-right with theme variables:
- `#24273a` → `#{@thm_base}`
- `#181926` → `#{@thm_crust}`
- `#b7bdf8` → `#{@thm_lavender}`
- `#f5a97f` → `#{@thm_peach}`
- `#8bd5ca` → `#{@thm_teal}`
- `#a6da95` → `#{@thm_green}`
- `#7dc4e4` → `#{@thm_sapphire}`
- `#eed49f` → `#{@thm_yellow}`
- `#c6a0f6` → `#{@thm_mauve}`
- `#cad3f5` → `#{@thm_text}`
- `#494d64` → `#{@thm_surface1}`
- `#5b6078` → `#{@thm_surface2}`

**Step 6: Verify tmux config syntax**

Run: `tmux source-file tmux/.tmux.conf` (in a tmux session)
Expected: No errors

**Step 7: Commit**

```bash
git add tmux/.tmux.conf
git commit -m "refactor(tmux): use generated Catppuccin colors

- Source tmux-colors.conf for theme variables
- Switch flavor from macchiato to mocha
- Replace ~30 hardcoded hex values with #{@thm_*} vars"
```

---

## Task 6: Update Tmux Status Scripts

**Files:**
- Modify: `tmux/scripts/battery_status.sh`
- Modify: `tmux/scripts/update_session_status.sh`

**Step 1: Update battery_status.sh**

Add at top (after shebang):
```bash
source ~/dotfiles/theme/generated/shell-colors.sh
```

Replace:
```bash
BASE="#24273a"
CRUST="#181926"
```
With:
```bash
BASE="$CATPPUCCIN_BASE"
CRUST="$CATPPUCCIN_CRUST"
```

Update get_color function to use variables:
```bash
get_color() {
    local pct=$1
    if   (( pct >= 80 )); then echo "$CATPPUCCIN_GREEN"
    elif (( pct >= 60 )); then echo "$CATPPUCCIN_YELLOW"
    elif (( pct >= 40 )); then echo "$CATPPUCCIN_PEACH"
    elif (( pct >= 20 )); then echo "$CATPPUCCIN_RED"
    else                       echo "$CATPPUCCIN_MAROON"
    fi
}
```

**Step 2: Update update_session_status.sh**

Add at top (after shebang):
```bash
source ~/dotfiles/theme/generated/shell-colors.sh
```

Replace hardcoded colors:
```bash
base="$CATPPUCCIN_BASE"
crust="$CATPPUCCIN_CRUST"
peach="$CATPPUCCIN_PEACH"
yellow="$CATPPUCCIN_YELLOW"
```

And update references to `#cad3f5` → `$CATPPUCCIN_TEXT`, `#5b6078` → `$CATPPUCCIN_SURFACE2`

**Step 3: Test scripts**

Run: `./tmux/scripts/battery_status.sh`
Expected: Output with tmux color codes (no errors)

**Step 4: Commit**

```bash
git add tmux/scripts/battery_status.sh tmux/scripts/update_session_status.sh
git commit -m "refactor(tmux): use generated colors in status scripts"
```

---

## Task 7: Update fzf Colors

**Files:**
- Modify: `fzf/.fzf-env.zsh`

**Step 1: Add Catppuccin colors to FZF_DEFAULT_OPTS**

The shell-colors.sh exports `$FZF_CATPPUCCIN_COLORS`. Update fzf config to use it.

Add near the top after the FZF_DEFAULT_OPTS definition, or replace the existing `--color` lines with a reference to the variable. Since FZF_DEFAULT_OPTS is defined with hardcoded colors, add:

```bash
# Apply Catppuccin colors (after shell-colors.sh is sourced in .zshrc)
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_CATPPUCCIN_COLORS"
```

Or replace the existing color definitions in FZF_DEFAULT_OPTS.

**Step 2: Remove old hardcoded color lines**

Remove these lines from FZF_DEFAULT_OPTS:
```bash
    --color 'border:#aaaaaa,label:#cccccc' \
    --color 'preview-border:#9999cc,preview-label:#ccccff' \
    --color 'list-border:#669966,list-label:#99cc99' \
    --color 'input-border:#996666,input-label:#ffcccc' \
    --color 'header-border:#6699cc,header-label:#99ccff'
```

**Step 3: Verify fzf colors work**

Run: `source fzf/.fzf-env.zsh && echo $FZF_DEFAULT_OPTS`
Expected: Contains Catppuccin color definitions

**Step 4: Commit**

```bash
git add fzf/.fzf-env.zsh
git commit -m "refactor(fzf): use Catppuccin colors from generated file"
```

---

## Task 8: Update setup.sh

**Files:**
- Modify: `setup.sh`
- Modify: `install/install_functions.sh`

**Step 1: Add theme generation to setup.sh (after line 29, before install_dotfiles)**

```bash
# Generate theme files before symlinking
gum_info "Generating theme files..."
"$HOME/dotfiles/theme/generate-theme.sh"
```

**Step 2: Add iTerm symlink to install_functions.sh install_dotfiles function**

Add to file_pairs array:
```bash
# Theme generated files
"$dotfiles/theme/generated/shell-colors.sh:$home/dotfiles/theme/generated/shell-colors.sh"
```

And add a separate block after the symlink loop for iTerm (since it goes to Application Support):
```bash
# iTerm Dynamic Profile (macOS only)
if [[ "$OSTYPE" == "darwin"* ]]; then
    local iterm_profiles="$HOME/Library/Application Support/iTerm2/DynamicProfiles"
    mkdir -p "$iterm_profiles"
    ln -sf "$dotfiles/theme/generated/iterm-profile.json" "$iterm_profiles/catppuccin-mocha-custom.json"
    gum_dim "iTerm profile symlinked to DynamicProfiles"
fi
```

**Step 3: Add Cursor merge function to install_functions.sh**

Add new function:
```bash
merge_cursor_colors() {
    local cursor_settings="$HOME/Library/Application Support/Cursor/User/settings.json"
    local overrides="$HOME/dotfiles/theme/generated/cursor-overrides.json"

    if [[ -f "$cursor_settings" ]] && [[ -f "$overrides" ]]; then
        gum_info "Merging Catppuccin colors into Cursor settings..."
        local tmp_file="${cursor_settings}.tmp"
        jq -s '.[0] * .[1]' "$cursor_settings" "$overrides" > "$tmp_file" && mv "$tmp_file" "$cursor_settings"
        gum_success "Cursor colors updated"
    else
        gum_dim "Cursor not installed or overrides not generated - skipping color merge"
    fi
}
```

**Step 4: Call merge_cursor_colors at end of setup.sh**

Add before the final success message:
```bash
# Merge Cursor color overrides
merge_cursor_colors
```

**Step 5: Verify setup.sh syntax**

Run: `zsh -n setup.sh`
Expected: No errors

**Step 6: Commit**

```bash
git add setup.sh install/install_functions.sh
git commit -m "feat(setup): add theme generation and app integrations

- Run generate-theme.sh before symlinking
- Symlink iTerm dynamic profile to DynamicProfiles
- Merge Cursor color overrides into settings.json"
```

---

## Task 9: Final Verification

**Step 1: Run full setup**

Run: `./setup.sh` (or just the theme generation part)

**Step 2: Verify shell colors**

Run: `source ~/.zshrc && echo $CATPPUCCIN_BASE`
Expected: #181825

**Step 3: Verify tmux**

Open new tmux session, check status bar colors match Mocha theme

**Step 4: Verify p10k**

Check prompt colors in new terminal

**Step 5: Verify iTerm (macOS)**

Open iTerm Preferences > Profiles, verify "Catppuccin Mocha Custom" appears

**Step 6: Verify Cursor**

Open Cursor, check background colors are darker than standard Mocha

**Step 7: Final commit**

```bash
git add -A
git commit -m "chore: complete Catppuccin theming standardization

All dev tools now use custom Mocha palette from single source of truth.
- Darker backgrounds (base=#181825) for better text readability
- Consistent theme across tmux, p10k, fzf, iTerm, Cursor"
```

---

## Summary

| Task | Files | Description |
|------|-------|-------------|
| 1 | theme/colors.json | Create source of truth |
| 2 | theme/generate-theme.sh | Create generator script |
| 3 | shell/.zshrc | Source shell colors |
| 4 | shell/.p10k.zsh | Use generated p10k colors |
| 5 | tmux/.tmux.conf | Use generated tmux colors |
| 6 | tmux/scripts/*.sh | Update status scripts |
| 7 | fzf/.fzf-env.zsh | Use Catppuccin fzf colors |
| 8 | setup.sh, install_functions.sh | Add generation and app integrations |
| 9 | - | Final verification |
