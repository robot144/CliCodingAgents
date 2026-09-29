@AGENTS.md

# test_marker

Testbed for [marker](https://github.com/datalab-to/marker), a PDF-to-markdown converter with support for formulas (LaTeX), tables and figures.

We work inside a container that has `pixi` preinstalled; Python and all dependencies are installed through pixi (no system pip/conda). The goal is a set of scripts that automate installing and using marker.

## Status

- Basics work: `pfaff2021_meshgraphnet.pdf` converts correctly on CPU (see `output/`).
- `install_marker-pdf.sh` / `uninstall_marker-pdf.sh` round-trip tested in scratch dirs: fresh empty dir (~10 min first time, ~1 min with warm pixi cache), `pixi.toml` with an existing `[activation.env]`, and a plain `pyproject.toml`. Uninstall intentionally leaves `python` and any pixi config that `pixi init` added.
- The project's `pixi.toml` is now the one `install_marker-pdf.sh` generated (Python 3.12, libgomp, marker-pdf, `[activation.env]`); the old stray `pip` is gone.
- Models (cached in `~/.cache/huggingface/hub`): llama-server runs the `datalab-to/surya-ocr-2-gguf` VLM (`surya-2.gguf` 1.2 GB + `surya-2-mmproj.gguf` vision projector 196 MB); layout/reading order uses `datalab-to/surya_layout2` (136 MB) via PyTorch.
- `D-Flow_FM_User_Manual.pdf` (large manual) has not been converted yet.

## Clean-slate install test (done 2026-09-29): passed

The pixi env, manifest, `bin/`, package caches and models were deleted from the host, then the container was restarted.

- Bootstrap: created a default `pixi.toml` (`python >=3.10,<3.14`) and installed Python 3.13.15.
- `./install_marker-pdf.sh`: 599 s, ended with `marker_single OK`, and re-pinned Python to 3.12.14. No errors.
- `./pdf2md.sh pfaff2021_meshgraphnet.pdf`: 518 s including the first-run model download; `diff -r` against `output/pfaff2021_meshgraphnet/` was identical.
- Cleanup slip: `output/` had been deleted instead of `pfaff2021_meshgraphnet/`. The leftover run was copied back to `output/` as the reference before the test.
- Cache sizes after the test: rattler 6.2 GB, huggingface 1.6 GB, datalab 262 MB.

## Formula test: `wickle_bayesian_tutorial.pdf` (2026-09-29)

Converted to `wickle_bayesian_tutorial/`. It took 73 min for 16 pages, because the paper has ~95 display equations at ~45 s each on 4 CPUs. There were 2 VLM timeouts. Separately, marker drops the last text block at the bottom of columns; e.g. the start of section 4.3.1 is lost, and this is reproducible without timeouts. Display math is good LaTeX with occasional OCR errors, but inline math is not LaTeX: it is PDF text with `<sup>`, and primes show up as `0`. Details are in `marker-pdf.md` under Performance.

Speed: this VM (VirtualBox 7.1.6 on Windows, 4 vCPU of an i7-11800H) runs in Hyper-V "snail" mode without AVX, so llama.cpp uses its SSE4.2 fallback; see `marker-pdf.md`. Planned (2026-09-29): upgrade VirtualBox to 7.2.x (+ more vCPUs), and test on a more powerful native Linux laptop. Benchmark: `time ./pdf2md.sh wickle_bayesian_tutorial_page9.pdf` (page 9 cut out; baseline on this VM 382 s wall, table in `marker-pdf.md`), plus `grep -o -w 'avx2\|fma\|f16c' /proc/cpuinfo | sort -u`.

Possible next steps: try `--force_ocr` on a few pages to see whether inline math improves; look into the llama-server timeout/thread settings; convert `D-Flow_FM_User_Manual.pdf` (large; try `--page_range` first).

Note: `CLAUDE.md` used to be a symlink to `AGENTS.md`. If the bootstrap turns it back into one, this file's content is lost; the same notes are in `marker-pdf.md`.

## Files

- `marker-pdf.md` — collected notes: installation gotchas, llama-server backend, output layout, performance. Keep it up to date with new findings.
- `install_marker-pdf.sh [dir]` — idempotent install: pixi manifest (reuses `pixi.toml`/`pyproject.toml` if present), deps, llama.cpp binary download, `[activation.env]` for `LLAMA_CPP_BINARY`/`LD_LIBRARY_PATH`.
- `uninstall_marker-pdf.sh [--models] [dir]` — reverses the install (deps, activation env lines, `bin/llama-*`); `--models` also deletes the ~1.8 GB model caches.
- `pdf2md.sh input.pdf [marker_single flags...]` — convert one PDF; output goes next to it (`docs/foo.pdf` → `docs/foo/foo.md`) unless `--output_dir` is given. Tested.
- `bin/llama-<tag>/` — prebuilt llama.cpp release (CPU inference backend); not from conda-forge.
- `output/<name>/` — conversion results (`<name>.md`, `<name>_meta.json`, `_page_N_*.jpeg`).

## Key facts

- Python must be 3.12: marker-pdf pins pillow 10.4, which has no wheels for newer Pythons.
- marker-pdf comes from PyPI (`pixi add --pypi`); `libgomp` from conda-forge is needed by `llama-server`.
- marker (via `surya`) finds llama-server through `LLAMA_CPP_BINARY` or `PATH`.
- First run downloads models from Hugging Face (`HF_TOKEN` optional).
- Full conversion is slow on CPU (~4.5 min for 18 pages); use `--page_range 0` for quick tests.
