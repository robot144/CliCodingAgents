# Claude Code in Apptainer

This folder contains the Apptainer image and helper scripts to run Claude Code in a sandbox. The current working directory is mounted into the container at `/workspace`, and the container home is set to `/workspace/.apptainer-home` so Claude Code can write config and cache locally.

## Build the SIF image

From this folder:

```bash
./build_claude.sh
```

This produces `claude-cli.sif` in the same directory.

## Run Copilot CLI

From any folder you want to work in, run:

```bash
/path/to/claude-cli/bash_claude.sh
```

That folder will be mounted into the container at `/workspace`.

Inside the container:

```bash
claude
```

## Example: using test_folder

```bash
cd test_folder
../bash_claude.sh
```

## Notes

- Container home: `/workspace/.apptainer-home`
- If you want a clean Claude Code state, remove the local home folder in your working directory:

```bash
rm -rf .apptainer-home
```
