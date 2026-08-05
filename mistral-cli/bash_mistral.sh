#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$script_dir"

image="$repo_root/mistral-cli.sif"
image_ref="${MISTRAL_IMAGE_REF:-oras://ghcr.io/robot144/mistral-cli:latest}"
bind_path="$(pwd -P)"
home_dir_host="$bind_path/.apptainer-home"
home_dir_container="$home_dir_host"
bootstrap_sentinel_host="$home_dir_host/bootstrap-finished"
additional_bind_args=()
default_bind_file="$bind_path/binds.txt"
default_bind_file_ro="$bind_path/binds-ro.txt"
rw_bind_specs=()
ro_bind_specs=()
declare -A seen_rw_bind_specs=()
declare -A seen_ro_bind_specs=()

usage() {
  cat <<'EOF'
Usage: bash_mistral.sh [--bind PATH|HOST:CONTAINER] [--bind-ro PATH|HOST:CONTAINER] \
                       [--bind-file FILE] [--bind-file-ro FILE]

Bind options:
  --bind         Add a read-write bind mount.
  --bind-ro      Add a read-only bind mount.
  --bind-file    Read additional read-write bind specs from a file.
  --bind-file-ro Read additional read-only bind specs from a file.

When only one host path is given, it is mounted at the same resolved path inside
the container.
If present, binds.txt and binds-ro.txt in the current working directory are
loaded automatically.
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
  case "$option_name" in
    --bind)
      if [[ -n "${seen_rw_bind_specs[$normalized_spec]:-}" ]]; then
        return
      fi
      seen_rw_bind_specs["$normalized_spec"]=1
      additional_bind_args+=("--bind" "$normalized_spec")
      rw_bind_specs+=("$normalized_spec")
      ;;
    --bind-ro)
      if [[ -n "${seen_ro_bind_specs[$normalized_spec]:-}" ]]; then
        return
      fi
      seen_ro_bind_specs["$normalized_spec"]=1
      additional_bind_args+=("--bind" "${normalized_spec}:ro")
      ro_bind_specs+=("$normalized_spec")
      ;;
    *)
      echo "Unsupported bind option: $option_name" >&2
      exit 1
      ;;
  esac
}

persist_bind_specs() {
  local bind_file="$1"
  shift
  local spec

  if [[ $# -eq 0 ]]; then
    return
  fi

  touch "$bind_file"
  for spec in "$@"; do
    if ! grep -Fqx "$spec" "$bind_file"; then
      printf '%s\n' "$spec" >> "$bind_file"
    fi
  done
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

if [[ -f "$default_bind_file" ]]; then
  load_bind_file "--bind" "$default_bind_file"
fi

if [[ -f "$default_bind_file_ro" ]]; then
  load_bind_file "--bind-ro" "$default_bind_file_ro"
fi

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

persist_bind_specs "$default_bind_file" "${rw_bind_specs[@]}"
persist_bind_specs "$default_bind_file_ro" "${ro_bind_specs[@]}"

if [[ ! -f "$image" ]]; then
  echo "Image not found locally: $image"
  echo "Pulling image from: $image_ref"
  apptainer pull "$image" "$image_ref"
fi

if [[ -z "${MISTRAL_API_KEY:-}" ]]; then
  echo "Warning: MISTRAL_API_KEY is not set. Set it before running mistral-vibe." >&2
fi

mkdir -p "$home_dir_host"

echo "Mounting current folder into container at the same path: $bind_path"
echo "Using host home: $home_dir_host"
echo "Container home target: $home_dir_container"
echo "Starting shell in container: $image"
echo "Use 'exit' to leave the container shell."
echo "Type 'vibe' to start the Mistral Vibe CLI inside the container."
echo "Python environment manager 'pixi' is available (https://pixi.sh)."

gpu_args=()
if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
  echo "NVIDIA GPU detected — enabling GPU passthrough (--nv)."
  gpu_args+=(--nv)
fi

x11_args=()
if [[ -n "${DISPLAY:-}" ]]; then
  x11_args+=(--env "DISPLAY=$DISPLAY")
  if [[ -n "${XAUTHORITY:-}" && -f "$XAUTHORITY" ]]; then
    x11_args+=(--bind "$XAUTHORITY:/root/.Xauthority" --env "XAUTHORITY=/root/.Xauthority")
  fi
fi

dbus_args=()
if [[ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]]; then
  dbus_args+=(--env "DBUS_SESSION_BUS_ADDRESS=$DBUS_SESSION_BUS_ADDRESS")
  if [[ "$DBUS_SESSION_BUS_ADDRESS" == unix:path=* ]]; then
    dbus_socket_path="${DBUS_SESSION_BUS_ADDRESS#unix:path=}"
    if [[ -S "$dbus_socket_path" ]]; then
      dbus_args+=(--bind "$dbus_socket_path:$dbus_socket_path")
    fi
  fi
fi

if [[ -n "${XDG_RUNTIME_DIR:-}" && -d "${XDG_RUNTIME_DIR}" ]]; then
  dbus_args+=(--env "XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR" --bind "$XDG_RUNTIME_DIR:$XDG_RUNTIME_DIR")
fi

exec apptainer exec --no-home \
  --home "$home_dir_container" \
  --bind "$bind_path:$bind_path" \
  --bind "$home_dir_host:$home_dir_container" \
  --env "MISTRAL_API_KEY=${MISTRAL_API_KEY:-}" \
  "${additional_bind_args[@]}" \
  --pwd "$bind_path" \
  "${gpu_args[@]}" \
  "${x11_args[@]}" \
  "${dbus_args[@]}" \
  "$image" \
  /bin/bash -lc "if [[ ! -f \"$bootstrap_sentinel_host\" ]]; then /opt/bootstrap-workspace.sh; fi; exec /bin/bash -i"
