# dotfiles

## bin

Create a softlink your bin dir to your home dir:

```bash
cd && ln -sf ~/dotfiles/bin
```

Ensure that you've include bin in your path some where.  In my .profile file I
have this line:

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
