# Data Placeholders and Privacy Guidance
This repository ships **only code and metadata**. All participant data, preprocessed EEG sets, MR maps, and other recordings are considered private and must stay outside the repository. This folder exists so scripts can resolve the path structure without embedding personal paths.

## Current layout
- `raw/analysis/importfiles/triggers/GA/1000QRS/...` keeps the triggers-processing pipeline hierarchy (GA, BCG, filtering, etc.).
- `raw/dataset` is where the original feature `.mat` files should land.
- `processed/dataset_filled` is the default target for `filling_NaN_percentage_rule.m` output.
- `derivatives/mapas_hrf` hosts NeuroElf outputs and HRF maps.
- `external/` contains non-EEG artifacts such as VOI files, VTC derivatives, and BOLD time courses.

## How to load or replace the placeholders
1. Populate these folders on your local machine (or point the scripts elsewhere) before running any pipeline script.
2. You can also export private data outside this repo and point each script to it via the environment variables documented in `project_config.m` (e.g. `EEG_DATA_RAW`, `EEG_EEGLAB_PATH`).
3. Do **not** commit actual `.set`, `.mat`, `.vmp`, `.voi`, or other sensitive files. Only share derivative summaries or aggregated figures.
4. If you need to change the structure, update `project_config.m` so every script reuses the new layout.
