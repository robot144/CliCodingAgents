# Codex CLI in Apptainer

This folder contains the Apptainer image and helper scripts to run the OpenAI Codex CLI in a sandbox. The current working directory is mounted into the container at `/workspace`, and the container home is set to `/workspace/.apptainer-home` so Codex can write config and cache locally.

## Build the SIF image

From this folder:

```bash
./build_codex.sh
```

This produces `codex-cli.sif` in the same directory.

## Run Codex CLI

From any folder you want to work in, run:

```bash
/path/to/codex-cli/bash_codex.sh
```

That folder will be mounted into the container at `/workspace`.

Inside the container:

```bash
codex
```

The first time you run Codex, you will be prompted to sign in — authenticate with your ChatGPT account or an API key.

## Example: using test_folder

```bash
cd test_folder
../bash_codex.sh
```

## Notes

- Container home: `/workspace/.apptainer-home`
- If you want a clean Codex state, remove the local home folder in your working directory:

```bash
rm -rf .apptainer-home
```
