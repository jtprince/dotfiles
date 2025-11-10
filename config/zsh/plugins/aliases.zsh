
# extraction & compression
alias utar='dtrx -n'
# compression (see ~/bin/tarz)
alias bunzip='bunzip2'
alias bzip='bzip2'

alias paru="arch-update-system"

# fuzzy find open
alias ff='fuzzy-file-open'
alias fzfo='fuzzy-file-open'

# like z but for files using fzf
alias zf='fuzzy-file-open-top-hit'
alias fz='fuzzy-file-open-top-hit'

# wine
alias wine32="export WINEARCH=win32; export WINEPREFIX=$HOME/.wine32; wine"
alias winecfg32="export WINEARCH=win32; export WINEPREFIX=$HOME/.wine32; winecfg"
alias wine64="export WINEARCH=win64; export WINEPREFIX=$HOME/.wine64; wine"
alias winecfg64="export WINEARCH=win64; export WINEPREFIX=$HOME/.wine64; winecfg"

# calendar
alias calendar="python -m calendar"

# pdf
alias pdf-cat='pdfunite'
alias pdf-combine='pdfunite'

# firejail
alias notrust="firejail --profile=$HOME/dotfiles/config/firejail/notrust.profile"

alias ipython="python3 -m IPython"
alias ipythonr="python3 -m IPython --profile=autoreload"

# file system
alias ls="ls --color=auto"
alias mount_wd15="gvfs-mount smb://wd15/USB_Storage"

# common spelling mistakes
alias sl="ls"
alias givm="gvim"
alias gvmi="gvim"
alias gimv="gvim"
alias gim="gvim"
alias gvi="gvim"

alias gti="git"
alias svim="sudo -E nvim"
alias snvim="sudo -E nvim"
alias mdkir="mkdir"
alias eixt="exit"

# edit arch installation file
CONFIG_DIR="$HOME/dotfiles/config"
DOTCONFIG_DIR="$HOME/.config"
ARCH_DIR="$CONFIG_DIR/arch"

alias archup="gvim $ARCH_DIR/installation.yaml"
alias archdir="pushd $ARCH_DIR"
alias archenvdir="pushd $HOME/Dropbox/env/os/arch"
alias aliasup="gvim $DOTCONFIG_DIR/alias"

# edit zshrc
alias zshup="gvim $CONFIG_DIR/zsh/.zshrc"
alias zshdir="pushd $CONFIG_DIR/zsh/"

alias nvimdir="pushd $DOTCONFIG_DIR/nvim/"
alias vimdir="nvimdir"

alias ncspotup="gvim $CONFIG_DIR/ncspot/config.toml"

alias swayup="gvim $CONFIG_DIR/sway/config"
alias swaydir="pushd $CONFIG_DIR/sway/"

alias alacrittyup="gvim $CONFIG_DIR/alacritty/alacritty.yml"
alias alacrittydir="pushd $CONFIG_DIR/alacritty/"

alias waybarup="gvim $CONFIG_DIR/waybar/config"
alias blueon="sudo systemctl restart bluetooth.service"

alias passup="gvim $HOME/Dropbox/env/passwds_logins/login_info.txt"
alias checkup="cd $HOME/work/REPORTING/checkins/"

# git
alias gitcim="gitci"

# media
alias vlisten="vlc --intf rc -Vdummy"
#alias mp="mpd ; ncmpcpp ; mpd --kill"
alias mplayer="mplayer -ao pulse -af scaletempo"
#alias youtube-dl="youtube-dl --prefer-ffmpeg"

# applications
GOOGLE_CHROME="google-chrome-stable"
# VIEB="vieb"
# alias viebwork="$VIEB"
alias chromepersonal="$GOOGLE_CHROME --user-data-dir=$HOME/.config/chrome-personal"
alias chromework="$GOOGLE_CHROME --user-data-dir=$HOME/.config/chrome-work"
# alias viebpersonal="$VIEB --user-data-dir=$HOME/.config/vieb-personal"
alias chromefaenrandir="$GOOGLE_CHROME --user-data-dir=$HOME/.config/chrome-faenrandir"
alias chromefaenrandir="$GOOGLE_CHROME --user-data-dir=$HOME/.config/chrome-faenrandir"
alias chromemelissa="$GOOGLE_CHROME --user-data-dir=$HOME/.config/chrome-melissa"
alias chromeproxy="$GOOGLE_CHROME --proxy-bypass-list=localhost,10.0.0.0/8,127.0.0.0/8,192.168.0.0/16 --proxy-server=socks5://localhost:8080 --user-data-dir=$HOME/.config/chrome-with-proxy"

alias libreoffice_to_pdf="libreoffice --headless --convert-to pdf"

# not using right now
alias tmux="tmux -f $HOME/.config/tmux/config"

# clear the screen (so no scrollback)
alias clearscreen="echo -ne '\033c'"

alias icat="kitten icat"

alias mp3encodinginfo="ffprobe -show_format 2>/dev/null"

alias icat="kitty +kitten icat"

alias scocr="sc -b --dir /home/jtprince/screenshots --timestamp box --ocr"

CHEATDIR="$HOME/dotfiles/config/cheat/cheatsheets/personal"

alias tree='tree -I "__pycache__|.git|.mypy_cache" --prune'

pip-install () {
  local py="$PYTHON_GLOBAL_VENV/bin/python"
  if [[ ! -x "$py" ]]; then
    echo "No python at: $py" >&2
    return 1
  fi
  command uv pip install --python "$py" "$@"
}
