#!/usr/bin/env bash
set -euo pipefail

default_image_path="${DEFAULT_IMAGE_PATH:-}"
default_image_name="${DEFAULT_IMAGE_NAME:-}"
default_build_hint="${DEFAULT_BUILD_HINT:-}"

image_path="${1:-$default_image_path}"
target_ref="${2:-}"

usage() {
  cat <<'EOF'
Usage: push_image.sh [IMAGE_PATH] [oras://TARGET]

Examples:
  ./push_image.sh ./copilot-cli/copilot-cli.sif oras://ghcr.io/myuser/copilot-cli:latest

Environment variables:
  DEFAULT_IMAGE_PATH  Optional default image path used when IMAGE_PATH is omitted
  DEFAULT_IMAGE_NAME  Optional default image name used when GHCR_IMAGE_NAME is unset
  DEFAULT_BUILD_HINT  Optional build hint shown when the image is missing
  GHCR_NAMESPACE      Optional. Example: myuser or myorg
  GHCR_IMAGE_NAME     Optional image name for the target
  GHCR_TAG            Optional. Default: latest

If no target is given explicitly, the script builds:
  oras://ghcr.io/${GHCR_NAMESPACE}/${GHCR_IMAGE_NAME}:${GHCR_TAG}

Authentication:
  Run 'apptainer registry login docker://ghcr.io' first, or configure
  compatible registry credentials for Apptainer.
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if ! command -v apptainer >/dev/null 2>&1; then
  echo "apptainer is not installed or not on PATH" >&2
  exit 1
fi

if [[ -z "$image_path" ]]; then
  echo "No image path provided and DEFAULT_IMAGE_PATH is not set." >&2
  usage >&2
  exit 1
fi

if [[ ! -f "$image_path" ]]; then
  echo "Image not found: $image_path" >&2
  if [[ -n "$default_build_hint" ]]; then
    echo "Build it first with: $default_build_hint" >&2
  fi
  exit 1
fi

if [[ -z "$target_ref" ]]; then
  ghcr_namespace="${GHCR_NAMESPACE:-}"
  ghcr_image_name="${GHCR_IMAGE_NAME:-$default_image_name}"
  ghcr_tag="${GHCR_TAG:-latest}"

  if [[ -z "$ghcr_namespace" ]]; then
    echo "GHCR_NAMESPACE is required when no explicit oras:// target is provided." >&2
    usage >&2
    exit 1
  fi

  if [[ -z "$ghcr_image_name" ]]; then
    echo "GHCR_IMAGE_NAME is required when no explicit oras:// target is provided." >&2
    usage >&2
    exit 1
  fi

  target_ref="oras://ghcr.io/${ghcr_namespace}/${ghcr_image_name}:${ghcr_tag}"
fi

case "$target_ref" in
  oras://ghcr.io/*:*)
    ;;
  *)
    echo "Target must look like oras://ghcr.io/<namespace>/<image>:<tag>" >&2
    exit 1
    ;;
esac

echo "Pushing image: $image_path"
echo "Target: $target_ref"

apptainer push "$image_path" "$target_ref"
