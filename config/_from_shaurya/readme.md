# Recreate your dev environment

### install `brew`
`/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"`

### install `gh`
```shell
brew install gh # authenticate github with ssh
gh auth login
gh auth setup-git
cp .gitconfig ~/.
```

### install `iterm2`
```shell
brew install --cask iterm2
```

### install `oh-my-zsh`
```shell
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
cp .zshrc ~/.
```

### install `pyenv` and `xz`
```shell
brew install xz pyenv
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
pyenv install 3.9.20
pyenv install 3.10.15
pyenv global 3.9.20
```

### install window manager shortcuts
```shell
brew install rectangle
```

Then, open the app, go to settings and import the `RectangleConfig.json`


### install vscode
```shell 
brew install visual-studio-code
```
Then run settings sync from within

### install pipx
allows us to manage global python programs
```shell
brew install pipx
pipx ensurepath
```

### install poetry
```shell
pipx install poetry
poetry config virtualenvs.in-project true
poetry config virtualenvs.prefer-active-python true

# add plugin for auto installing pre-commit hooks
poetry self add poetry-pre-commit-plugin
```

### Copy vimrc
```shell
cp .vimrc ~/.
```

### awscli
```shell
brew install awscli
aws configure
```
Get keys and configure region.

### azure-cli
```shell
brew install azure-cli
az login
```
see [vm-setup.md](./vm-setup.md) for more details

### make dock appear on each monitor
```shell
defaults write com.apple.Dock appswitcher-all-displays -bool true
killall Dock
```

### adjust menubar whitespace settings to prevent programs from hiding behind the notch

Log out and back in after either set of commands

```shell
# Change the whitespace settings value
defaults -currentHost write -globalDomain NSStatusItemSelectionPadding -int 6
defaults -currentHost write -globalDomain NSStatusItemSpacing -int 6
```

```shell
# Revert to the original values
defaults -currentHost delete -globalDomain NSStatusItemSelectionPadding
defaults -currentHost delete -globalDomain NSStatusItemSpacing
```

### ssh
```shell
mkdir -p ~/.ssh
cp config ~/.ssh/.
```

# apps
[deeper](https://www.titanium-software.fr/en/deeper.html)
[unarchiver](https://theunarchiver.com)
