
# CliCodingAgents

Recently (2026), there has been a surge in interest in using large language models (LLMs) to automate coding tasks. This repository contains a collection of agents that utilize LLMs to perform various coding-related tasks, such as code generation, code review, and debugging. There are several agents that can be used for different purposes, and they are designed to be easy to use and integrate into existing workflows. There are also several ways to interact with the agents, such as with a plugin in vscode, from the github.com page, or with a command line interface (CLI). 

In this repository, the aim is to test a few agents and see how well they perform on various coding tasks. 

## A word of caution

Agents that utilize LLMs can be powerful tools, but if you accept to run a command, then a small mistake can cause a lot of damage. All of the agents discussed here have safeguards in place to prevent them from causing harm, but it is still important to be cautious when using them. Always review the commands that the agents generate before running them, and make sure that you understand what they do. If you are unsure about a command, it is best to err on the side of caution and not run it. My suggestion would be to use the agents only on a folder that is linked to a repository, so that you can easily revert any changes that the agents make, or just revert to the previous commit if you are using git. Still, this is not a guarantee that the agents will not cause any damage, so it is important to be vigilant and cautious when using them. Always keep in mind that the agents are just tools, and it is up to you to use them responsibly and safely.

Being a cautious creature, we here create a safe and controlled environment for testing, the agents are run in a sandboxed environment. This allows us to evaluate their performance without risking any damage to the system or data. We use apptainer to create and manage the sandboxed environment, which provides a secure and isolated environment for running the agents. This can make it harder to run code from the agents, but it also ensures that the agents cannot cause any harm to the system or data, outside the folder that we share with the container.

Another concern voiced is that all LLMs that you call with an api, will have access to the data that you share with them, and that they may use this data for training or other purposes. This is a valid concern, and it is important to be aware of the privacy implications of using these agents. It is always a good idea to review the privacy policies of the agents and the LLMs that they use, and to be cautious about sharing sensitive data with them. If you are concerned about privacy, you may want to consider using agents that allow you to run your own instance of the LLM, or that have strict privacy policies in place.

## Pre-requisites
- apptainer installed on the system. Many linux clusters have apptainer installed, but if you are running on a local machine, you may need to install it yourself. You can find instructions for installing apptainer on the [apptainer documentation](https://apptainer.org/docs/) page.
- access to the agents (e.g., copilot cli, claude code, chatgpt codex-cli, aider) This may require signing up for an account and obtaining an API key, depending on the agent.

## Status

### Generic agents: usefull for a wide range of coding tasks, such as code generation, code review, and debugging. They can be used in a variety of programming languages and frameworks, and they can be integrated into existing workflows.
| Agent | Available | Tested |
|---|:---:|:---:|
| Copilot CLI | ✓ | ✓ |
| ChatGPT Codex CLI | ✓ | ✓ |
| Mistral Vibe CLI | ✓ | ✓ |
| Claude Code | ✓ | ✓ |
| Gemini Code | ✗ | ✗ |

### Delft3D-FM agents: specifically designed for working with the Delft3D-FM hydrodynamic modelling suite. They can read model input/output, write run scripts, and post-process results directly, making them well-suited for users of Delft3D-FM.
| Agent | Available | Tested |
|---|:---:|:---:|
| Claude Code + Delft3D-FM | ✓ | ✓ |
| GitHub Copilot CLI + Delft3D-FM | ✓ | ✓ |

# Content of the containers
- **pixi** see below for more details.
- There are tools like popplar available in the containers to support the agents in working with pdf files.
- Many tools keep files in folders like $HOME/.pixi. Environments are stored inside the project folder and persist across container sessions via `.apptainer-home`. This folder is mapped to the host home directory, so you can share environments between container sessions. If you want to start with a clean slate, simply delete the `.apptainer-home` folder and its contents.

## Available Agents

## Copilot cli
- **Description**: Copilot CLI is a command-line interface that allows developers to interact with GitHub Copilot, an AI-powered code completion tool. It provides a way to use Copilot's capabilities directly from the terminal, enabling developers to generate code snippets, get suggestions, and perform various coding tasks without leaving the command line.
- [into copilot-cli](https://developer.microsoft.com/blog/get-started-with-github-copilot-cli-a-free-hands-on-course)
- [copilot-cli on github](https://github.com/github/copilot-cli)
- **copilot-cli tests**: See [copilot-cli/README.md](copilot-cli/README.md) for more details on the tests performed with copilot-cli.

## ChatGPT codex-cli
- **Description**: ChatGPT Codex CLI is a command-line interface that allows developers to interact with OpenAI's Codex, an AI model designed for code generation and understanding. It provides a way to use Codex's capabilities directly from the terminal, enabling developers to generate code snippets, get suggestions, and perform various coding tasks without leaving the command line.
- [ChatGPT Codex CLI documentation](https://developers.openai.com/codex/cli/)
- **ChatGPT Codex CLI tests**: See [chatgpt-codex-cli/README.md](chatgpt-codex-cli/README.md) for more details on the tests performed with ChatGPT Codex CLI.

## Mistral Vibe CLI
- **Description**: Mistral Vibe CLI is an AI-powered code generation tool developed by Mistral. It uses advanced language models to assist developers in writing code by generating code snippets, providing suggestions, and helping with various coding tasks. Mistral Vibe CLI aims to enhance developer productivity and streamline the coding process by leveraging the capabilities of large language models.
- [Mistral Vibe CLI documentation](https://mistral.ai/news/devstral-2-vibe-cli)
- [Codestral CLI console page](https://console.mistral.ai/codestral/cli)
- **Mistral Vibe CLI tests**: See [mistral-cli/README.md](mistral-cli/README.md) for more details on running the Mistral Vibe CLI in an Apptainer container.

## Claude code
- **Description**: Claude Code is an AI-powered code generation tool developed by Anthropic. It uses advanced language models to assist developers in writing code by generating code snippets, providing suggestions, and helping with various coding tasks. Claude Code aims to enhance developer productivity and streamline the coding process by leveraging the capabilities of large language models.
- [Claude code documentation](https://code.claude.com/docs/en/overview)
- It works linked to a consumer claude.ai chat pro account or with the business console.enthropic.com api-key. The first has a fixed limit, predicatable pricing and lower context.
- [Claude ai](https://claude.ai/chat/)
- [Claude api-key](https://platform.claude.com/)
- **Claude Code tests**: See [claude-cli/README.md](claude-cli/README.md) for more details on the tests performed with Claude Code.

### pixi — Python & multi-language environment manager

The Claude Code container includes [pixi](https://pixi.sh), a fast, Rust-based package manager built on conda-forge. It allows you to create reproducible environments with Python, R, and compiled libraries (NumPy, GDAL, NetCDF4, CUDA, etc.) without needing system-level installs. Unlike pip/venv, pixi resolves both Python packages and native dependencies together, making it well suited for scientific and data-heavy projects. Environments are stored inside the project folder and persist across container sessions via `.apptainer-home`. 

```bash
pixi init myproject && cd myproject # initialise a new project
pixi add python numpy xarray # add packages (from conda-forge and PyPI)
pixi run python script.py # run a script inside the environment
```

## Delft3D-FM

[Delft3D-FM](https://github.com/Deltares/Delft3D) is a hydrodynamic modelling suite developed by Deltares. Two containers pair a coding agent with a Delft3D-FM v2.30.2 installation, so the agent can read model input/output, write run scripts, and post-process results directly.

- **claude-delft3d** — Claude Code + Delft3D-FM. See [claude-delft3d/CLAUDE.md](claude-delft3d/CLAUDE.md) for key paths, run commands, and environment setup.
- **copilot-delft3d** — GitHub Copilot CLI + Delft3D-FM. See [copilot-delft3d/CLAUDE.md](copilot-delft3d/CLAUDE.md) for details.

> **Note:** The Delft3D-FM binaries are **not included** in this repository. Before building either Delft3D container, obtain a Delft3D-FM installation and copy it into a folder named `delft3d/` at the root of this repository. The `Apptainer.def` files reference `../delft3d/opt` and the build will fail without it.

Both containers mount the current working directory at `/workspace` and include **pixi** for managing Python post-processing environments (e.g. matplotlib, xarray, netCDF4). The Delft3D binaries live at `/opt/dimrset/bin/` inside the container and are invoked via the provided run scripts:

```bash
# Single-domain flow run
/opt/dimrset/bin/run_dflowfm.sh -- mymodel.mdu

# Coupled DIMR run
/opt/dimrset/bin/run_dimr.sh
```

## Running the containers

Each agent has a dedicated launch script in its folder (e.g. `claude-cli/bash_claude.sh`). The script mounts your current working directory into the container at `/workspace`, sets up an isolated home directory, and drops you into a shell where you can invoke the agent.

```bash
cd /path/to/your/project
/path/to/repo/claude-cli/bash_claude.sh
# then inside the container:
claude
```

All launch scripts share the same behaviour for host-feature passthrough:

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

## Other links
- [apptainer documentation](https://apptainer.org/docs/)
