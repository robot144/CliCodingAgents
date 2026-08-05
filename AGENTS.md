# AGENTS.md

This file gives coding agents (Claude Code, Codex CLI, Copilot CLI, Mistral Vibe CLI, Antigravity CLI, or any other AI assistant working in a checkout of this repo) the context needed to work productively here.

## What this repository is

`CliCodingAgents` is a collection of Apptainer-containerized CLI coding agents, built to let people safely try out and compare LLM-based coding tools (Copilot CLI, ChatGPT Codex CLI, Mistral Vibe CLI, Claude Code, Antigravity CLI). Each agent is packaged as its own container so it can be tested in an isolated sandbox rather than run directly on the host. See [README.md](README.md) for the full background, status table, and usage docs.

There are two flavors of container per agent:
- **Generic** (`<agent>-cli/`) — the agent alone, for general coding tasks.
- **Delft3D-FM** (`<agent>-delft3d-cli/`) — the agent paired with a Delft3D-FM hydrodynamic modelling install, for Deltares-style workflows.

## Repository layout

```
<agent>-cli/            Apptainer.def, build_<agent>.sh, bash_<agent>.sh, optional helper docs
<agent>-delft3d-cli/    same, plus CLAUDE.md with Delft3D-FM paths/commands
bin/                    build artifacts collected by build.sh (*.sif images + bash_*.sh launchers)
build.sh                builds every */Apptainer.def and collects artifacts into bin/
clean.sh                removes generated .apptainer-home/ and .bash_history state
delft3d/                Delft3D-FM installation used by the *-delft3d-cli builds (not tracked in git — must be supplied locally)
coding_agents_presentation/  slides/plan for introducing these agents to colleagues
skills/                 shared Claude Code skills (e.g. weather-agent) available across containers
```

Each agent directory is self-contained: its `Apptainer.def` defines the container image, `build_<agent>.sh` builds it, and `bash_<agent>.sh` launches a shell inside it with the current working directory mounted at the same absolute path as on the host.

## Conventions to follow

- **One pattern per agent pair.** The `bash_*.sh` launcher scripts are near-identical across agents (mount cwd, isolate home via `.apptainer-home`, forward `DISPLAY`/Xauthority if set, detect `nvidia-smi` and add `--nv` if present). When editing one launcher's passthrough logic, check whether the same fix applies to the others — see the pattern in `claude-cli/bash_claude.sh:32-36` or `codex-cli/bash_codex.sh:39-43` for reference.
- **Don't hand-edit `bin/`.** It's a build artifact directory populated by `build.sh`; regenerate it by rebuilding rather than patching files there directly.
- **Delft3D binaries are not in the repo.** The `*-delft3d-cli/Apptainer.def` files reference `../delft3d/opt`; that directory must be populated locally before building (see README.md's Delft3D-FM section). Don't assume it's present in a fresh checkout.
- **Persisted container state lives in `.apptainer-home/`** (one per container, mapped to host). `clean.sh` wipes these — use it to reset to a clean slate rather than deleting by hand.
- **Large binary artifacts** (`.sif` images, `.tgz` archives, model data) are host-local build output or fixtures, not something to regenerate or commit casually — check `.gitignore` before adding new large files.

## Safety notes

This repo exists specifically to sandbox LLM agents via Apptainer so their file access stays inside the mounted workspace. When modifying launcher scripts or `Apptainer.def` files, preserve that isolation boundary (e.g. `--no-home`, explicit bind mounts) rather than loosening it — see README.md's "A word of caution" section for the full rationale.

## GUI and browser launch note

Inside these containers, GUI applications may work when launched directly from the interactive shell, but agent-executed commands can run in a reduced subprocess environment. If you need to launch a browser or other X11 application from an agent action, prefer preserving or explicitly passing the current session variables such as `DISPLAY`, `XAUTHORITY`, `DBUS_SESSION_BUS_ADDRESS`, and `XDG_RUNTIME_DIR`, or fall back to a manual shell command if needed.

## Where to look for more detail

- [README.md](README.md) — project overview, agent status table, running containers, X11/GPU passthrough
- `plan.md` — current priorities and open work
- `<agent>-delft3d-cli/CLAUDE.md` — Delft3D-FM paths, executables, run commands
