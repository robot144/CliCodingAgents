# CliCodingAgents Plan

## Goal

Provide a safe, sandboxed way to try and compare CLI-based LLM coding agents (Copilot CLI, Codex CLI, Mistral Vibe CLI, Claude Code, Gemini CLI), each packaged as an Apptainer container, so they can be evaluated without risking the host system or exposing more data than intended. See [README.md](README.md) for full rationale.


Shared infrastructure already in place across all containers:
- Isolated `.apptainer-home` per container, host cwd mounted at `/workspace`
- `pixi` for Python/R/native package management inside containers
- X11/`DISPLAY` passthrough for GUI tools (e.g. matplotlib)
- NVIDIA GPU passthrough (`--nv`) auto-detected via `nvidia-smi`
- `build.sh` / `clean.sh` for building all containers and resetting state

## Check after making changes

- **Keep launcher scripts in sync.** The `bash_<agent>.sh` scripts share a common pattern (mount, home isolation, X11, `--nv` GPU detection); when one is fixed or improved, check whether the fix applies to the others.
- **Do containers still compile cleanly** Note that this cannot be done from within a container. Prompt me (user) to check this.

## Out of scope (for now)

- Non-CLI agents (VSCode extensions, web-based chat) — this repo is specifically about the CLI/container story.
- Deep evaluation/benchmarking harness — current testing is manual, documented per-agent in each `<agent>-cli/README.md`.
- Aider or other agents not already listed in the status tables above, unless a specific need arises.

## TODO / Next steps

- [x] **Define generic first-run bootstrap behavior for mounted workspaces**
  - [x] **Create draft for bootstrap script for github-copilot**
  - [x] **add python and a pixi run python shortcut to ~/bin**
  - [x] **work on a generic AGENTS.md**
- [x] **Make container working directories match the host `pwd`**
  - [x] **Modify `copilot-cli/bash_copilot.sh` so the container starts in the same working directory as the host `pwd`**
  - [x] **Add support for binding additional folders, with optional read-only mounts**
- [ ] **Fix the other agents, based on copilot template:
    - [ ] claude
    - [ ] mistral
    - [ ] codex
    - [ ] gemini
- [x] **make installation easier**
  - [x] **generate container images and push them to ghcr.io**
  - [x] **automatically pull image if missing**
- [ ] **Move domain knowledge into installable skills**
  - [x] **Add `gh` for skill management**
  - [x] **Create a dummy skill and document it**
  - [ ] **Move Delft3D-specific skills to an external repo**
  - [ ] **Install skills after container startup using `gh`**
