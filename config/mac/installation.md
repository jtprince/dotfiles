

# homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
---
.zprofile
---
eval "$(/opt/homebrew/bin/brew shellenv)"


brew install gh
gh auth login


gh repo clone jtprince/dotfiles


brew install alacritty
