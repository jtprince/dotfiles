# Zsh Completion Configuration
# Load completion fragments from a custom directory
fpath=($ZDOTDIR/completion $fpath)

# =============================
# Fix for missing _brew_services
# =============================
# Remove broken path to missing _brew_services completion
fpath=("${(@f)fpath:#*site-functions/_brew_services}")

# Load the modern completion system safely
autoload -Uz compinit
compinit -i  # '-i' ignores insecure or missing completions (like _brew_services)

# =============================
# Completion UI & Behavior Tweaks
# =============================

# Show a description next to each completion result
zstyle ':completion:*' auto-description 'specify: %d'

# Set the order of completers (how zsh tries to find completions)
# - _expand: expands aliases or parameters
# - _complete: standard completion
# - _correct: corrects small typos
# - _approximate: allows approximate matching
zstyle ':completion:*' completer _expand _complete _correct _approximate

# Format group headers when listing completion groups
zstyle ':completion:*' format 'Completing %d'

# Group results under group names (empty = automatic group names)
zstyle ':completion:*' group-name ''

# Enable a menu when there are 2 or more results to pick from
zstyle ':completion:*' menu select=2

# Colorize listings if dircolors is available (typically Linux)
if command -v dircolors &>/dev/null; then
  eval "$(dircolors -b)"
  zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
else
  # fallback: use built-in Zsh colors or skip
  zstyle ':completion:*' list-colors ''
fi

# Override with blank list-colors (optional—can be removed)
zstyle ':completion:*' list-colors ''

# Custom prompt shown when listing is triggered
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

# Match case-insensitively and allow some fuzzy matching
zstyle ':completion:*' matcher-list \
  '' \
  'm:{a-z}={A-Z}' \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=* l:|=*'

# Enable long-style menu selection (like a scrollable list)
zstyle ':completion:*' menu select=long

# Custom prompt when scrolling through long menu
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s

# Don't fall back to old-style compctl completions
zstyle ':completion:*' use-compctl false

# Print explanations for ambiguous completions
zstyle ':completion:*' verbose true

# =============================
# Special-case Completion Tweaks
# =============================

# Colorize the output of `kill` process completion (red for PIDs)
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'

# Use a custom `ps` command to list processes for `kill`
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# =============================
# Extras / Optional Features
# =============================

# Uncomment these for different menu behavior / case sensitivity
# setopt MENU_COMPLETE          # Autoselect from menu
# setopt no_list_ambiguous      # Don't list ambiguous items automatically
# CASE_SENSITIVE="false"        # Turn off case sensitivity (already handled above)
