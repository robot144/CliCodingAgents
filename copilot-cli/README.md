# Copilot CLI in Apptainer

This folder contains the Apptainer image and helper scripts to run GitHub Copilot CLI in a sandbox. The current working directory is mounted into the container at `/workspace`, and the container home is set to `/workspace/.apptainer-home` so Copilot can write config and cache locally.

## Build the SIF image

From this folder:

```bash
./build_copilot.sh
```

This produces `copilot-cli.sif` in the same directory.

## Run Copilot CLI

From any folder you want to work in, run:

```bash
/path/to/copilot-cli/bash_copilot.sh
```

That folder will be mounted into the container at `/workspace`.

Inside the container:

```bash
copilot
```

## Example: using test_folder

```bash
cd test_folder
../bash_copilot.sh
```

## Notes

- Container home: `/workspace/.apptainer-home`
- If you want a clean Copilot state, remove the local home folder in your working directory:

```bash
rm -rf .apptainer-home
```
