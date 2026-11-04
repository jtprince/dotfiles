# Command-line tools for an Azure VM

Four small scripts handle the routine work with an Azure development VM: signing in, starting and stopping the VM, opening a shell on it, and copying files to and from it. Each script is standalone and prints its usage with `--help`.

| Script | Purpose |
| --- | --- |
| [`az-login`](az-login) | Sign in to Azure if needed and select the dev or prod subscription. |
| [`vm-manage`](vm-manage) | List VMs, and start, stop, or check the status of one. |
| [`az-ssh`](az-ssh) | Open an ssh session to a VM by name, using your Entra ID (Azure AD) login. |
| [`az-scp`](az-scp) | Copy files to or from a VM by name. It requires `az-ssh` in the same directory or on `PATH`. |

`az-ssh` and `az-scp` need no ssh key management. On first use they look up the VM's resource group, ask `az ssh config` for a short-lived certificate, and then run the ordinary `ssh` or `scp`. All standard ssh and scp options therefore work.

## Prerequisites

1. Install the Azure CLI: <https://aka.ms/azcli> (on macOS, `brew install azure-cli`).
2. Install the CLI's ssh extension:

   ```sh
   az extension add --name ssh
   ```

3. Confirm that your account has the **Virtual Machine User Login** or **Virtual Machine Administrator Login** role on the VM. Whoever created the VM normally grants this role.
4. Connect to the company VPN. The scripts reach the VM on its private IP address.

`az-login` is a Python 3 script. The other three scripts need only bash, which macOS and Linux both provide.

## Installation

Download the scripts into a directory on `PATH`. This example uses `~/.local/bin`:

```sh
mkdir -p ~/.local/bin
cd ~/.local/bin
base=https://raw.githubusercontent.com/jtprince/dotfiles/main/bin/work
for f in az-login vm-manage az-ssh az-scp; do
  curl -fsSLO "$base/$f"
done
chmod +x az-login vm-manage az-ssh az-scp
```

If `~/.local/bin` is not yet on `PATH`, add this line to `~/.zshrc` (or `~/.bashrc`) and open a new terminal:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

## First-time setup

1. Sign in:

   ```sh
   az-login
   ```

2. Find the name of your VM:

   ```sh
   vm-manage list
   ```

3. Set that name as the default for `vm-manage` by adding this line to `~/.zshrc` (or `~/.bashrc`):

   ```sh
   export VM_MANAGE_DEFAULT_VM="your-vm-name"
   ```

## Daily use

Start the VM, connect to it, and stop it at the end of the day:

```sh
vm-manage start
az-ssh your-vm-name
vm-manage stop
```

A running VM incurs compute charges. `vm-manage stop` deallocates the VM, which ends those charges; the disk is kept. `vm-manage stop-only` powers the VM off but leaves it allocated and still billed.

Other common commands:

```sh
vm-manage status                              # power state and IP address
az-ssh your-vm-name nvidia-smi                # run one command and return
az-ssh your-vm-name -L 8888:localhost:8888    # forward a port, e.g. for Jupyter
az-scp results.csv your-vm-name:~/            # copy a file to the VM
az-scp -r your-vm-name:~/outputs ./outputs    # copy a directory from the VM
az-ssh --list                                 # VMs that az-ssh can reach
```

`vm-manage` accepts a VM name after the command (`vm-manage start other-vm`) to act on a VM other than the default.

## Troubleshooting

| Symptom | Action |
| --- | --- |
| `unknown Azure VM` for a newly created VM | Run `az-ssh --refresh`. The VM list is otherwise rebuilt once a day. |
| A message suggesting `az login`, or an `AADSTS` error | Run `az-login`. |
| `the Azure CLI ssh extension is not installed` | Run `az extension add --name ssh`. |
| The connection times out | Check the VPN connection and that `vm-manage status` reports `VM running`. |
| Idle sessions disconnect | Run `az-ssh --keepalive-help` for client and server keepalive settings. |
| `Permission denied` after the certificate step | Ask the VM owner to confirm the login role described under Prerequisites. |

## Optional settings

The scripts search the `sub-enveda-data-dev-01` subscription by default. Set `AZ_SSH_SUBSCRIPTIONS` (space-separated) and `VM_MANAGE_SUBSCRIPTION` to use others. `az-ssh --help` and `vm-manage --help` list the remaining environment variables.

zsh users can add tab completion of VM names and remote paths by downloading [`az-ssh.zsh`](../../config/zsh/plugins/az-ssh.zsh) and sourcing it in `~/.zshrc` after `compinit`.

`az-ssh` and `az-scp` store generated ssh configs, certificates, and the VM list in `~/.ssh/azure-ephemeral/`. Deleting that directory is safe; the scripts rebuild it on next use.
