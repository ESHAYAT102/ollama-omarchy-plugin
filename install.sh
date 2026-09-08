#!/usr/bin/env bash
set -euo pipefail

plugin_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
source_file="$plugin_dir/bin/ollama"
destination="$HOME/.local/bin/ollama"

mkdir -p "$(dirname -- "$destination")"
if [[ -e "$destination" ]] && ! grep -q '^# esh\.ollama CLI wrapper$' "$destination"; then
  printf 'Refusing to replace existing file: %s\n' "$destination" >&2
  exit 1
fi

install -m 0755 "$source_file" "$destination"
printf 'Installed the esh.ollama CLI wrapper at %s\n' "$destination"
printf 'Ensure ~/.local/bin appears before /usr/bin in PATH, then open a new terminal.\n'
