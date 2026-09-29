#!/usr/bin/env bash
# Convert a PDF to markdown with marker-pdf (see install_marker-pdf.sh).
#
# Usage:  ./pdf2md.sh input.pdf [marker_single options...]
#
# Output goes next to the PDF: docs/foo.pdf -> docs/foo/foo.md (+ images, meta.json),
# unless --output_dir is given.
# Run `./pdf2md.sh --help` for marker_single's options.
set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 1 ]; then
    echo "usage: $0 input.pdf [marker_single options...]" >&2
    exit 1
fi
if [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    exec pixi run --manifest-path "$PROJECT_DIR" marker_single --help
fi

PDF="$1"
shift
[ -f "$PDF" ] || { echo "error: file not found: $PDF" >&2; exit 1; }

# Default: output next to the PDF (marker creates <pdf dir>/<name>/), unless the caller passed --output_dir.
extra=()
case " $* " in
    *" --output_dir"*) ;;
    *) extra=(--output_dir "$(cd "$(dirname "$PDF")" && pwd)") ;;
esac

# Point marker at the local llama-server if the pixi manifest doesn't already.
if [ -z "${LLAMA_CPP_BINARY:-}" ]; then
    server="$(ls -d "$PROJECT_DIR"/bin/llama-*/llama-server 2>/dev/null | sort -V | tail -1 || true)"
    [ -n "$server" ] && export LLAMA_CPP_BINARY="$server"
fi
export LD_LIBRARY_PATH="$PROJECT_DIR/.pixi/envs/default/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

exec pixi run --manifest-path "$PROJECT_DIR" marker_single "$PDF" "${extra[@]}" "$@"
