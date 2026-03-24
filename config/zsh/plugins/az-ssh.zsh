typeset -gA _az_vm_meta
_az_vm_meta[johnprince-dev]='data-science-dev-ncus-rg-01|sub-enveda-data-dev-01'
_az_vm_meta[johnprince-highmem]='data-science-dev-ncus-rg-01|sub-enveda-data-dev-01'

_az_ssh_cfg_dir="${HOME}/.ssh/azure-ephemeral"
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

_az_ensure_cfg_alias() {
  local logical_host="$1"
  local cfg="$2"
  local tmp="${cfg}.tmp"

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

  if ! _az_cfg_is_fresh "$cfg"; then
    az ssh config \
      --name "$host" \
      --resource-group "$rg" \
      --subscription "$sub" \
      --prefer-private-ip \
      --overwrite \
      --yes \
      --file "$cfg" >/dev/null || return 1
  fi

  _az_ensure_cfg_alias "$host" "$cfg" || return 1
  print -r -- "$cfg"
}

az-ssh() {
  local host meta rg sub
  local -a passthrough
  host="$(_az_extract_ssh_host "$@")" || {
    printf 'az-ssh: could not determine host\n' >&2
    return 2
  }

  meta="${_az_vm_meta[$host]}"
  [[ -n "$meta" ]] || {
    printf 'az-ssh: unknown Azure host: %s\n' "$host" >&2
    return 2
  }

  rg="${meta%%|*}"
  sub="${meta#*|}"
  passthrough=("${(@f)$(_az_strip_ssh_host "$@")}")

  if (( ${#passthrough[@]} > 0 )); then
    command az ssh vm \
      --name "$host" \
      --resource-group "$rg" \
      --subscription "$sub" \
      --prefer-private-ip \
      --yes \
      -- "${passthrough[@]}"
  else
    command az ssh vm \
      --name "$host" \
      --resource-group "$rg" \
      --subscription "$sub" \
      --prefer-private-ip \
      --yes
  fi
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
  command scp -o IdentitiesOnly=yes -F "$cfg" "$@"
}

autoload -Uz compinit
compinit
compdef _ssh az-ssh
compdef _scp az-scp
