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

# Redirect caches to /workspace to avoid filling root filesystem
# Root overlay is typically 20GB and fills up quickly with model downloads
echo "📁 Setting up cache symlinks to /workspace..."
mkdir -p /workspace/.cache/huggingface /workspace/.cache/uv

if [ ! -L "$HOME/.cache/huggingface" ]; then
    rm -rf "$HOME/.cache/huggingface" 2>/dev/null || true
    mkdir -p "$HOME/.cache"
    ln -sf /workspace/.cache/huggingface "$HOME/.cache/huggingface"
    echo "✓ Symlinked ~/.cache/huggingface -> /workspace/.cache/huggingface"
fi

if [ ! -L "$HOME/.cache/uv" ]; then
    rm -rf "$HOME/.cache/uv" 2>/dev/null || true
    mkdir -p "$HOME/.cache"
    ln -sf /workspace/.cache/uv "$HOME/.cache/uv"
    echo "✓ Symlinked ~/.cache/uv -> /workspace/.cache/uv"
fi

# Source install functions and install zsh
source "$DOTFILES_DIR/install/install_functions.sh"
install_if_missing zsh install_zsh

# Configure tokens from RunPod secrets
echo "🔐 Configuring API tokens..."

# Create local env file for persistent environment variables
LOCAL_ENV_FILE="$DOTFILES_DIR/local/.local_env.sh"
mkdir -p "$(dirname "$LOCAL_ENV_FILE")"
touch "$LOCAL_ENV_FILE"

# Hugging Face token
if [ -n "$HF_TOKEN" ]; then
    mkdir -p "$HOME/.huggingface"
    echo "$HF_TOKEN" > "$HOME/.huggingface/token"
    
    # Add to local env if not already present
    if ! grep -q "export HF_TOKEN" "$LOCAL_ENV_FILE" 2>/dev/null; then
        echo "export HF_TOKEN='$HF_TOKEN'" >> "$LOCAL_ENV_FILE"
    fi
    echo "✓ Configured Hugging Face token"
fi

# Weights & Biases token
if [ -n "$WANDB_TOKEN" ]; then
    # Create/update .netrc for wandb
    cat > "$HOME/.netrc" << EOF
machine api.wandb.ai
  login user
  password $WANDB_TOKEN
EOF
    chmod 600 "$HOME/.netrc"
    
    # Also set in wandb settings
    mkdir -p "$HOME/.config/wandb"
    echo "[default]" > "$HOME/.config/wandb/settings"
    echo "api_key = $WANDB_TOKEN" >> "$HOME/.config/wandb/settings"
    
    # Add to local env if not already present
    if ! grep -q "export WANDB_TOKEN" "$LOCAL_ENV_FILE" 2>/dev/null; then
        echo "export WANDB_TOKEN='$WANDB_TOKEN'" >> "$LOCAL_ENV_FILE"
    fi
    echo "✓ Configured Weights & Biases token"
fi

# GitHub token (for git operations)
if [ -n "$GITHUB_TOKEN" ]; then
    # Configure git to use token for HTTPS operations
    git config --global credential.helper store
    echo "https://oauth2:${GITHUB_TOKEN}@github.com" > "$HOME/.git-credentials"
    chmod 600 "$HOME/.git-credentials"
    
    # Add to local env if not already present
    if ! grep -q "export GITHUB_TOKEN" "$LOCAL_ENV_FILE" 2>/dev/null; then
        echo "export GITHUB_TOKEN='$GITHUB_TOKEN'" >> "$LOCAL_ENV_FILE"
    fi
    echo "✓ Configured GitHub token for git operations"
fi

# Ngrok token (for tunnel access)
if [ -n "$NGROK_TOKEN" ]; then
    # Add to local env as NGROK_AUTH_TOKEN (pyngrok expects this name)
    if ! grep -q "export NGROK_AUTH_TOKEN" "$LOCAL_ENV_FILE" 2>/dev/null; then
        echo "export NGROK_AUTH_TOKEN='$NGROK_TOKEN'" >> "$LOCAL_ENV_FILE"
    fi
    echo "✓ Configured ngrok auth token"
fi

# Ensure ~/.cache exists and is writable before zsh startup
mkdir -p "$HOME/.cache"
if [[ "$(id -u)" -eq 0 && "$HOME" != "/root" ]]; then
    target_user=$(basename "$HOME")
    chown -R "$target_user:$target_user" "$HOME/.cache" 2>/dev/null || true
fi

# Run setup.sh from zsh with --minimal flag, mark as bootstrapped, and stay in zsh
cd "$DOTFILES_DIR"
exec zsh -c "./setup.sh --minimal && touch '$BOOTSTRAP_MARKER' && echo '' && echo '✓ RunPod setup complete! Starting zsh...'"
