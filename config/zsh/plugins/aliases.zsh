
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

## OWLET
export OWLET_CONFIGURATION="$HOME/owlet/ci-kit/bin/python/configuration"

alias owlet_black="black --config $OWLET_PYPROJECT_FILE"

alias owlet_test_all="python -m pytest --cov=./ --cov-branch --cov-config=$OWLET_COVERAGERC_FILE ./tests"
alias owlet_test_unit="python -m pytest --cov=./ --cov-branch --cov-config=$OWLET_COVERAGERC_FILE ./tests/unit"

alias owlet_isort="isort --sp $OWLET_PYPROJECT_FILE --src ."
alias owlet_lint_all="black --config $OWLET_PYPROJECT_FILE . && isort --sp $OWLET_PYPROJECT_FILE --src . **/*.py"
alias owlet_pylint="pylint --rcfile=$OWLET_PYPROJECT_FILE"

alias owlet_pylint_global="pylint --rcfile=${OWLET_CONFIGURATION}/pylint_global.toml"
alias owlet_pylint_global_oas="pylint --rcfile=${OWLET_CONFIGURATION}/pylint_global.toml --ignore=app/models"
alias owlet_pylint_models="pylint --rcfile=${OWLET_CONFIGURATION}/pylint_generated_models.toml"
alias owlet_pylint_tests="pylint --rcfile=${OWLET_CONFIGURATION}/pylint_tests.toml"

alias owlet_test_all="python -m pytest --cov=./ --cov-branch --cov-config=$OWLET_COVERAGERC_FILE ./tests"
alias owlet_test_unit="python -m pytest --cov=./ --cov-branch --cov-config=$OWLET_COVERAGERC_FILE ./tests/unit"

alias ipythonr="ipython --profile=autoreload"

# ruby
alias bundlei="bundle install --jobs=$NUM_CPU_CORES"
alias be="bundle exec"
alias markdown_lint="mdl"

# file system
alias ls="ls --color=auto"
alias dl='gvfs-trash'
alias sudoe="sudo -E"
alias mount_wd15="gvfs-mount smb://wd15/USB_Storage"

# nmatrix
alias atlasinclude="export C_INCLUDE_PATH=/usr/include/atlas && export CPLUS_INCLUDE_PATH=/usr/include/atlas"
alias includeatlas=atlasinclude

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

# latex
alias latexmk="latexmk -pdf -xelatex"

# grep and find
alias rgrep="grep -rs"
alias rgreptext="grep -rs --binary-files=without-match"
alias gg="git grep"
# -L follow links
# alias findit="find -L . -iname"

# git
alias gitcim="gitci"

# media
alias vlisten="vlc --intf rc -Vdummy"
#alias mp="mpd ; ncmpcpp ; mpd --kill"
alias mplayer="mplayer -ao pulse -af scaletempo"
alias mpv_bar="mpv --gpu-context=wayland --script-opts=osc-visibility=always"
alias mpv="mpv --gpu-context=wayland"
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

alias open="xdg-open"

alias conky="conky --config $HOME/.config/conky/conky.conf"

alias mp3encodinginfo="ffprobe -show_format 2>/dev/null"

alias prn="poetry run"

alias kubeon="export ZSH_KUBECTL_DISPLAY=true"
alias kubeoff="export ZSH_KUBECTL_DISPLAY=false"

## proxy to datascience instance
alias socksproxy="ssh-proxy alex-ec2-medium 8080"

alias condaenvs="conda info --env"

alias icat="kitty +kitten icat"

alias scocr="sc -b --dir /home/jtprince/screenshots --timestamp box --ocr"
