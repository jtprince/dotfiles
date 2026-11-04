# zsh completion for the az-ssh and az-scp scripts (bin/work/az-ssh, bin/work/az-scp).
# The scripts themselves are standalone; this file only adds tab completion.

# The VM index that az-ssh maintains (name<TAB>resource-group<TAB>subscription).
_az_vm_index_file="${HOME}/.ssh/azure-ephemeral/.vm-index.tsv"

# Host completion for az-ssh/az-scp comes from the discovery index -- these VMs
# are in neither ~/.ssh/config nor known_hosts. The path is _ssh_hosts ->
# _combination -> _hosts, and _hosts honours the `hosts` style set below, so
# scp keeps its host: suffix and remote path completion. Deliberately replaces
# the known_hosts list: a non-Azure host is rejected by these wrappers anyway.
# Assigns `reply` for `zstyle -e`, so it must not declare it local.
_az_vm_complete_hosts() {
  reply=()
  if [[ -f "$_az_vm_index_file" ]]; then
    reply=(${${(f)"$(<"$_az_vm_index_file")"}%%$'\t'*})
  fi
  reply=(${(u)${reply:#}})
}

# `-e` re-evaluates per completion, so a rebuilt index needs no shell reload.
zstyle -e ':completion:*:(az-ssh|az-scp):*' hosts '_az_vm_complete_hosts'

# Remote path completion (`az-scp host:<TAB>`) goes through _remote_files, which
# shells out to plain `ssh` -- no generated config for these VMs, so it silently
# returns nothing. Re-dispatch it through az-ssh instead.
#
# _remote_files passes the glob as a backslash-escaped `\*` that only survives
# because _call_program evals its argv, so the replacement has to keep that
# eval: hence the style's `-prefix` form, which prepends to the eval'd command
# rather than replacing it. The shim then drops the leading `ssh`.
_az_scp_remote_shim() {
  shift  # discard the literal `ssh` that _remote_files passes as the command

  # That same eval also expands a leading `~` against the *local* home, so a
  # remote `~/...` is sent as /Users/<me>/... and matches nothing. When the word
  # being completed really did start with `~`, put it back and let the remote
  # shell expand it. Guarding on $PREFIX keeps genuine local-looking remote
  # paths untouched.
  if [[ $PREFIX == '~/'* && ${argv[-1]} == ${HOME}/* ]]; then
    argv[-1]="~/${argv[-1]#${HOME}/}"
  fi

  az-ssh "$@"
}
zstyle ':completion:*:az-scp:*:files' command '-_az_scp_remote_shim'

# compinit is centralized in sheldon plugins.toml `__init_completion`. (Standalone
# users: source this file after compinit.)
# _ssh dispatches entirely on $service, so both need an explicit service name --
# a bare `compdef _ssh az-ssh` matches no branch and completes nothing. There is
# no _scp function either; scp completion is a service inside _ssh.
compdef _ssh az-ssh=ssh
compdef _ssh az-scp=scp
