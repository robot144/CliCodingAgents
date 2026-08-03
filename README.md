
# CliCodingAgents

Recently (2026), there has been a surge in interest in using large language models (LLMs) to automate coding tasks. This repository contains a collection of agents that utilize LLMs to perform various coding-related tasks, such as code generation, code review, and debugging. There are several agents that can be used for different purposes, and they are designed to be easy to use and integrate into existing workflows. There are also several ways to interact with the agents, such as with a plugin in vscode, from the github.com page, or with a command line interface (CLI). 

In this repository, the aim is to test a few agents and see how well they perform on various coding tasks. 

## Status

We try to keep a few of the main agents up to date and tested. The table below shows the current status of the agents in this repository.

| Agent | Available | Last tested |
|---|:---:|:---:|
| Copilot CLI | ✓ | DD-MM-YYYY |
| ChatGPT Codex CLI | ✓ | DD-MM-YYYY |
| Mistral Vibe CLI | ✓ | DD-MM-YYYY |
| Claude Code | ✓ | DD-MM-YYYY |
| Gemini CLI | ✗ | DD-MM-YYYY |

### Delft3D-FM agents

Until recently, we also had Delft3D-FM-specific containers, but now we're moving this to skills that can be reused across different agents. Existing notes have been moved to [README_delft3d.md](README_delft3d.md) to prepare for moving this functionality out of this repository.

# Content of the containers
- **pixi** see below for more details.
- There are tools like popplar available in the containers to support the agents in working with pdf files.
- Many tools keep files in folders like $HOME/.pixi. Environments are stored inside the project folder and persist across container sessions via `.apptainer-home`. This folder is mapped to the host home directory, so you can share environments between container sessions. If you want to start with a clean slate, simply delete the `.apptainer-home` folder and its contents.

## Available Agents

### Copilot cli
- **Description**: Copilot CLI is a command-line interface that allows developers to interact with GitHub Copilot, an AI-powered code completion tool. It provides a way to use Copilot's capabilities directly from the terminal, enabling developers to generate code snippets, get suggestions, and perform various coding tasks without leaving the command line.
- [into copilot-cli](https://developer.microsoft.com/blog/get-started-with-github-copilot-cli-a-free-hands-on-course)
- [copilot-cli on github](https://github.com/github/copilot-cli)
- **copilot-cli tests**: See [copilot-cli/README.md](copilot-cli/README.md) for more details on the tests performed with copilot-cli.

### ChatGPT codex-cli
- **Description**: ChatGPT Codex CLI is a command-line interface that allows developers to interact with OpenAI's Codex, an AI model designed for code generation and understanding. It provides a way to use Codex's capabilities directly from the terminal, enabling developers to generate code snippets, get suggestions, and perform various coding tasks without leaving the command line.
- [ChatGPT Codex CLI documentation](https://developers.openai.com/codex/cli/)
- **ChatGPT Codex CLI tests**: See [chatgpt-codex-cli/README.md](chatgpt-codex-cli/README.md) for more details on the tests performed with ChatGPT Codex CLI.

### Mistral Vibe CLI
- **Description**: Mistral Vibe CLI is an AI-powered code generation tool developed by Mistral. It uses advanced language models to assist developers in writing code by generating code snippets, providing suggestions, and helping with various coding tasks. Mistral Vibe CLI aims to enhance developer productivity and streamline the coding process by leveraging the capabilities of large language models.
- [Mistral Vibe CLI documentation](https://mistral.ai/news/devstral-2-vibe-cli)
- [Codestral CLI console page](https://console.mistral.ai/codestral/cli)
- **Mistral Vibe CLI tests**: See [mistral-cli/README.md](mistral-cli/README.md) for more details on running the Mistral Vibe CLI in an Apptainer container.

### Claude code
- **Description**: Claude Code is an AI-powered code generation tool developed by Anthropic. It uses advanced language models to assist developers in writing code by generating code snippets, providing suggestions, and helping with various coding tasks. Claude Code aims to enhance developer productivity and streamline the coding process by leveraging the capabilities of large language models.
- [Claude code documentation](https://code.claude.com/docs/en/overview)
- It works linked to a consumer claude.ai chat pro account or with the business console.enthropic.com api-key. The first has a fixed limit, predicatable pricing and lower context.
- [Claude ai](https://claude.ai/chat/)
- [Claude api-key](https://platform.claude.com/)
- **Claude Code tests**: See [claude-cli/README.md](claude-cli/README.md) for more details on the tests performed with Claude Code.

### Gemini CLI
- **Description**: Gemini CLI is Google's terminal-based coding assistant for querying and editing large codebases, generating apps from images or PDFs, and automating development workflows from the command line.
- [Gemini CLI documentation](https://geminicli.com/)
- Install with `npm install -g @google/gemini-cli`
- Status in this repository: not yet containerized or tested.

## Installation

### Pre-requisites
- apptainer installed on the system. Many linux clusters have apptainer installed, but if you are running on a local machine, you may need to install it yourself. You can find instructions for installing apptainer on the [apptainer documentation](https://apptainer.org/docs/) page.
- access to the agents (e.g., copilot cli, claude code, chatgpt codex-cli, aider) This may require signing up for an account and obtaining an API key, depending on the agent.

### Building the containers

To build the containers for the agents, navigate to the respective agent's folder and run the build script. For example:

```bash
cd /path/to/repo/claude-cli
./build_claude.sh
```

### Running the containers

Each agent has a dedicated launch script in its folder (e.g. `claude-cli/bash_claude.sh`). The script mounts your current working directory into the container, sets up an isolated home directory, and drops you into a shell where you can invoke the agent.

```bash
cd /path/to/your/project
/path/to/repo/claude-cli/bash_claude.sh
# then inside the container:
claude
```

### Mounted folders

The launchers mount the current working directory into the container and keep a hidden `.apptainer-home` folder inside that project folder for persistent data such as pixi environments and configuration files. The newer binding scheme preserves the same absolute path inside the container as on the host whenever possible, so file references are easier to recognize and reuse.

The aim is to keep the container isolated from the host system, while still allowing you to work on your project files and share data between container sessions.

Some launchers also support binding extra folders into the container:

- `--bind <path>` mounts a host path read-write at the same path inside the container.
- `--bind <host:container>` mounts a host path read-write at an explicit container path.
- `--bind-ro <path>` mounts a host path read-only at the same path inside the container.
- `--bind-ro <host:container>` mounts a host path read-only at an explicit container path.
- `--bind-file <file>` reads additional read-write bind specs from a file.
- `--bind-file-ro <file>` reads additional read-only bind specs from a file.

Relative host paths are resolved against the current working directory for direct `--bind` and `--bind-ro` arguments. In bind files, relative host paths are resolved relative to the bind file's directory. Container target paths must be absolute.

Examples:

```bash
/path/to/repo/copilot-cli/bash_copilot.sh --bind data --bind-ro ../shared-models
/path/to/repo/copilot-cli/bash_copilot.sh --bind /host/data:/container/data
/path/to/repo/copilot-cli/bash_copilot.sh --bind-file mounts.txt --bind-file-ro mounts-ro.txt
```

### Container initialization

On first startup in a given workspace, the launcher runs a shared bootstrap script inside the container. This bootstrap tracks completion with `.apptainer-home/bootstrap-finished`, so it normally runs only once per mounted workspace.

The bootstrap currently focuses on Python environment setup through `pixi`. It creates `$HOME/bin`, prepends that directory to the shell `PATH`, and installs small `python` and `python3` wrappers there that run `pixi run python`. If `pixi.toml` is missing and there is no user-provided `pyproject.toml`, it creates a minimal default manifest with Python pinned below 3.14. If `.pixi` is missing, it runs `pixi install` to create the environment, **which may take some time**. If `.pixi` already exists, it assumes that environment is valid and leaves it untouched.

## Pre-installed tools in the containers

A few tools are pre-installed in the containers to support the agents in working with various file formats and dependencies. These include:

### pixi — Python & multi-language environment manager

The Claude Code container includes [pixi](https://pixi.sh), a fast, Rust-based package manager built on conda-forge. It allows you to create reproducible environments with Python, R, and compiled libraries (NumPy, GDAL, NetCDF4, CUDA, etc.) without needing system-level installs. Unlike pip/venv, pixi resolves both Python packages and native dependencies together, making it well suited for scientific and data-heavy projects. Environments are stored inside the project folder and persist across container sessions via `.apptainer-home`. 

```bash
pixi init myproject && cd myproject # initialise a new project
pixi add python numpy xarray # add packages (from conda-forge and PyPI)
pixi run python script.py # run a script inside the environment
```

### Skill installation via `gh`

The containers also include `gh`, which can be used to install skills from a GitHub repository. This is intended for sharing domain-specific skills outside the container image itself.

Skills in a repository can live in a layout like:

```text
skills/
└── weather-agent
    ├── scripts
    │   └── weather.py
    └── SKILL.md
```

Example installation:

```bash
gh skill install robot144/CliCodingAgents weather-agent
```

This requires a very recent version of `gh`.

## Container to host connection

We try to find a balance between isolation and usability. The containers are sandboxed, but we also want to make it easy to use host features like graphical displays and NVIDIA GPUs. Currently you can expect the following host features to be available inside the container:

### X11 / graphical display passthrough

If the environment variable `DISPLAY` is set on the host (i.e. you are running inside a graphical session or have X11 forwarding active over SSH), the script automatically passes it into the container together with the Xauthority cookie. This lets code running inside the container open windows on your desktop — for example matplotlib figures or GUI tools.

To enable X11 forwarding over SSH, connect with:

```bash
ssh -X user@host
```

No changes to the container image are needed; the display is forwarded automatically whenever `DISPLAY` is set.

### NVIDIA GPU passthrough

Each launch script detects whether an NVIDIA GPU is available on the host by calling `nvidia-smi`. If the driver is present and responsive, the Apptainer `--nv` flag is added automatically and a message is printed:

```
NVIDIA GPU detected — enabling GPU passthrough (--nv).
```

`--nv` binds the host NVIDIA driver libraries into the container, making the GPU accessible to code running inside. Importantly, only the **driver** needs to be installed on the host — CUDA toolkit libraries (e.g. from a `pixi` or `conda` environment) can live entirely inside the container. On machines without an NVIDIA GPU the flag is silently omitted and the container starts normally.

## A word of caution

Agents that utilize LLMs can be powerful tools, but if you accept to run a command, then a small mistake can cause a lot of damage. All of the agents discussed here have safeguards in place to prevent them from causing harm, but it is still important to be cautious when using them. Always review the commands that the agents generate before running them, and make sure that you understand what they do. If you are unsure about a command, it is best to err on the side of caution and not run it. My suggestion would be to use the agents only on a folder that is linked to a repository, so that you can easily revert any changes that the agents make, or just revert to the previous commit if you are using git. Still, this is not a guarantee that the agents will not cause any damage, so it is important to be vigilant and cautious when using them. Always keep in mind that the agents are just tools, and it is up to you to use them responsibly and safely.

Being a cautious creature, we here create a safe and controlled environment for testing, the agents are run in a sandboxed environment. This allows us to evaluate their performance without risking any damage to the system or data. We use apptainer to create and manage the sandboxed environment, which provides a secure and isolated environment for running the agents. This can make it harder to run code from the agents, but it also ensures that the agents cannot cause any harm to the system or data, outside the folder that we share with the container.

Another concern voiced is that all LLMs that you call with an api, will have access to the data that you share with them, and that they may use this data for training or other purposes. This is a valid concern, and it is important to be aware of the privacy implications of using these agents. It is always a good idea to review the privacy policies of the agents and the LLMs that they use, and to be cautious about sharing sensitive data with them. If you are concerned about privacy, you may want to consider using agents that allow you to run your own instance of the LLM, or that have strict privacy policies in place.

## Other links
- [apptainer documentation](https://apptainer.org/docs/)
