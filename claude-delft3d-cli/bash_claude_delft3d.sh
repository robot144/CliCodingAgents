#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$script_dir"

image="$repo_root/claude-delft3d-cli.sif"
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
  echo "Build it first with: ./build_claude.sh" >&2
  exit 1
fi

mkdir -p "$home_dir_host"

if [[ ! -f "$bind_path/CLAUDE.md" ]]; then
  echo "Copying /opt/CLAUDE.md from container to current directory..."
  apptainer exec "$image" cat /opt/CLAUDE.md > "$bind_path/CLAUDE.md" || true
fi

echo "Mounting current folder into container: $bind_path to /workspace"
echo "Using host home: $home_dir_host"
echo "Container home target: $home_dir_container"
echo "Starting shell in container: $image"
echo "Use 'exit' to leave the container shell."
echo "Type 'claude' to start Claude Code inside the container."
echo "You will be prompted to authenticate on first use."
echo "Python environment manager 'pixi' is available (https://pixi.sh)."
# NVIDIA GPU passthrough: add --nv if driver is available
gpu_args=()
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
  echo "NVIDIA GPU detected — enabling GPU passthrough (--nv)."
  gpu_args+=(--nv)
fi

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
  --pwd /workspace \
  "${gpu_args[@]}" \
  "${x11_args[@]}" \
  "$image"
