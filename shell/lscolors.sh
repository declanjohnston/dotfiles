# Catppuccin Macchiato LS_COLORS via vivid
# Falls back to static colors if vivid is not installed

if command -v vivid &> /dev/null; then
    export LS_COLORS="$(vivid generate catppuccin-mocha)"
else
    # Fallback: basic Catppuccin-inspired colors using 256-color palette
    LS_COLORS='di=38;5;111:ln=38;5;183:so=38;5;197:pi=38;5;222:ex=38;5;167;1:bd=38;5;222;48;5;236:cd=38;5;222;48;5;236:su=38;5;167;48;5;236:sg=38;5;167;48;5;236:tw=38;5;111;48;5;236:ow=38;5;111:*.tar=38;5;183:*.tgz=38;5;183:*.zip=38;5;183:*.gz=38;5;183:*.bz2=38;5;183:*.xz=38;5;183:*.7z=38;5;183:*.rar=38;5;183:*.jpg=38;5;208:*.jpeg=38;5;208:*.png=38;5;208:*.gif=38;5;208:*.svg=38;5;208:*.webp=38;5;208:*.mp3=38;5;208:*.mp4=38;5;208:*.mkv=38;5;208:*.avi=38;5;208:*.mov=38;5;208:*.pdf=38;5;167:*.doc=38;5;167:*.docx=38;5;167:*.xls=38;5;150:*.xlsx=38;5;150:*.py=38;5;150:*.js=38;5;150:*.ts=38;5;150:*.rs=38;5;150:*.go=38;5;150:*.rb=38;5;150:*.java=38;5;150:*.c=38;5;150:*.cpp=38;5;150:*.h=38;5;150:*.hpp=38;5;150:*.sh=38;5;150:*.zsh=38;5;150:*.bash=38;5;150:*.md=38;5;222:*.json=38;5;222:*.yaml=38;5;222:*.yml=38;5;222:*.toml=38;5;222:*.xml=38;5;222:*.html=38;5;222:*.css=38;5;139:*.scss=38;5;139:*.log=38;5;102:*.bak=38;5;102:*.tmp=38;5;102:*.swp=38;5;102:*~=38;5;102:*.git=38;5;102:*.gitignore=38;5;102'
    export LS_COLORS
fi
