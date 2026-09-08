#!/usr/bin/env bash
set -euo pipefail

endpoint="${1-}"
if [[ "$endpoint" != http://* && "$endpoint" != https://* ]]; then
  endpoint="http://$endpoint"
fi

url_pattern='^https?://[A-Za-z0-9._:-]+(/[A-Za-z0-9._~:/?#\[\]@!$&()*+,;=%-]*)?$'
if [[ ! "$endpoint" =~ $url_pattern ]]; then
  printf 'invalid Ollama endpoint: %s\n' "$endpoint" >&2
  exit 2
fi

state_dir="$HOME/.config/omarchy/esh.ollama"
mkdir -p "$state_dir"

write_atomic() {
  local destination="$1"
  local temporary
  temporary=$(mktemp "$state_dir/.endpoint.XXXXXX")
  trap 'rm -f "$temporary"' RETURN
  printf '%s\n' "$endpoint" > "$temporary"
  mv -f "$temporary" "$destination"
  trap - RETURN
}

write_atomic "$state_dir/active-endpoint"
if [[ "${2-}" == "remote" ]]; then
  write_atomic "$state_dir/remote-endpoint"
fi
