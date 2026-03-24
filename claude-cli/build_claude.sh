#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

def_file="$script_dir/Apptainer.def"
output_image="$script_dir/claude-cli.sif"

if ! command -v apptainer >/dev/null 2>&1; then
  echo "apptainer is not installed or not on PATH" >&2
  exit 1
fi

if [[ ! -f "$def_file" ]]; then
  echo "Definition file not found: $def_file" >&2
  exit 1
fi

apptainer build "$output_image" "$def_file"

printf 'Built image: %s\n' "$output_image"
