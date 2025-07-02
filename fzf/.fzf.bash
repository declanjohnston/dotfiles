# Setup fzf
# ---------
if [[ ! "$PATH" == */home/declanjohnston/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/declanjohnston/.fzf/bin"
fi

eval "$(fzf --bash)"
