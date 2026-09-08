#!/usr/bin/env bash
set -euo pipefail

destination="$HOME/.local/bin/ollama"
state_dir="$HOME/.config/omarchy/esh.ollama"

if [[ -f "$destination" ]] && grep -q '^# esh\.ollama CLI wrapper$' "$destination"; then
  rm -- "$destination"
  printf 'Removed %s\n' "$destination"
else
  printf 'No esh.ollama CLI wrapper found at %s\n' "$destination"
fi

if [[ "${1-}" == "--purge" ]]; then
  rm -f -- "$state_dir/active-endpoint" "$state_dir/remote-endpoint"
  rmdir --ignore-fail-on-non-empty "$state_dir" 2>/dev/null || true
  printf 'Removed saved endpoint settings.\n'
fi
