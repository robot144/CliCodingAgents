# marker-pdf

[marker](https://github.com/datalab-to/marker) is a PDF-to-markdown converter by datalab.

## Quick start

```bash
./install_marker-pdf.sh            # set up pixi env + llama.cpp in the current dir
./pdf2md.sh input.pdf              # -> input/input.md next to the PDF
```

`install_marker-pdf.sh [dir]` can be re-run safely. It reuses an existing `pixi.toml` or `pyproject.toml` (or creates a `pixi.toml`), adds the dependencies, downloads llama.cpp if missing, configures the activation env and checks the install. Tested on a fresh empty directory (~10 min, mostly downloading PyTorch). Clean-slate test on 2026-09-29 (no env, no caches, no models; bootstrap had created a default `pixi.toml` with Python 3.13): install took 599 s and pinned Python to 3.12.14, and the first conversion reproduced the reference output exactly.

`uninstall_marker-pdf.sh [--models] [dir]` reverses it: it removes marker-pdf and libgomp, the two activation-env lines and `bin/llama-*`. It keeps `python`, any pixi config that `pixi init` added and all converted output. `--models` also deletes the downloaded models (~1.8 GB). Round-trip tested on a fresh dir, a `pixi.toml` with an existing `[activation.env]` and a plain `pyproject.toml`.

`pdf2md.sh input.pdf [marker_single options...]` passes extra options through to `marker_single`; `./pdf2md.sh --help` lists them.

## Installation (manual)

marker-pdf is not available on conda-forge, so it is installed from PyPI via pixi's `pypi-dependencies`.

**Python version:** Python 3.14 is too new. marker-pdf pins `pillow` 10.4, which has no pre-built wheels for newer Pythons, and the source build fails. Use Python 3.12.

`libgomp` must be added from conda-forge so the `llama-server` inference binary can find `libgomp.so.1` at runtime.

```bash
pixi init .
pixi add "python>=3.12,<3.13" libgomp
pixi add --pypi marker-pdf
```

The resulting `pixi.toml`, including the activation env from the [Usage](#usage) section:

```toml
[workspace]
channels = ["conda-forge"]
name = "test_marker"
platforms = ["linux-64"]
version = "0.1.0"

[dependencies]
python = ">=3.12,<3.13"
libgomp = ">=16.2.0,<17"

[pypi-dependencies]
marker-pdf = ">=2.0.0, <3"

[activation.env]
LLAMA_CPP_BINARY = "$PIXI_PROJECT_ROOT/bin/llama-b11228/llama-server"
LD_LIBRARY_PATH = "$CONDA_PREFIX/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
```

`pip` is not needed; an earlier manual setup also had it, but nothing depends on it.

Reproduce the environment on another machine:

```bash
pixi install
```

## CPU inference backend: llama-server

On Linux without a GPU, marker uses `llama-server` from [llama.cpp](https://github.com/ggml-org/llama.cpp). There is no conda-forge package, so download the pre-built binary from the releases page (x86_64 only):

```bash
# Replace b11228 with the latest release tag
mkdir -p bin
curl -fL https://github.com/ggml-org/llama.cpp/releases/download/b11228/llama-b11228-bin-ubuntu-x64.tar.gz \
  | tar -xz -C bin
```

This extracts to `bin/llama-b11228/`. Keep `bin/` out of version control, since it holds about 100 MB of binaries.

marker finds the binary through its `surya` dependency, which uses `LLAMA_CPP_BINARY` or otherwise looks for `llama-server` on `PATH`.

## Models

Downloaded from Hugging Face on first run into `~/.cache/huggingface/hub`. An `HF_TOKEN` is optional but raises rate limits.

| Model | Size | Runs on | Role |
|---|---|---|---|
| `datalab-to/surya-ocr-2-gguf`: `surya-2.gguf` | 1.2 GB | llama-server | vision-language model (OCR, text) |
| `datalab-to/surya-ocr-2-gguf`: `surya-2-mmproj.gguf` | 196 MB | llama-server | vision projector for the model above |
| `datalab-to/surya_layout2` | 136 MB | PyTorch | layout detection and reading order |

Override the GGUF files with `SURYA_GGUF_LOCAL_MODEL_PATH` / `SURYA_GGUF_LOCAL_MMPROJ_PATH` (see `surya/settings.py`).

## Usage

With the `[activation.env]` section above, `pixi run` sets `LLAMA_CPP_BINARY` and `LD_LIBRARY_PATH` automatically:

```bash
pixi run marker_single input.pdf --output_dir ./output
```

Without it, export them yourself. Use absolute paths and keep any existing `LD_LIBRARY_PATH`:

```bash
export LLAMA_CPP_BINARY="$PWD/bin/llama-b11228/llama-server"
export LD_LIBRARY_PATH="$PWD/.pixi/envs/default/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
```

`pdf2md.sh` sets both variables if needed, so it works with either setup.

Use `--page_range 0` for a quick one-page test.

## Output

For each converted PDF, marker writes a subdirectory `<name>/` under `--output_dir` containing:

- `<name>.md`: converted markdown (equations as LaTeX `$$…$$`, tables as markdown tables)
- `<name>_meta.json`: metadata (table of contents, per-page block counts)
- `_page_N_*.jpeg`: extracted figures and diagrams

Without `--output_dir`, `marker_single` writes inside its own install directory. `pdf2md.sh` defaults to the PDF's directory instead, so `docs/foo.pdf` becomes `docs/foo/foo.md`.

## Performance

Tested on `pfaff2021_meshgraphnet.pdf` (18 pages, math-heavy ML paper), CPU only:

- ~4.5 minutes (263 s) for the full document; one page takes ~20 s including llama-server startup
- 5 tables detected and processed
- 11 images extracted
- The output was identical across two runs, and again after a clean-slate reinstall (2026-09-29)
- First run after a clean install: 518 s wall time (marker reports 497 s), including downloading the ~1.8 GB of models

Tested on `wickle_bayesian_tutorial.pdf` (16 pages, formula-heavy statistics paper), CPU only, 4 cores, models cached (2026-09-29):

- **73 minutes** (4376 s) for the full document. The paper has about 95 display equations; pfaff has almost none. Each display equation is recognised by the VLM in llama-server, so it costs roughly 45 s on this machine.
- Two `Inference error: Request timed out.` messages; the run still exits 0. It is unclear what the timeouts lost. The missing start of section 4.3.1 is *not* caused by them; see the single-page benchmark below.

Single-page benchmark: `wickle_bayesian_tutorial_page9.pdf` (page 9 of the paper, 10 display equations), timed with `time ./pdf2md.sh wickle_bayesian_tutorial_page9.pdf`. Use it to compare machines.

| Machine | Wall time | marker total | Notes |
|---|---|---|---|
| VM: VirtualBox 7.1.6 "snail" mode, 4 vCPU i7-11800H, no AVX (2026-09-29) | 382 s | 364 s | no timeouts |

The output is deterministic. It reproduces the same equation errors as the full run (`\mathbf{y}_{:t}` in (35), wrong δ subscript), and it **drops the last text block at the bottom of both columns**: left, "Thus, given a sample from p(x0), … Applying (33) for this"; right, the heading "4.3.1. Particle filtering" and the two lines after it. This happens without any timeout, so it is a layout/block problem, not an inference failure.

Formula quality:

- Display equations come out as good LaTeX: fractions, sums, products, `\begin{aligned}`, bold matrices, `\begin{pmatrix}` numeric matrices, `\tag`/`\quad (n)` equation numbers.
- A few display equations have OCR errors: a spurious extra matrix entry, `(c_{12} - c_{13})` for the row vector `(c_{12}\ c_{13})`, `\mathbf{y}_{:t}` for `\mathbf{y}_{1:t}`, a wrong δ subscript.
- Some equations with an equation number are wrapped in a markdown table. There the `|` of `X|y` is taken as a column separator and lost, e.g. `$\text{var}(X \mathbf{y}) = (1 - K)\tau^2,$ | (4)`.
- Inline math is not converted: text comes from the PDF text layer (`pdftext`, no OCR) and is written as italic text plus `<sup>`. Primes become `0` (`Y'` → `(...) 0`, `PH'` → `PH<sup>0</sup>`), `∫` → `R`, `Σ` → `P`, and `τ²` splits into `τ <sup>2</sup>` or `τ 2`. `--force_ocr` may fix this, which is untested and likely much slower.
- Figure captions are separated from their images and heading levels (`#` to `####`) are inconsistent.
- **This test machine has no AVX.** It is a 4-vCPU VM on an i7-11800H, and `/proc/cpuinfo` shows only SSE4.2; the host CPU itself has AVX2 and AVX-512. As a result llama.cpp can only use its slowest CPU code path (`libggml-cpu-sse42.so`), and PyTorch reports CPU capability `DEFAULT` instead of `AVX2`. Exposing AVX to the VM and giving it more cores is probably the cheapest speed-up. The installed PyTorch is a CUDA build (`2.14.0+cu130`), but the llama.cpp release binary is CPU-only; a GPU run needs a CUDA or Vulkan llama.cpp build.
- The host runs Windows with VirtualBox 7.1.6. With Hyper-V active on the host (green turtle icon; Machine → Session Information → Runtime Information shows the execution engine), VirtualBox before 7.1.12 cannot expose AVX/AVX2 to the guest. 7.1.12 added AVX/AVX2 under Hyper-V (github gh-36), and 7.2.0 added x86_64-v3 (AVX, AVX2) via xsave handling. So upgrading VirtualBox is the easiest fix, and WSL2/Docker keep working.
- Confirmed in `VBox.log` (2026-09-29): `NEM: NEMR3Init: Snail execution mode is active!` (VirtualBox is running on top of Hyper-V) and `AVX - AVX support = 0 (1)` (VM value, host value in parentheses). The VM config itself is clean: CPU profile `host`, `PortableCpuIdLevel 0`, no `CPUM/IsaExts` overrides.
