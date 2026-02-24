# ===================================================================
# PATH AND ENVIRONMENT SETUP
# ===================================================================

# NVM Setup
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Consolidated PATH Setup (order matters - earlier entries take precedence)
PATH_ADDITIONS=(
    "$HOME/.local/bin"              # Local user binaries
    "$HOME/bin"                     # Personal scripts
    "$HOME/tools"                   # Custom tools from dotfiles
    "$HOME/.claude"               # Claude CLI
    "$HOME/.bun/bin"                # Bun runtime
    "$HOME/.npm-global/bin"         # Global npm packages
    "$HOME/go/bin"                  # Go binaries
    "/usr/local/go/bin"             # Go installation
    "$HOME/.cargo/bin"              # Rust/Cargo binaries
    "/opt/homebrew/bin"             # Homebrew binaries
)


# Add paths to PATH if they exist and aren't already present
for path_dir in "${PATH_ADDITIONS[@]}"; do
    if [[ -n "$path_dir" && -d "$path_dir" && ":$PATH:" != *":$path_dir:"* ]]; then
        export PATH="$path_dir:$PATH"
    fi
done

# REMOVE DUPLICATES
export PATH=$(echo -n $PATH | awk -v RS=: -v ORS=: '!seen[$0]++' | sed 's/:$//')

# Additional Environment Variables
export BAT_THEME="Solarized (light)"
export WANDB_ENTITY='djohnston'

# Cursor Extension Path
if [ -d "$HOME/.cursor-server/extensions/*tomrijndorp*" ]; then
    export EXTENSION_PATH=$(find ~/.cursor-server/extensions  -type d -name 'tomrijndorp*')
fi

# Htop filter
export HTOP_FILTER='sshd|jupyter/runtime/kernel|.cursor-server|/usr/bin/dockerd|/usr/lib/snapd/snapd|amazon|containerd|ssh-agent|gitstatus|zsh|sleep'
