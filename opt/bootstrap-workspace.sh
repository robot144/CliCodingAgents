#!/usr/bin/env bash
set -euo pipefail

sentinel_path="${HOME}/bootstrap-finished"
bashrc_path="${HOME}/.bashrc"
home_bin_dir="${HOME}/bin"
python_shim_path="${home_bin_dir}/python"
python3_shim_path="${home_bin_dir}/python3"
workspace_dir="${PWD}"
default_agents_path="/opt/AGENTS.md"
workspace_agents_path="${workspace_dir}/AGENTS.md"
pixi_manifest_path="${workspace_dir}/pixi.toml"
pyproject_manifest_path="${workspace_dir}/pyproject.toml"
pixi_env_dir="${workspace_dir}/.pixi"
workspace_name="$(basename "${workspace_dir}")"

if [[ -f "$sentinel_path" ]]; then
    echo "Bootstrap already completed for this workspace: $sentinel_path"
    exit 0
fi

echo "Starting workspace bootstrap..."

if ! command -v pixi >/dev/null 2>&1; then
    echo "pixi is not installed or not on PATH" >&2
    exit 1
fi

mkdir -p "${home_bin_dir}"

if [[ ! -f "${bashrc_path}" ]]; then
    touch "${bashrc_path}"
fi

if ! grep -Fqx 'export PATH="$HOME/bin:$PATH"' "${bashrc_path}"; then
    echo 'export PATH="$HOME/bin:$PATH"' >> "${bashrc_path}"
fi

cat > "${python_shim_path}" <<'EOF'
#!/usr/bin/env bash
exec pixi run python "$@"
EOF
chmod +x "${python_shim_path}"

cat > "${python3_shim_path}" <<'EOF'
#!/usr/bin/env bash
exec pixi run python "$@"
EOF
chmod +x "${python3_shim_path}"
echo "Configured ${python_shim_path} and ${python3_shim_path} to run 'pixi run python'."

if [[ -f "${workspace_agents_path}" ]]; then
    echo "Found existing AGENTS.md: ${workspace_agents_path}"
elif [[ -f "${default_agents_path}" ]]; then
    cp "${default_agents_path}" "${workspace_agents_path}"
    echo "Copied default AGENTS.md into workspace: ${workspace_agents_path}"
else
    echo "Default AGENTS.md not found at ${default_agents_path}; skipping workspace copy."
fi

if [[ -f "$pixi_manifest_path" ]]; then
    echo "Found existing pixi manifest: $pixi_manifest_path"
elif [[ -f "$pyproject_manifest_path" ]]; then
    echo "Found existing pyproject manifest: $pyproject_manifest_path"
    echo "Skipping default pixi.toml creation because the workspace already defines a project manifest."
else
    echo "No pixi.toml found. Creating a default manifest with Python..."
    cat > "$pixi_manifest_path" <<EOF
[workspace]
name = "${workspace_name}"
version = "0.1.0"
channels = ["conda-forge"]
platforms = ["linux-64"]

[dependencies]
python = ">=3.10,<3.14"
EOF
fi

if [[ ! -d "$pixi_env_dir" ]]; then
    echo "No .pixi environment found. Initializing pixi environment..."
    echo "Creating fresh Pixi environment with 'pixi install'..."
    pixi install
else
    echo "Found existing pixi environment: $pixi_env_dir"
    echo "Assuming this existing Pixi environment is already working."
    echo "If it is not working, run: rm -rf .pixi; pixi install"
fi

touch "$sentinel_path"

echo "Finished workspace bootstrap: $sentinel_path"
