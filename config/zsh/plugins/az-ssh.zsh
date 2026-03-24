typeset -gA _az_vm_meta
_az_vm_meta[johnprince-dev]='data-science-dev-ncus-rg-01|sub-enveda-data-dev-01'
_az_vm_meta[johnprince-highmem]='data-science-dev-ncus-rg-01|sub-enveda-data-dev-01'

_az_ssh_cfg_dir="${HOME}/.ssh/azure-ephemeral"
_az_ssh_keepalive_interval="${AZ_SSH_SERVER_ALIVE_INTERVAL:-30}"
_az_ssh_keepalive_countmax="${AZ_SSH_SERVER_ALIVE_COUNT_MAX:-6}"
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

_az_cfg_is_fresh() {
  local cfg="$1"
  [[ -f "$cfg" ]] || return 1
  local now mtime max_age=300
  now=$(date +%s)
  mtime=$(stat -f %m "$cfg" 2>/dev/null || stat -c %Y "$cfg" 2>/dev/null) || return 1
  (( now - mtime < max_age ))
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
  local meta="${_az_vm_meta[$host]}"
  [[ -z "$meta" ]] && return 1

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

  [[ -n "${_az_vm_meta[$host]}" ]] || {
    printf 'az-ssh: unknown Azure host: %s\n' "$host" >&2
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

  [[ -n "${_az_vm_meta[$host]}" ]] || {
    printf 'az-scp: unknown Azure host: %s\n' "$host" >&2
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

autoload -Uz compinit
compinit
compdef _ssh az-ssh
compdef _scp az-scp
