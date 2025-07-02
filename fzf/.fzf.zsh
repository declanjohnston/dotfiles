# Setup fzf
# ---------
if [[ ! "$PATH" == */home/declanjohnston/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/declanjohnston/.fzf/bin"
fi

source <(fzf --zsh)
