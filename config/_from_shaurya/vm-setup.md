# For a VM (linux)

### gh
```shell
# update
sudo apt update
sudo apt install gh
# if this doesn't work, there are extra steps you can do 
# to mess with gpg and adding the repository manually
# https://github.com/cli/cli/blob/trunk/docs/install_linux.md

# gh login stuff
gh auth login
gh auth setup-git

# config
git config user.email "your_email@abc.example"
git config user.name "your name"
```

### pyenv
```shell
# install libraries
sudo apt install curl git-core gcc make zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev libssl-dev \
    lzma liblzma-dev libbz2-dev libffi-dev
	
# install pyenv
curl https://pyenv.run | bash

# echo to zshrc
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc \
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc \
echo 'eval "$(pyenv init -)"' >> ~/.zshrc

# install pythons
pyenv install 3.9.20
pyenv install 3.10.15

# set global
pyenv global 3.9.20
```

### poetry
```shell
# install
curl -sSL https://install.python-poetry.org | python3 -

# config
poetry config virtualenvs.in-project true
poetry config virtualenvs.prefer-active-python true
```


### setting up az vm

```shell
# login
az login
az account set --subscription "sub-enveda-data-dev-01"

# ssh 
# this will generate two Host lines in your ~/.ssh/config file
az ssh config -n shaurya-dev-vm -g data-science-dev-ncus-rg-01 --prefer-private-ip -f ~/.ssh/config

# to actually use normal ssh, you have to generate a certificate but it expires in an hour. So instead, you can have it write to a random config file and regenerate the certificates before ssh'ing every time. But you can keep the entries in your original ssh config since the paths don't change only the underlying files do (via the function below)

refresh-azure-cert() {
    local vm_name="shaurya-dev-vm"
    local resource_group="data-science-dev-ncus-rg-01"
    local actual_name="${resource_group}-${vm_name}"
    local config_file="$HOME/.ssh/azure_vm_config"
    local ssh_key_dir="/Users/shaurya/.ssh/az_ssh_config/${resource_group}-${vm_name}"

    # Remove old config and keys if they exist
    rm -rf "$ssh_key_dir"
    rm -rf "$config_file"

    # Generate new SSH config without prompting for overwrites
    az ssh config --vm-name "$vm_name" --resource-group "$resource_group" --prefer-private-ip --file "$config_file"

    # Verify the config file was generated
    if [[ ! -f "$config_file" ]]; then
        echo "Error: SSH config file was not generated."
        return 1
    fi

    # Find `Host $actual_name` and replace it with `Host vm`
    awk -v actual_name="$actual_name" '
        $1 == "Host" && $2 == actual_name { $2 = "vm" }
        { print }
    ' "$config_file" > "${config_file}.tmp" && mv "${config_file}.tmp" "$config_file"
}

# now you can simply do
refresh-azure-cert

# and then
ssh vm
```