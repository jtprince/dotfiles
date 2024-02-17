# dotfiles

## bin

Create a softlink your bin dir to your home dir:

```bash
cd && ln -sf ~/dotfiles/bin
```

Ensure that you've include bin in your path some where. For example, in
.profile include a line like this:

```bash
export PATH=$HOME/bin:$HOME/.local/bin:$PATH
```

## config

Assuming your bin folder is setup and is in your path:

```
dotfiles-configure --dry
dotfiles-configure
```

The command is idempotent with regards to the results, so you can rerun as
soon as you update it with no negative consequences.

## scripts

These are scripts that might useful again but are more one-off, so do not
belong on the PATH.
