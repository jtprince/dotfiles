# Manual overrides, keyed by VM name:
#   _az_vm_meta[my-vm]='resource-group|subscription'
# Normally empty -- hosts resolve from the discovery index below.
typeset -gA _az_vm_meta
# Per-shell memo of index hits, so repeat lookups cost nothing.
typeset -gA _az_vm_cache

_az_ssh_cfg_dir="${HOME}/.ssh/azure-ephemeral"
_az_vm_index_file="${_az_ssh_cfg_dir}/.vm-index.tsv"
# Rebuild the index once it is older than this.
_az_vm_index_ttl="${AZ_SSH_VM_INDEX_TTL:-86400}"
# Floor between rebuilds triggered by an unknown host, so typos stay cheap.
_az_vm_index_miss_ttl="${AZ_SSH_VM_INDEX_MISS_TTL:-60}"
typeset -ga _az_ssh_subscriptions
_az_ssh_subscriptions=(${=${AZ_SSH_SUBSCRIPTIONS:-sub-enveda-data-dev-01}})
# Defaults target ~2 hours before the client gives up on an otherwise idle session.
_az_ssh_keepalive_interval="${AZ_SSH_SERVER_ALIVE_INTERVAL:-60}"
_az_ssh_keepalive_countmax="${AZ_SSH_SERVER_ALIVE_COUNT_MAX:-120}"
mkdir -p "${_az_ssh_cfg_dir}"

_az_extract_ssh_host() {
  local prev="" arg
  for arg in "$@"; do
    case "$prev" in
      -b|-c|-D|-E|-e|-F|-I|-i|-J|-L|-l|-m|-O|-o|-p|-Q|-R|-S|-W|-w)
        prev=""
        continue
        ;;
    esac
    case "$arg" in
      --) prev=""; continue ;;
      -*) prev="$arg"; continue ;;
      *)
        [[ "$arg" == *"@"* ]] && print -r -- "${arg#*@}" || print -r -- "$arg"
        return 0
        ;;
    esac
  done
  return 1
}

_az_strip_ssh_host() {
  local prev="" arg host_removed=0
  local -a remaining=()

  for arg in "$@"; do
    case "$prev" in
      -b|-c|-D|-E|-e|-F|-I|-i|-J|-L|-l|-m|-O|-o|-p|-Q|-R|-S|-W|-w)
        remaining+=("$arg")
        prev=""
        continue
        ;;
    esac

    case "$arg" in
      --)
        prev=""
        continue
        ;;
      -*)
        remaining+=("$arg")
        prev="$arg"
        continue
        ;;
    esac

    if (( ! host_removed )); then
      host_removed=1
      continue
    fi

    remaining+=("$arg")
  done

  printf '%s\n' "${remaining[@]}"
}

_az_extract_scp_host() {
  local arg hostpart
  for arg in "$@"; do
    case "$arg" in
      -*) continue ;;
      *:*)
        hostpart="${arg%%:*}"
        if [[ "$hostpart" != */* && -n "$hostpart" ]]; then
          [[ "$hostpart" == *"@"* ]] && print -r -- "${hostpart#*@}" || print -r -- "$hostpart"
          return 0
        fi
        ;;
    esac
  done
  return 1
}

_az_file_is_fresh() {
  local file="$1" max_age="$2"
  [[ -f "$file" ]] || return 1
  local now mtime
  now=$(date +%s)
  mtime=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null) || return 1
  (( now - mtime < max_age ))
}

_az_cfg_is_fresh() {
  _az_file_is_fresh "$1" 300
}

# Rebuild the name -> resource-group|subscription index from Azure.
_az_vm_index_refresh() {
  local sub out tmp rc=0
  mkdir -p "${_az_ssh_cfg_dir}" 2>/dev/null || return 1
  tmp="$(mktemp "${_az_vm_index_file}.XXXXXX")" || return 1

  for sub in "${_az_ssh_subscriptions[@]}"; do
    out="$(
      az vm list \
        --subscription "$sub" \
        --only-show-errors \
        --query '[].[name,resourceGroup]' \
        -o tsv 2>&1
    )" || {
      printf 'az-ssh: vm index refresh failed for %s: %s\n' "$sub" "$out" >&2
      rc=1
      continue
    }
    # Lower-case the resource group so it matches the layout `az ssh config`
    # uses under az_ssh_config/, which _az_harden_cfg_permissions relies on.
    # `sub` is an awk builtin, so the variable has to be named something else.
    print -r -- "$out" \
      | awk -F'\t' -v s="$sub" 'NF >= 2 { print $1 "\t" tolower($2) "\t" s }' >> "$tmp"
  done

  # Never clobber a usable index with an empty one.
  if [[ ! -s "$tmp" ]]; then
    rm -f "$tmp"
    return 1
  fi

  mv "$tmp" "$_az_vm_index_file" || { rm -f "$tmp"; return 1; }
  chmod 600 "$_az_vm_index_file" 2>/dev/null || true
  return $rc
}

_az_vm_index_get() {
  [[ -f "$_az_vm_index_file" ]] || return 1
  awk -F'\t' -v h="$1" '$1 == h { print $2 "|" $3; exit }' "$_az_vm_index_file"
}

# Print `resource-group|subscription` for a VM name, refreshing the index as
# needed. Overrides win, then the per-shell memo, then the index.
_az_vm_lookup() {
  local host="$1" meta
  [[ -n "$host" ]] || return 1

  if [[ -n "${_az_vm_meta[$host]}" ]]; then
    print -r -- "${_az_vm_meta[$host]}"
    return 0
  fi
  if [[ -n "${_az_vm_cache[$host]}" ]]; then
    print -r -- "${_az_vm_cache[$host]}"
    return 0
  fi

  local refreshed=0
  if ! _az_file_is_fresh "$_az_vm_index_file" "$_az_vm_index_ttl"; then
    _az_vm_index_refresh || true
    refreshed=1
  fi
  meta="$(_az_vm_index_get "$host")"

  # Fresh index, still a miss: the VM may have been created since the last
  # rebuild. Retry once, rate-limited so typos don't cost an az round trip.
  if [[ -z "$meta" ]] && (( ! refreshed )) \
    && ! _az_file_is_fresh "$_az_vm_index_file" "$_az_vm_index_miss_ttl"; then
    _az_vm_index_refresh || true
    meta="$(_az_vm_index_get "$host")"
  fi

  [[ -n "$meta" ]] || return 1
  _az_vm_cache[$host]="$meta"
  print -r -- "$meta"
}

_az_vm_suggest() {
  local host="$1" stem matches
  [[ -f "$_az_vm_index_file" ]] || return 0
  stem="${host%%-*}"
  matches="$(
    awk -F'\t' -v s="$stem" 'length(s) >= 3 && index($1, s) { print "  " $1 }' \
      "$_az_vm_index_file" 2>/dev/null | sort -u | head -10
  )"
  [[ -n "$matches" ]] || return 0
  print -r -- 'did you mean:'
  print -r -- "$matches"
}

_az_harden_cfg_permissions() {
  local cfg="$1"
  local rg="$2"
  local host="$3"
  local cfg_dir key_root key_dir

  [[ -f "$cfg" ]] || return 1

  cfg_dir="${cfg:h}"
  key_root="${cfg_dir}/az_ssh_config"
  key_dir="${key_root}/${rg}-${host}"

  chmod 700 "$cfg_dir" 2>/dev/null || return 1
  [[ -d "$key_root" ]] && chmod 700 "$key_root" 2>/dev/null || true

  if [[ -d "$key_dir" ]]; then
    chmod 700 "$key_dir" 2>/dev/null || return 1
    [[ -f "$key_dir/id_rsa" ]] && chmod 600 "$key_dir/id_rsa" 2>/dev/null || true
    [[ -f "$key_dir/id_rsa.pub" ]] && chmod 644 "$key_dir/id_rsa.pub" 2>/dev/null || true
    [[ -f "$key_dir/id_rsa.pub-aadcert.pub" ]] && chmod 644 "$key_dir/id_rsa.pub-aadcert.pub" 2>/dev/null || true
  fi

  chmod 600 "$cfg" 2>/dev/null || return 1
}

_az_ensure_cfg_alias() {
  local logical_host="$1"
  local cfg="$2"
  local tmp

  [[ -f "$cfg" ]] || return 1
  tmp="$(mktemp "${cfg}.tmp.XXXXXX")" || return 1

  awk -v logical_host="$logical_host" '
    BEGIN { updated = 0 }
    !updated && tolower($1) == "host" {
      found = 0
      for (i = 2; i <= NF; i++) {
        if ($i == logical_host) {
          found = 1
          break
        }
      }
      if (!found) {
        print $0 " " logical_host
      } else {
        print
      }
      updated = 1
      next
    }
    { print }
  ' "$cfg" > "$tmp" && mv "$tmp" "$cfg"
}

_az_refresh_cfg() {
  local host="$1"
  local meta
  meta="$(_az_vm_lookup "$host")" || return 1

  local rg="${meta%%|*}"
  local sub="${meta#*|}"
  local cfg="${_az_ssh_cfg_dir}/${host}.config"
  local key_dir="${_az_ssh_cfg_dir}/az_ssh_config/${rg}-${host}"
  local output

  if ! _az_cfg_is_fresh "$cfg"; then
    rm -rf "$key_dir" "$cfg"
    output="$(
      az ssh config \
        --name "$host" \
        --resource-group "$rg" \
        --subscription "$sub" \
        --prefer-private-ip \
        --overwrite \
        --yes \
        --only-show-errors \
        -o none \
        --file "$cfg" 2>&1
    )" || {
      [[ -n "$output" ]] && print -r -- "$output" >&2
      return 1
    }
  fi

  _az_ensure_cfg_alias "$host" "$cfg" || return 1
  _az_harden_cfg_permissions "$cfg" "$rg" "$host" || return 1
  print -r -- "$cfg"
}

az-ssh() {
  local host cfg
  host="$(_az_extract_ssh_host "$@")" || {
    printf 'az-ssh: could not determine host\n' >&2
    return 2
  }

  _az_vm_lookup "$host" >/dev/null || {
    printf 'az-ssh: unknown Azure host: %s\n' "$host" >&2
    _az_vm_suggest "$host" >&2
    return 2
  }

  cfg="$(_az_refresh_cfg "$host")" || return 1
  command ssh \
    -o IdentitiesOnly=yes \
    -o ServerAliveInterval="${_az_ssh_keepalive_interval}" \
    -o ServerAliveCountMax="${_az_ssh_keepalive_countmax}" \
    -F "$cfg" \
    "$@"
}

az-scp() {
  local host cfg
  host="$(_az_extract_scp_host "$@")" || {
    printf 'az-scp: could not determine remote host\n' >&2
    return 2
  }

  _az_vm_lookup "$host" >/dev/null || {
    printf 'az-scp: unknown Azure host: %s\n' "$host" >&2
    _az_vm_suggest "$host" >&2
    return 2
  }

  cfg="$(_az_refresh_cfg "$host")" || return 1
  command scp \
    -o IdentitiesOnly=yes \
    -o ServerAliveInterval="${_az_ssh_keepalive_interval}" \
    -o ServerAliveCountMax="${_az_ssh_keepalive_countmax}" \
    -F "$cfg" \
    "$@"
}

az-vm-index() {
  case "${1:-list}" in
    list|-l|--list) ;;
    -r|--refresh|refresh)
      _az_vm_index_refresh || {
        printf 'az-vm-index: refresh failed\n' >&2
        return 1
      }
      # Drop memoized hits so this shell picks up the rebuilt index.
      _az_vm_cache=()
      ;;
    -h|--help|help)
      print -r -- 'usage: az-vm-index [list|--refresh]'
      return 0
      ;;
    *)
      printf 'az-vm-index: unknown argument: %s\n' "$1" >&2
      return 2
      ;;
  esac

  [[ -f "$_az_vm_index_file" ]] || {
    printf 'az-vm-index: no index yet; run: az-vm-index --refresh\n' >&2
    return 1
  }
  awk -F'\t' '{ printf "%-40s %s\n", $1, $3 }' "$_az_vm_index_file" | sort
}

az-ssh-keepalive-help() {
  cat <<'EOF'
Recommended client defaults from dotfiles:

  AZ_SSH_SERVER_ALIVE_INTERVAL=60
  AZ_SSH_SERVER_ALIVE_COUNT_MAX=120

This gives the client roughly 2 hours before it gives up on a dead peer.

Recommended server-side /etc/ssh/sshd_config settings:

  ClientAliveInterval 60
  ClientAliveCountMax 120
  TCPKeepAlive yes

After updating sshd_config:

  sudo sshd -t
  sudo systemctl reload ssh

On Ubuntu 24 LTS, the OpenSSH server unit is typically `ssh`, not `sshd`.

If your distro uses a different service name:

  sudo systemctl reload sshd

Also check for non-sshd idle killers such as:

  - shell TMOUT
  - firewall / VPN idle timeout
  - cloud gateway / bastion timeout
EOF
}

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
  reply+=(${(k)_az_vm_meta})
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

# compinit is centralized in sheldon plugins.toml `__init_completion`.
# _ssh dispatches entirely on $service, so both need an explicit service name --
# a bare `compdef _ssh az-ssh` matches no branch and completes nothing. There is
# no _scp function either; scp completion is a service inside _ssh.
compdef _ssh az-ssh=ssh
compdef _ssh az-scp=scp
