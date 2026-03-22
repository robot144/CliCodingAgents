
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
- Copilot CLI: tested and working in the apptainer container. Others: not even started yet.

## Agents

## Copilot cli
- **Description**: Copilot CLI is a command-line interface that allows developers to interact with GitHub Copilot, an AI-powered code completion tool. It provides a way to use Copilot's capabilities directly from the terminal, enabling developers to generate code snippets, get suggestions, and perform various coding tasks without leaving the command line.
- [into copilot-cli](https://developer.microsoft.com/blog/get-started-with-github-copilot-cli-a-free-hands-on-course)
- [copilot-cli on github](https://github.com/github/copilot-cli)
- **copilot-cli tests**: See [copilot-cli/README.md](copilot-cli/README.md) for more details on the tests performed with copilot-cli.

## Claude code
- **Description**: Claude Code is an AI-powered code generation tool developed by Anthropic. It uses advanced language models to assist developers in writing code by generating code snippets, providing suggestions, and helping with various coding tasks. Claude Code aims to enhance developer productivity and streamline the coding process by leveraging the capabilities of large language models.
 - [Claude code documentation](https://code.claude.com/docs/en/overview)

## ChatGPT codex-cli
- **Description**: ChatGPT Codex CLI is a command-line interface that allows developers to interact with OpenAI's Codex, an AI model designed for code generation and understanding. It provides a way to use Codex's capabilities directly from the terminal, enabling developers to generate code snippets, get suggestions, and perform various coding tasks without leaving the command line.
- [ChatGPT Codex CLI documentation](https://developers.openai.com/codex/cli/)
- **ChatGPT Codex CLI tests**: See [chatgpt-codex-cli/README.md](chatgpt-codex-cli/README.md) for more details on the tests performed with ChatGPT Codex CLI.

## Aider
- **Description**: Aider is an AI-powered code assistant that helps developers with various coding tasks, such as code generation, code review, and debugging. It uses advanced language models to understand the context of the code and provide relevant suggestions and assistance. Aider aims to enhance developer productivity and streamline the coding process by leveraging the capabilities of large language models.
- [Homepage Aider](https://aider.chat/)


## Other links
- [apptainer documentation](https://apptainer.org/docs/)