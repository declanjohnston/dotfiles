export LANG='en_US.UTF-8'

# Ensure 24-bit truecolor is advertised to TUIs (opencode, bubble tea, etc.).
# SSH does not forward COLORTERM, so it ends up empty on remote boxes even
# though iTerm/VSCode/etc. set it locally. Without this, dark theme
# backgrounds get quantized to the nearest 256-color palette entry.
: "${COLORTERM:=truecolor}"
export COLORTERM
#
# Defines environment variables.
#
# Authors:
#   Sorin Ionescu <sorin.ionescu@gmail.com>
#

# Ensure that a non-login, non-interactive shell has a defined environment.
if [[ ( "$SHLVL" -eq 1 && ! -o LOGIN ) && -s "${ZDOTDIR:-$HOME}/.zprofile" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprofile"
fi

# Source cargo environment if it exists (only if Rust/Cargo is installed)
[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"

# argcomplete - project-specific paths should be added locally, not in dotfiles

# Begin added by argcomplete
fpath=( /opt/homebrew/share/zsh/site-functions "${fpath[@]}" )
# End added by argcomplete
