#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"

export DEFAULT_IMAGE_PATH="${DEFAULT_IMAGE_PATH:-$script_dir/copilot-cli.sif}"
export DEFAULT_IMAGE_NAME="${DEFAULT_IMAGE_NAME:-copilot-cli}"
export DEFAULT_BUILD_HINT="${DEFAULT_BUILD_HINT:-./build_copilot.sh}"

if [[ $# -eq 0 && -t 0 && -t 1 ]]; then
  default_namespace="${GHCR_NAMESPACE:-robot144}"
  default_image_name="${GHCR_IMAGE_NAME:-copilot-cli}"
  default_tag="${GHCR_TAG:-latest}"
  default_username="${GHCR_USERNAME:-$default_namespace}"

  printf 'GitHub Container Registry namespace [%s]: ' "$default_namespace"
  read -r ghcr_namespace
  ghcr_namespace="${ghcr_namespace:-$default_namespace}"

  printf 'Image name [%s]: ' "$default_image_name"
  read -r ghcr_image_name
  ghcr_image_name="${ghcr_image_name:-$default_image_name}"

  printf 'Tag [%s]: ' "$default_tag"
  read -r ghcr_tag
  ghcr_tag="${ghcr_tag:-$default_tag}"

  printf 'Log in to ghcr.io now? [y/N]: '
  read -r do_login
  case "${do_login,,}" in
    y|yes)
      printf 'GitHub username [%s]: ' "$default_username"
      read -r ghcr_username
      ghcr_username="${ghcr_username:-$default_username}"
      apptainer registry login --username "$ghcr_username" docker://ghcr.io
      ;;
  esac

  export GHCR_NAMESPACE="$ghcr_namespace"
  export GHCR_IMAGE_NAME="$ghcr_image_name"
  export GHCR_TAG="$ghcr_tag"
fi

exec "$repo_root/push_image.sh" "$@"
