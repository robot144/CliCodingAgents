# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This workspace runs **Delft3D-FM** (Deltares' hydrodynamic flow and transport modeling system, v2.30.2) inside an Apptainer container (`delft3dfm_2.30.2.sif`). It is not a traditional software project — there is no build system or test suite in this directory.

## Running the Container

```bash
# Interactive shell
apptainer shell delft3dfm_2.30.2.sif

# Execute a single command
apptainer exec delft3dfm_2.30.2.sif <command>
```

## Delft3D-FM Installation (inside container at /opt)

The installation lives at `/opt/dimrset/` (canonical path). `/opt/delft3dfm_latest` is a deprecated symlink — avoid it.

Key paths:
- `/opt/dimrset/bin/` — all executables and run scripts
- `/opt/dimrset/lib/` — shared libraries (set via `LD_LIBRARY_PATH`)
- `/opt/dimrset/share/delft3d/` — data files (`proc_def.dat`, `bloom.spe`, etc.)
- `/opt/intel/mpi/` — Intel MPI (used for parallel runs)

### Key executables

| Binary | Purpose |
|---|---|
| `dflowfm` | D-Flow FM hydrodynamic solver |
| `dimr` | Delta Infrastructure Model Runner — orchestrates coupled models via `dimr_config.xml` |
| `delwaq` | Water quality module |
| `delpar` | Particle tracking |
| `rr` | Rainfall-runoff module |
| `rtc` | Real-time control module |

### Running simulations

Convenience run scripts set `D3D_HOME`, `LD_LIBRARY_PATH`, and OMP/MPI settings automatically:

```bash
# Single-domain D-Flow FM run (from model directory)
/opt/dimrset/bin/run_dflowfm.sh -- mymodel.mdu

# Coupled model run via DIMR (default config: dimr_config.xml)
/opt/dimrset/bin/run_dimr.sh
/opt/dimrset/bin/run_dimr.sh -m custom_config.xml

# Parallel DIMR run (N MPI slots)
/opt/dimrset/bin/run_dimr.sh -c <cores_per_node>
```

The `run_dflowfm.sh` script passes all arguments after `--` directly to `dflowfm`. To call the binary directly, set the environment first:

```bash
export D3D_HOME=/opt/dimrset
export LD_LIBRARY_PATH=$D3D_HOME/lib:$LD_LIBRARY_PATH
$D3D_HOME/bin/dflowfm --nodisplay --autostartstop mymodel.mdu
```

## Package Management

Python, Julia, and other tools are managed via **pixi** (v0.66.0), built on the Conda ecosystem. They are not on PATH by default:

```bash
# Install tools globally
pixi global install julia
pixi global install python

# Or in a project workspace
pixi init
pixi add julia python
pixi run julia script.jl
pixi shell   # activate environment interactively
```

## Documentation

The manuals are available inside the container at `/opt/`:

- `/opt/D-Flow_FM_User_Manual.pdf` — end-user guide
- `/opt/D-Flow_FM_Technical_Reference_Manual.pdf` — technical reference
- Upstream source: https://github.com/Deltares/Delft3D
