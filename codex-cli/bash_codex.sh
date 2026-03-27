#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$script_dir"

image="$repo_root/codex-cli.sif"
bind_path="$PWD"
home_dir_host="${CODEX_APPTAINER_HOME:-$HOME/.codex-apptainer-home}"
home_dir_container="/workspace/.apptainer-home"

if ! command -v apptainer >/dev/null 2>&1; then
  echo "apptainer is not installed or not on PATH" >&2
  exit 1
fi

if [[ ! -d "$bind_path" ]]; then
  echo "Bind path is not a directory: $bind_path" >&2
  exit 1
fi

if [[ ! -f "$image" ]]; then
  echo "Image not found: $image" >&2
  echo "Build it first with: ./build_codex.sh" >&2
  exit 1
fi

mkdir -p "$home_dir_host"

echo "Mounting current folder into container: $bind_path to /workspace"
echo "Using host home: $home_dir_host"
echo "Container home target: $home_dir_container"
echo "Starting shell in container: $image"
echo "Use 'exit' to leave the container shell."
echo "Type 'codex' to start the OpenAI Codex CLI inside the container."
echo "The first time you run it, authenticate with your ChatGPT account or an API key."
exec apptainer shell --no-home \
  --home "$home_dir_container" \
  --bind "$bind_path:/workspace" \
  --bind "$home_dir_host:$home_dir_container" \
  --pwd /workspace \
  "$image"
