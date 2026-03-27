
# CliCodingAgents

Recently (2026), there has been a surge in interest in using large language models (LLMs) to automate coding tasks. This repository contains a collection of agents that utilize LLMs to perform various coding-related tasks, such as code generation, code review, and debugging. There are several agents that can be used for different purposes, and they are designed to be easy to use and integrate into existing workflows. There are also several ways to interact with the agents, such as with a plugin in vscode, from the github.com page, or with a command line interface (CLI). 

In this repository, the aim is to test a few agents and see how well they perform on various coding tasks. 

## A word of caution

Agents that utilize LLMs can be powerful tools, but if you accept to run a command, then a small mistake can cause a lot of damage. All of the agents discussed here have safeguards in place to prevent them from causing harm, but it is still important to be cautious when using them. Always review the commands that the agents generate before running them, and make sure that you understand what they do. If you are unsure about a command, it is best to err on the side of caution and not run it. My suggestion would be to use the agents only on a folder that is linked to a repository, so that you can easily revert any changes that the agents make, or just revert to the previous commit if you are using git. Still, this is not a guarantee that the agents will not cause any damage, so it is important to be vigilant and cautious when using them. Always keep in mind that the agents are just tools, and it is up to you to use them responsibly and safely.

Being a cautious creature, we here create a safe and controlled environment for testing, the agents are run in a sandboxed environment. This allows us to evaluate their performance without risking any damage to the system or data. We use apptainer to create and manage the sandboxed environment, which provides a secure and isolated environment for running the agents. This can make it harder to run code from the agents, but it also ensures that the agents cannot cause any harm to the system or data, outside the folder that we share with the container.

Another concern voiced is that all LLMs that you call with an api, will have access to the data that you share with them, and that they may use this data for training or other purposes. This is a valid concern, and it is important to be aware of the privacy implications of using these agents. It is always a good idea to review the privacy policies of the agents and the LLMs that they use, and to be cautious about sharing sensitive data with them. If you are concerned about privacy, you may want to consider using agents that allow you to run your own instance of the LLM, or that have strict privacy policies in place.

## Pre-requisites
- apptainer installed on the system
- access to the agents (e.g., copilot cli, claude code, chatgpt codex-cli, aider) This may require signing up for an account and obtaining an API key, depending on the agent.

## Status
- Copilot CLI: tested and working in the apptainer container.
- ChatGPT Codex CLI: tested and working in the apptainer container.
- Mistral Vibe CLI: tested and working in the apptainer container.
- Claude Code: tested and working in the apptainer container.
- **pixi** added to the Claude Code container for Python and multi-language environment management.
  - We aim to add pixi to the other containers as well, but for now it is only available in the Claude Code container. The first tests look promising, and it seems to work well in the container. It is a great tool for managing Python environments, and it can be used to create isolated environments for testing different versions of packages or for testing code that has different dependencies.

## Agents

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

## Other links
- [apptainer documentation](https://apptainer.org/docs/)
