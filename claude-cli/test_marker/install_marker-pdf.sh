#!/usr/bin/env bash
# Install marker-pdf (PDF -> markdown) with a CPU llama.cpp backend into a pixi workspace.
#
# Usage:  ./install_marker-pdf.sh [project_dir]      (default: current directory)
#
# Safe to re-run: existing manifests are extended, not replaced, and the
# llama.cpp binary is only downloaded when missing.
#
# Environment overrides:
#   LLAMA_TAG   llama.cpp release tag to download (default: b11228)
set -euo pipefail

PROJECT_DIR="$(cd "${1:-.}" && pwd)"
LLAMA_TAG="${LLAMA_TAG:-b11228}"
LLAMA_DIR="bin/llama-${LLAMA_TAG}"
LLAMA_URL="https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_TAG}/llama-${LLAMA_TAG}-bin-ubuntu-x64.tar.gz"

cd "$PROJECT_DIR"
log() { printf '\n==> %s\n' "$*"; }

command -v pixi >/dev/null || { echo "error: pixi not found on PATH" >&2; exit 1; }
[ "$(uname -m)" = "x86_64" ] || { echo "error: prebuilt llama.cpp binary is x86_64 only" >&2; exit 1; }

# --- 1. pixi manifest --------------------------------------------------------
if [ -f pixi.toml ]; then
    MANIFEST=pixi.toml
    ENV_SECTION='[activation.env]'
elif [ -f pyproject.toml ]; then
    MANIFEST=pyproject.toml
    ENV_SECTION='[tool.pixi.activation.env]'
    if ! grep -q '^\[tool\.pixi' pyproject.toml; then
        log "Adding pixi configuration to existing pyproject.toml"
        pixi init --format pyproject .
    fi
else
    MANIFEST=pixi.toml
    ENV_SECTION='[activation.env]'
    log "Creating pixi.toml"
    pixi init --format pixi .
fi
log "Using manifest: $MANIFEST"

# --- 2. dependencies ----------------------------------------------------------
# Python 3.12: marker-pdf pins pillow 10.4, which has no wheels for newer Pythons.
# libgomp: needed at runtime by the llama-server binary (libgomp.so.1).
log "Adding conda dependencies (python 3.12, libgomp)"
pixi add "python>=3.12,<3.13" libgomp

log "Adding marker-pdf from PyPI"
pixi add --pypi "marker-pdf>=2.0.0,<3"

# --- 3. llama.cpp CPU inference server ---------------------------------------
if [ -x "$LLAMA_DIR/llama-server" ]; then
    log "llama-server already present in $LLAMA_DIR"
else
    log "Downloading llama.cpp $LLAMA_TAG"
    mkdir -p bin
    curl -fL "$LLAMA_URL" | tar -xz -C bin
    [ -x "$LLAMA_DIR/llama-server" ] || { echo "error: $LLAMA_DIR/llama-server not found after extraction" >&2; exit 1; }
fi

# --- 4. activation environment -----------------------------------------------
# Lets `pixi run marker_single ...` find llama-server and libgomp without manual exports.
if grep -q 'LLAMA_CPP_BINARY' "$MANIFEST"; then
    log "Activation env already configured in $MANIFEST"
else
    log "Adding LLAMA_CPP_BINARY / LD_LIBRARY_PATH to $ENV_SECTION in $MANIFEST"
    env_lines="LLAMA_CPP_BINARY = \"\$PIXI_PROJECT_ROOT/${LLAMA_DIR}/llama-server\"
LD_LIBRARY_PATH = \"\$CONDA_PREFIX/lib\${LD_LIBRARY_PATH:+:\$LD_LIBRARY_PATH}\""
    if grep -qF "$ENV_SECTION" "$MANIFEST"; then
        # Section exists: insert the variables right below its header.
        tmp="$(mktemp)"
        awk -v hdr="$ENV_SECTION" -v lines="$env_lines" \
            '{ print } $0 == hdr { print lines }' "$MANIFEST" > "$tmp"
        cat "$tmp" > "$MANIFEST" && rm -f "$tmp"
    else
        printf '\n%s\n%s\n' "$ENV_SECTION" "$env_lines" >> "$MANIFEST"
    fi
fi

# --- 5. install and verify ---------------------------------------------------
log "Installing environment"
pixi install

log "Verifying"
pixi run bash -c '"$LLAMA_CPP_BINARY" --version 2>&1 | head -1'
pixi run marker_single --help >/dev/null
echo "marker_single OK"

cat <<EOF

Done. Convert a PDF with:

    pixi run marker_single input.pdf --output_dir ./output

The first run downloads models from Hugging Face (setting HF_TOKEN raises rate limits).
EOF
