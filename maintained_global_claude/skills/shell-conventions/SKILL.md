---
name: shell-conventions
description: Use when writing or editing shell scripts (zsh/bash) or shell one-liners in files. Declan's conventions — zsh, gum, fd/rg/eza, small helpers, idempotent stages.
---

# Shell conventions


- always use gum for printing and styling shell scripts
- always use zsh over bash
- always use small bash helper functions if it makes the code more readable
- always prioritize readibility over everything else when making bash scripts
- always try to make the bash scripts idempotent, so they can be run multiple times safely. if the script contains multiple "stages", make each stage idempotent
- always use fd instead of find
- always use rg instead of grep
- always use `eza --tree` over `tree`

