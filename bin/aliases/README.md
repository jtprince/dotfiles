# Introduction

We want to be able to start certain programs as quickly and easily using tofi
(a dmenu like program) as we do on the command line. tofi includes all the
executables on a path, but it does *not* include aliases (see [my
issue](https://github.com/philj56/tofi/issues/110)).

# Potential Solutions

I see two ways to remedy lack of aliases for tofi.

## Add aliases to tofi arguments

#The first is to run a
script to collect the aliases from some file or via the bash built-in `alias`.
Here's an example that works:

```
#!/bin/bash

ALIASES="$HOME/.config/alias"

# Extract aliases and format them
aliases=$(grep '^alias ' "$ALIASES" | sed "s/alias //;s/=.*//")

# Combine aliases with executables in the PATH
commands=$(echo "$aliases"; compgen -c)

# Use dmenu/rofi/wofi to select a command
selected=$(echo "$commands" | sort -u | tofi)

# Check if the selected command is an alias
if grep -q "^alias $selected=" "$ALIASES"; then
    # Extract the command for the alias
    command_to_run=$(grep "^alias $selected=" "$ALIASES" | sed "s/^alias $selected=//;s/'//g")
else
    # If not an alias, the command is executed directly
    command_to_run=$selected
fi

# Execute the command
bash -i -c "$command_to_run"
```

The problem is that with this formulation we then do not get tofi's built in
history biasing (which is really nice). So, until we either implement history
ourselves OR we figure out a way to include it with tofi after adding in
aliases, then this isn't a great solution.

## Add aliases as scripts

The script is three lines:

* a shebang line (best to use zsh? bash??)
* a directive to source the alias file
* the alias.

If you're reading this README, that's what we're doing for now.
