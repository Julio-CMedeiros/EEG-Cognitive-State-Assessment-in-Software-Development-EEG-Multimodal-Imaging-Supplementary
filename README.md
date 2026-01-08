# EEG Cognitive-State Assessment (MATLAB Supplementary)

This repository contains the MATLAB scripts that supported the preprocessing, artifact rejection, and multimodal correlation analysis published in "EEG as a potential ground truth for the assessment of cognitive state in software development activities: a multimodal imaging study."

## Overview

- Pipeline scripts stitch together artifact cleaning (GA/BCG), filtering, ICA rejection, epoching, and NeuroElf-based correlation analysis.
- Supplemental utilities assist with trigger verification, epoch diagnostics, and figure creation for inspection.
- The supplied files omit participant data; all sensitive inputs live outside this repository for privacy.

## Dependencies

| Tool | Suggested location | Notes |
| --- | --- | --- |
| [EEGLAB 14.1.2](https://sccn.ucsd.edu/eeglab/download.php) | `vendor/eeglab` | Required for dataset operations, ICA, filtering, and plotting.
| [ICLabel plugin (v1.2.5)](https://sccn.ucsd.edu/plugins/iclabel/) | `vendor/eeglab/plugins/ICLabel1.2.5` | Used by `ICA_rejection.m`.
| [NeuroElf](https://neuroelf.net/) | `vendor/neuroelf` | Needed for VOI/BOLD/voxel manipulation and figure generation.
| Rodolfo toolbox | `toolbox_rodolfo` | Zipped version is included; unzip before running the helpers.
| Custom helpers | `vendor/funcoes` | Placeholder for `stacking_*` helpers referenced by `create_figure_overlap.m`.

After downloading each dependency, extract it inside the mentioned folder or set the corresponding environment variables (see below) so the scripts can find them.

## Repository layout

- `project_config.m`: Centralized path configuration used by every script to avoid hard-coded personal paths.
- `.m` scripts: preprocessing phases (`GA_cleaning.m`, `BCG_cleaning.m`, `filtering.m`, `inter_reref.m`, `epoching*.m`, `ICA_*`, etc.), trigger helpers, and NeuroElf analysis.
- `data/`: Placeholder directories for raw inputs, processed outputs, derivatives, and external assets.
- `toolbox_rodolfo.zip`: Zipped Rodolfo helper toolbox that can be extracted into `toolbox_rodolfo/`.
- `triggersinfor.mat`: Example metadata produced by the trigger inspection tools.

## Configuration helper and environment variables

All scripts depend on `project_config.m`. The helper exposes a `cfg` struct with the following configurable roots:

| Env Variable | Default directory inside repo | Description |
| --- | --- | --- |
| `EEG_EEGLAB_PATH` | `vendor/eeglab` | EEGLAB installation used by the scripts. |
| `EEG_NEUROELF_PATH` | `vendor/neuroelf` | NeuroElf toolbox root. |
| `EEG_RODOLFO_PATH` | `toolbox_rodolfo` | Rodolfo helper scripts (zipped version is provided). |
| `EEG_FUNCOES_PATH` | `vendor/funcoes` | Optional helpers used by `create_figure_overlap.m`. |
| `EEG_DATA_RAW` | `data/raw` | Placeholder for raw triggers, BCG sets, etc. |
| `EEG_DATA_PROCESSED` | `data/processed` | Output of NaN cleaning and other derived tables. |
| `EEG_DATA_DERIVATIVES` | `data/derivatives` | Stores HRF maps, final matrices, and neuroimaging outputs. |
| `EEG_DATA_EXTERNAL` | `data/external` | VOI files, VTC images, BOLD time courses, etc. |
| `EEG_DATA_LOGS` | `logs` | Optional log outputs (ICA info, epoch heuristics, etc.). |

`project_config` automatically creates the placeholder directories if they are missing, but you should replace them with actual data files before running. The helper also exposes common trigger-specific directories such as
`cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref.epoching` so scripts can stay portable.

## Data placeholders and privacy

Sensitive EEG or MRI data never appears in this repository. Instead, refer to `data/README.md` for the placeholder topology, and populate those directories locally before running the scripts.

The code intentionally avoids naming any personal drives or machines. If you need to point a script at a different dataset location, set one of the environment variables above rather than editing the script directly.

## Typical processing order

1. **Trigger validation** (`verifying_triggers.m`, `triggers_fixing.m`, `eventos_contagem.m`) ensures the event markers are consistent.
2. **GA and BCG removal** (`GA_cleaning.m`, `BCG_cleaning.m`, `cuttingoff_sec_after_BCG.m`).
3. **Filtering and rereferencing** (`filtering.m`, `inter_reref.m`).
4. **Epoching + Hanning window** (`epoching.m`, `epoching_hanning.m`).
5. **ICA computation + rejection** (`ICA_step.m`, `ICA_rejection.m`, `get_epochs_removed.m`).
6. **Correlation analysis** using NeuroElf (`NeuroElf_CorrelationAnalysis.m`, `dice_coeff_calculation_and_correlation_hrf4.m`, `create_figure_overlap.m`).

Each script reads from the paths exposed by `project_config` and writes results to the placeholder folders (or to custom locations when env vars point elsewhere).

## Running the scripts

1. Install or point to dependencies (EEGLAB, NeuroElf, Rodolfo toolbox, helper functions).
2. Populate the placeholder directories under `data/` with your actual `.set`, `.mat`, `.vmp`, `.voi`, etc., or set the corresponding environment variables.
3. Run `project_config` from MATLAB to confirm paths and log warnings about missing directories.
4. Execute the scripts in the desired order. Most scripts expect to be run from the repository root.

## Output and verification

- Intermediate sets land under `data/raw/analysis/...` (e.g., `BCG/fixed/filtered/inter_reref`).
- Filled datasets go to `data/processed/dataset_filled`.
- Logs (e.g., ICA removal info) are written to `logs/` by default.
- NeuroElf outputs (VOI overlap, correlation matrices) should be stored inside `data/derivatives/mapas_hrf`.

If a script needs to write additional output, update `project_config.m` so it tracks the new location and keep privacy-sensitive files outside the repository.
