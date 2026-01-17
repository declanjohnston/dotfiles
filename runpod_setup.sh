#!/bin/bash
# ===================================================================
# RunPod Setup Script
# ===================================================================
# Run this when a RunPod pod starts to bootstrap the environment.
# Uses --minimal flag to skip heavy installs (Helix, Cargo, Go, Node).
# Optimized for Cursor development (~5-10 min vs ~60-80 min).
#
# Docker Command (one-liner for RunPod template):
#   bash -c "git clone https://github.com/declanjohnston/dotfiles.git /workspace/dotfiles 2>/dev/null || true && /workspace/dotfiles/runpod_setup.sh"
#
# Usage: /workspace/dotfiles/runpod_setup.sh
# ===================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="${SCRIPT_DIR}"
DOTFILES_REPO="https://github.com/declanjohnston/dotfiles.git"
BOOTSTRAP_MARKER="$HOME/.dotfiles_bootstrapped"

# Clone dotfiles if missing (handles case where script is run standalone)
if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "📦 Cloning dotfiles repository..."
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
    echo "✓ Cloned dotfiles to $DOTFILES_DIR"
fi

# Skip if already bootstrapped this session
if [ -f "$BOOTSTRAP_MARKER" ]; then
    echo "✓ Dotfiles already bootstrapped this session"
    exit 0
fi

echo "🚀 Bootstrapping RunPod environment..."

# Create symlink to dotfiles in home
if [ ! -L "$HOME/dotfiles" ]; then
    ln -sf "$DOTFILES_DIR" "$HOME/dotfiles"
    echo "✓ Symlinked ~/dotfiles -> $DOTFILES_DIR"
fi

# Source install functions and install zsh
source "$DOTFILES_DIR/install/install_functions.sh"
install_if_missing zsh install_zsh

# Run setup.sh from zsh with --minimal flag, mark as bootstrapped, and stay in zsh
cd "$DOTFILES_DIR"
exec zsh -c "./setup.sh --minimal && touch '$BOOTSTRAP_MARKER' && echo '' && echo '✓ RunPod setup complete! Starting zsh...'"
