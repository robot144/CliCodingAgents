#!/usr/bin/env bash
# Undo install_marker-pdf.sh in a pixi workspace.
#
# Usage:  ./uninstall_marker-pdf.sh [--models] [project_dir]   (default: current directory)
#
# Removes: marker-pdf and libgomp from the manifest (and env), the LLAMA_CPP_BINARY /
#          LD_LIBRARY_PATH lines added to [activation.env], and bin/llama-*.
# Keeps:   the manifest itself, the python dependency (other code may need it),
#          and all converted output.
# --models also deletes the downloaded models (~/.cache/datalab and the
#          datalab-to repos in the Hugging Face cache), ~1.8 GB.
set -euo pipefail

REMOVE_MODELS=0
if [ "${1:-}" = "--models" ]; then
    REMOVE_MODELS=1
    shift
fi
PROJECT_DIR="$(cd "${1:-.}" && pwd)"
cd "$PROJECT_DIR"
log() { printf '\n==> %s\n' "$*"; }

command -v pixi >/dev/null || { echo "error: pixi not found on PATH" >&2; exit 1; }

if [ -f pixi.toml ]; then
    MANIFEST=pixi.toml
    ENV_SECTION='[activation.env]'
elif [ -f pyproject.toml ] && grep -q '^\[tool\.pixi' pyproject.toml; then
    MANIFEST=pyproject.toml
    ENV_SECTION='[tool.pixi.activation.env]'
else
    MANIFEST=
fi

if [ -n "$MANIFEST" ]; then
    log "Using manifest: $MANIFEST"

    # --- 1. activation environment -------------------------------------------
    # Drop the two lines install_marker-pdf.sh added, then the section header if it is now empty.
    if grep -q 'LLAMA_CPP_BINARY' "$MANIFEST"; then
        log "Removing LLAMA_CPP_BINARY / LD_LIBRARY_PATH from $ENV_SECTION"
        tmp="$(mktemp)"
        awk -v hdr="$ENV_SECTION" '
            /^LLAMA_CPP_BINARY = "\$PIXI_PROJECT_ROOT\/bin\/llama-[^"]*\/llama-server"$/ { next }
            $0 == "LD_LIBRARY_PATH = \"$CONDA_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}\"" { next }
            { line[++n] = $0 }
            END {
                for (i = 1; i <= n; i++) {
                    if (line[i] == hdr) {
                        j = i + 1
                        while (j <= n && line[j] ~ /^[[:space:]]*$/) j++
                        if (j > n || line[j] ~ /^\[/) continue   # empty section
                    }
                    keep[++m] = line[i]
                }
                while (m > 0 && keep[m] ~ /^[[:space:]]*$/) m--   # trailing blank lines
                for (i = 1; i <= m; i++) print keep[i]
            }' "$MANIFEST" > "$tmp"
        cat "$tmp" > "$MANIFEST" && rm -f "$tmp"
        grep -q 'LLAMA_CPP_BINARY' "$MANIFEST" &&
            echo "warning: LLAMA_CPP_BINARY still in $MANIFEST (edited by hand?); remove it manually" >&2
    fi

    # --- 2. dependencies -------------------------------------------------------
    if grep -q 'marker-pdf' "$MANIFEST"; then
        log "Removing marker-pdf"
        pixi remove --pypi marker-pdf
    fi
    if grep -q '^libgomp' "$MANIFEST"; then
        log "Removing libgomp"
        pixi remove libgomp
    fi
else
    log "No pixi manifest found; skipping dependency removal"
fi

# --- 3. llama.cpp binaries -----------------------------------------------------
if compgen -G "bin/llama-*" >/dev/null; then
    log "Removing $(echo bin/llama-*)"
    rm -rf bin/llama-*
    rmdir bin 2>/dev/null || true
fi

# --- 4. models (optional) -------------------------------------------------------
if [ "$REMOVE_MODELS" = 1 ]; then
    hf_hub="${HF_HUB_CACHE:-${HF_HOME:-$HOME/.cache/huggingface}/hub}"
    log "Removing models from ~/.cache/datalab and $hf_hub/models--datalab-to--*"
    rm -rf "$HOME/.cache/datalab"
    rm -rf "$hf_hub"/models--datalab-to--*
fi

echo
echo "Done. python and converted output were left in place."
[ "$REMOVE_MODELS" = 1 ] || echo "Downloaded models were kept; use --models to remove them."
