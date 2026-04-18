#!/bin/bash

# Create bin directory if it doesn't exist
mkdir -p ./bin

# Build each container and collect artifacts
for cli_dir in ./*-cli/; do
    if [ -d "$cli_dir" ]; then
        echo "Building $cli_dir..."
        (cd "$cli_dir" && ./build_*.sh)
        
        # Copy .sif and bash_*.sh files to bin
        cp "$cli_dir"/*.sif /workspace/bin/ 2>/dev/null || true
        cp "$cli_dir"/bash_*.sh /workspace/bin/ 2>/dev/null || true
    fi
done

echo "Build complete. Artifacts collected in /workspace/bin/"
