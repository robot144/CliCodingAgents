# Mistral Vibe CLI in Apptainer

This folder contains the Apptainer image and helper scripts to run the [Mistral Vibe CLI](https://mistral.ai/news/devstral-2-vibe-cli) in a sandbox. The current working directory is mounted into the container at `/workspace`, and the container home is set to `/workspace/.apptainer-home` so the CLI can write config and cache locally.

## Prerequisites

- [Apptainer](https://apptainer.org/) installed on your system
- A Mistral API key (obtain one from [Mistral Studio](https://console.mistral.ai/)) — see also the [Codestral CLI page](https://console.mistral.ai/codestral/cli)

Set your API key in your shell before running:

```bash
export MISTRAL_API_KEY=your_api_key_here
```

## Build the SIF image

From this folder:

```bash
./build_mistral.sh
```

This produces `mistral-cli.sif` in the same directory.

## Run Mistral Vibe CLI

From any folder you want to work in, run:

```bash
MISTRAL_API_KEY=your_key /path/to/mistral-cli/bash_mistral.sh
```

That folder will be mounted into the container at `/workspace`.

Inside the container:

```bash
vibe
```

## Example: using test_folder

```bash
cd test_folder
MISTRAL_API_KEY=your_key ../mistral-cli/bash_mistral.sh
```

## Notes

- Container home: `/workspace/.apptainer-home`
- The `MISTRAL_API_KEY` environment variable is forwarded into the container automatically.
- If you want a clean state, remove the local home folder in your working directory:

```bash
rm -rf .apptainer-home
```
