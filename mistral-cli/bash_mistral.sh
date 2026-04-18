#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$script_dir"

image="$repo_root/mistral-cli.sif"
bind_path="$PWD"
# Use a per-working-directory home so each session is isolated
home_dir_host="$bind_path/.apptainer-home"
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
  echo "Build it first with: ./build_mistral.sh" >&2
  exit 1
fi

if [[ -z "${MISTRAL_API_KEY:-}" ]]; then
  echo "Warning: MISTRAL_API_KEY is not set. Set it before running mistral-vibe." >&2
fi

mkdir -p "$home_dir_host"

echo "Mounting current folder into container: $bind_path to /workspace"
echo "Using host home: $home_dir_host"
echo "Container home target: $home_dir_container"
echo "Starting shell in container: $image"
echo "Use 'exit' to leave the container shell."
echo "Type 'vibe' to start the Mistral Vibe CLI inside the container."
# X11 forwarding: bind Xauthority into container if available
x11_args=()
if [[ -n "${DISPLAY:-}" ]]; then
  x11_args+=(--env "DISPLAY=$DISPLAY")
  if [[ -n "${XAUTHORITY:-}" && -f "$XAUTHORITY" ]]; then
    x11_args+=(--bind "$XAUTHORITY:/root/.Xauthority" --env "XAUTHORITY=/root/.Xauthority")
  fi
fi

exec apptainer shell --no-home \
  --home "$home_dir_container" \
  --bind "$bind_path:/workspace" \
  --bind "$home_dir_host:$home_dir_container" \
  --env "MISTRAL_API_KEY=${MISTRAL_API_KEY:-}" \
  --pwd /workspace \
  "${x11_args[@]}" \
  "$image"
