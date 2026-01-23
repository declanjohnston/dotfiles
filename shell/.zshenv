export LANG='en_US.UTF-8'
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
