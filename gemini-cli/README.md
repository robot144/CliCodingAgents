# Gemini CLI in Apptainer

This folder contains the Apptainer image and helper scripts to run the [Gemini CLI](https://geminicli.com/) in a sandbox. The current working directory is mounted into the container at `/workspace`, and the container home is set to `/workspace/.apptainer-home` so Gemini can write config and cache locally.

## Prerequisites

- [Apptainer](https://apptainer.org/) installed on your system
- A Google account for interactive sign-in, or a Gemini API key from [Google AI Studio](https://aistudio.google.com/)

If you want to use an API key instead of browser sign-in, set it in your shell before running:

```bash
export GEMINI_API_KEY=your_api_key_here
```

## Build the SIF image

From this folder:

```bash
./build_gemini.sh
```

This produces `gemini-cli.sif` in the same directory.

## Run Gemini CLI

From any folder you want to work in, run:

```bash
/path/to/gemini-cli/bash_gemini.sh
```

That folder will be mounted into the container at `/workspace`.

Inside the container:

```bash
gemini
```

On first use, Gemini CLI can open a browser-based Google sign-in flow. In headless or non-interactive setups, use `GEMINI_API_KEY` instead.

## Example: using test_folder

```bash
cd test_folder
GEMINI_API_KEY=your_key ../gemini-cli/bash_gemini.sh
```

## Notes

- Container home: `/workspace/.apptainer-home`
- The `GEMINI_API_KEY` environment variable is forwarded into the container automatically.
- If you want a clean Gemini state, remove the local home folder in your working directory:

```bash
rm -rf .apptainer-home
```
