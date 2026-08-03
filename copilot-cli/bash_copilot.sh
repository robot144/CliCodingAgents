#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$script_dir"

image="$repo_root/copilot-cli.sif"
bind_path="$(pwd -P)"
# Use a per-working-directory home so each session is isolated
home_dir_host="$bind_path/.apptainer-home"
home_dir_container="$home_dir_host"
bootstrap_sentinel_host="$home_dir_host/bootstrap-finished"
additional_bind_args=()

usage() {
  cat <<'EOF'
Usage: bash_copilot.sh [--bind PATH|HOST:CONTAINER] [--bind-ro PATH|HOST:CONTAINER] \
                       [--bind-file FILE] [--bind-file-ro FILE]

Bind options:
  --bind         Add a read-write bind mount.
  --bind-ro      Add a read-only bind mount.
  --bind-file    Read additional read-write bind specs from a file.
  --bind-file-ro Read additional read-only bind specs from a file.

When only one absolute host path is given, it is mounted at the same path inside
the container.
EOF
}

normalize_bind_spec() {
  local raw_spec="$1"
  local base_dir="$2"
  local host_part
  local container_part

  if [[ "$raw_spec" == *:* ]]; then
    host_part="${raw_spec%%:*}"
    container_part="${raw_spec#*:}"
  else
    host_part="$raw_spec"
    container_part="$raw_spec"
  fi

  if [[ -z "$host_part" || -z "$container_part" ]]; then
    echo "Invalid bind spec: $raw_spec" >&2
    exit 1
  fi

  if [[ "$host_part" != /* ]]; then
    host_part="${base_dir}/${host_part}"
  fi

  if [[ "$container_part" != /* ]]; then
    echo "Bind container path must be absolute: $container_part" >&2
    exit 1
  fi

  if [[ ! -e "$host_part" ]]; then
    echo "Bind host path does not exist: $host_part" >&2
    exit 1
  fi

  printf '%s:%s' "$host_part" "$container_part"
}

add_bind_arg() {
  local option_name="$1"
  local raw_spec="$2"
  local base_dir="$3"
  local normalized_spec

  normalized_spec="$(normalize_bind_spec "$raw_spec" "$base_dir")"
  additional_bind_args+=("$option_name" "$normalized_spec")
}

load_bind_file() {
  local option_name="$1"
  local bind_file="$2"
  local bind_file_dir
  local line
  local trimmed

  if [[ ! -f "$bind_file" ]]; then
    echo "Bind file not found: $bind_file" >&2
    exit 1
  fi

  bind_file_dir="$(cd "$(dirname "$bind_file")" && pwd -P)"

  while IFS= read -r line || [[ -n "$line" ]]; do
    trimmed="${line#"${line%%[![:space:]]*}"}"
    trimmed="${trimmed%"${trimmed##*[![:space:]]}"}"

    if [[ -z "$trimmed" || "$trimmed" == \#* ]]; then
      continue
    fi

    if [[ "$trimmed" == *:* ]]; then
      local host_part="${trimmed%%:*}"
      local container_part="${trimmed#*:}"
      if [[ "$host_part" != /* ]]; then
        host_part="${bind_file_dir}/${host_part}"
      fi
      add_bind_arg "$option_name" "${host_part}:${container_part}" "$bind_file_dir"
    else
      add_bind_arg "$option_name" "$trimmed" "$bind_file_dir"
    fi
  done < "$bind_file"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bind|--bind-ro|--bind-file|--bind-file-ro)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for $1" >&2
        usage >&2
        exit 1
      fi
      case "$1" in
        --bind|--bind-ro)
          add_bind_arg "$1" "$2" "$bind_path"
          ;;
        --bind-file)
          load_bind_file "--bind" "$2"
          ;;
        --bind-file-ro)
          load_bind_file "--bind-ro" "$2"
          ;;
      esac
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

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
  echo "Build it first with: ./build_copilot.sh" >&2
  exit 1
fi

mkdir -p "$home_dir_host"

echo "Mounting current folder into container at the same path: $bind_path"
echo "Using host home: $home_dir_host"
echo "Container home target: $home_dir_container"
echo "Starting shell in container: $image"
echo "Use 'exit' to leave the container shell."
echo "Type 'copilot' to start the Copilot CLI inside the container."
echo "Copilot commands start with a /, for example: /help"
echo "Use '/login' to authenticate with GitHub Copilot if needed."
echo "and /model to switch between available models."
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

exec apptainer exec --no-home \
  --home "$home_dir_container" \
  --bind "$bind_path:$bind_path" \
  --bind "$home_dir_host:$home_dir_container" \
  "${additional_bind_args[@]}" \
  --pwd "$bind_path" \
  "${gpu_args[@]}" \
  "${x11_args[@]}" \
  "$image" \
  /bin/bash -lc "if [[ ! -f \"$bootstrap_sentinel_host\" ]]; then /opt/bootstrap-workspace.sh; fi; exec /bin/bash -i"
