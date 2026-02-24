#!/bin/bash

export FZF_PREVIEW_WINDOW_BINDING='ctrl-/:change-preview-window(down,80%|hidden|)'

# https://erees.dev/terminal-tricks/
# export FZF_DEFAULT_OPTS=" \
# --reverse --ansi \
# --color border:41 --border=sharp \
# --inline-info \
# --prompt='➤  ' --pointer='➤ ' --marker='➤ ' \
# --cycle -m  \
# --tmux 95%  \
# --preview-window=right:70%:wrap \
# --bind 'ctrl-/:change-preview-window(down|hidden|)' \
# --bind 'ctrl-d:preview-half-page-down' \
# --bind 'ctrl-u:preview-half-page-up' \
# --bind 'ctrl-s:toggle-sort' \
# --bind 'ctrl-j:preview-down' \
# --bind 'ctrl-k:preview-up' \
# --bind 'ctrl-b:preview-bottom' \
# --bind 'ctrl-n:preview-top'
# "

# --prompt='➤  ' --pointer='➤ ' --marker='➤ ' \

# export FZF_DEFAULT_OPTS=" \
#     --style full --scheme path \
#     --tmux 95%  \
#     --cycle -m  \
#     --reverse --ansi \
#     --border --padding 1,2 \
#     --ghost 'Type in your query' \
#     --border-label ' Demo ' --input-label ' Input ' --header-label ' File Type ' \
#     --footer-label ' MD5 Hash ' \
#     --preview 'BAT_THEME=gruvbox-dark fzf-preview.sh {}' \
#     --bind 'result:transform-list-label: \
#         if [[ -z $FZF_QUERY ]]; then \
#           echo \" $FZF_MATCH_COUNT items \" \
#         else \
#           echo \" $FZF_MATCH_COUNT matches for [$FZF_QUERY] \" \
#         fi \
#         ' \
#     --bind 'focus:bg-transform-preview-label:[[ -n {} ]] && printf \" Previewing [%s] \" {}' \
#     --bind 'focus:+bg-transform-header:[[ -n {} ]] && file --brief {}' \
#     --bind 'focus:+bg-transform-footer:if [[ -n {} ]]; then
#               echo \"MD5:    \$(md5sum < {})\"   \
#               echo \"SHA1:   \$(sha1sum < {})\"   \
#               echo \"SHA256: \$(sha256sum < {})\"   \
#             fi' \
#     --bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)' \
#     --color 'border:#aaaaaa,label:#cccccc' \
#     --color 'preview-border:#9999cc,preview-label:#ccccff' \
#     --color 'list-border:#669966,list-label:#99cc99' \
#     --color 'input-border:#996666,input-label:#ffcccc' \
#     --color 'header-border:#6699cc,header-label:#99ccff' \
#     --color 'footer:#ccbbaa,footer-border:#cc9966,footer-label:#cc9966'"

# Detect tmux version for --tmux flag compatibility (requires 3.3+)
_FZF_TMUX_OPT=""
if command -v tmux >/dev/null 2>&1; then
    _tmux_ver=$(tmux -V 2>/dev/null | grep -oP '[\d.]+' | head -1)
    _tmux_major=${_tmux_ver%%.*}
    _tmux_minor=${_tmux_ver#*.}
    _tmux_minor=${_tmux_minor%%[a-z]*}
    if [[ $_tmux_major -gt 3 ]] || [[ $_tmux_major -eq 3 && $_tmux_minor -ge 3 ]]; then
        _FZF_TMUX_OPT="--tmux 95%"
    fi
    unset _tmux_ver _tmux_major _tmux_minor
fi

# Detect fzf version for --style flag compatibility (requires 0.54+)
_FZF_STYLE_OPT=""
if command -v fzf >/dev/null 2>&1; then
    _fzf_ver=$(fzf --version 2>/dev/null | grep -oP '[\d.]+' | head -1)
    _fzf_minor=$(echo "$_fzf_ver" | cut -d. -f2)
    if [[ ${_fzf_minor:-0} -ge 54 ]]; then
        _FZF_STYLE_OPT="--style full"
    fi
    unset _fzf_ver _fzf_minor
fi

export FZF_DEFAULT_OPTS=" \
    $_FZF_STYLE_OPT \
    $_FZF_TMUX_OPT \
    --cycle -m  \
    --reverse --ansi \
    --border --padding 1,2 \
    --border-label ' Demo ' --input-label ' Input ' --header-label ' File Type ' \
    --preview 'fzf-preview {}' \
    --preview-window=right:70%:nowrap \
    --bind 'result:transform-list-label: \
        if [[ -z \$FZF_QUERY ]]; then \
          echo \" \$FZF_MATCH_COUNT items \" \
        else \
          echo \" \$FZF_MATCH_COUNT matches for [\$FZF_QUERY] \" \
        fi \
        ' \
    --bind 'focus:transform-preview-label:[[ -n {} ]] && printf \" Previewing [%s] \" {}' \
    --bind 'focus:+transform-header:file --brief {} || echo \"No file selected\"' \
    --bind 'ctrl-r:change-list-label( Reloading the list )+reload(sleep 2; git ls-files)' \
    --bind 'ctrl-/:change-preview-window(down|hidden|)' \
    --bind 'ctrl-d:preview-half-page-down' \
    --bind 'ctrl-u:preview-half-page-up' \
    --bind 'ctrl-s:toggle-sort' \
    --bind 'ctrl-j:preview-down' \
    --bind 'ctrl-k:preview-up' \
    --bind 'ctrl-b:preview-bottom' \
    --bind 'ctrl-n:preview-top'"
unset _FZF_TMUX_OPT _FZF_STYLE_OPT






export FD_EXCLUDE="-E __pycache__ -E .git" # ignore more
export BFS_EXCLUDE='! \( -name .git -prune \) ! \( -name  __pycache__ -prune \) ! \( -name .venv -prune \) ! \( -name .mypy_cache -prune \)'

if type -p bfs >/dev/null; then
    export FZF_DEFAULT_FILES_COMMAND="bfs -x -color $BFS_EXCLUDE -type f"
    export FZF_DEFAULT_DIR_COMMAND="bfs -x -color $BFS_EXCLUDE -type d"
else
    export FZF_DEFAULT_FILES_COMMAND="fd --color='always' --type f --hidden --follow --no-ignore $FD_EXCLUDE"
    export FZF_DEFAULT_DIR_COMMAND="fd --color='always' --type d --hidden --follow --no-ignore $FD_EXCLUDE"
fi


export FZF_DEFAULT_GLOBAL_DIRS="$HOME"


FZF_CTRL_T_LOCAL_GLOBAL_TOGGLE="
  if [[ {fzf:prompt} =~ \"Files\(~\)\" ]]; then
    echo \"change-prompt(Files(.)> )+reload($FZF_DEFAULT_FILES_COMMAND .)\"
  elif [[ {fzf:prompt} =~ \"Files\(.\)\" ]]; then
    echo \"change-prompt(Files(~)> )+reload($FZF_DEFAULT_FILES_COMMAND . $FZF_DEFAULT_GLOBAL_DIRS)\"
  elif [[ {fzf:prompt} =~ \"Dirs\(~\)\" ]]; then
    echo \"change-prompt(Dirs(.)> )+reload($FZF_DEFAULT_DIR_COMMAND .)\"
  elif [[ {fzf:prompt} =~ \"Dirs\(.\)\" ]]; then
    echo \"change-prompt(Dirs(~)> )+reload($FZF_DEFAULT_DIR_COMMAND . $FZF_DEFAULT_GLOBAL_DIRS)\"
  fi
"

FZF_CTRL_T_FILES_DIRS_TOGGLE="
  if [[ {fzf:prompt} =~ \"Files\(~\)\" ]]; then
    echo \"change-prompt(Dirs(~)> )+reload($FZF_DEFAULT_DIR_COMMAND . $FZF_DEFAULT_GLOBAL_DIRS)\"
  elif [[ {fzf:prompt} =~ \"Files\(.\)\" ]]; then
    echo \"change-prompt(Dirs(.)> )+reload($FZF_DEFAULT_DIR_COMMAND .)\"
  elif [[ {fzf:prompt} =~ \"Dirs\(~\)\" ]]; then
    echo \"change-prompt(Files(~)> )+reload($FZF_DEFAULT_FILES_COMMAND . $FZF_DEFAULT_GLOBAL_DIRS)\"
  elif [[ {fzf:prompt} =~ \"Dirs\(.\)\" ]]; then
    echo \"change-prompt(Files(.)> )+reload($FZF_DEFAULT_FILES_COMMAND .)\"
  fi
"

export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_FILES_COMMAND ."
export FZF_CTRL_T_OPTS="--preview 'fzf-preview {}' --prompt 'Files(.)> ' \
--bind 'ctrl-t:transform:$FZF_CTRL_T_LOCAL_GLOBAL_TOGGLE' \
--bind 'ctrl-r:transform:$FZF_CTRL_T_FILES_DIRS_TOGGLE' \
--bind 'ctrl-f:execute:hx {} >/dev/tty' \
--keep-right"

export FZF_CTRL_R_OPTS="
  --style default \
  --preview 'echo {2..} | bat --color=always -pl sh' \
  --preview-window up:5:nowrap \
  --bind 'result:' \
  --bind 'focus:' \
  --bind 'focus:+transform-preview-label:' \
  --bind 'focus:+transform-header:' \
  --bind 'ctrl-/:toggle-preview' \
  --bind 'ctrl-v:execute(echo {2..} | view - > /dev/tty)' \
  --bind 'ctrl-t:track+clear-query' \
  --bind 'ctrl-y:execute-silent(echo -n {2..} | pbcopy)+abort'"

# Apply Catppuccin colors (FZF_CATPPUCCIN_COLORS is set by shell-colors.sh)
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS $FZF_CATPPUCCIN_COLORS"
