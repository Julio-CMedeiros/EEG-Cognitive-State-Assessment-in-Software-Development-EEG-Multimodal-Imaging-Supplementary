function cfg = project_config()
% PROJECT_CONFIG centralizes all workspace paths and placeholders.
%   Use this helper to refer to toolboxes, data, and derivative folders without
%   embedding any personal or machine-specific paths in the analysis scripts.

    persistent cfg_cache;
    if ~isempty(cfg_cache)
        cfg = cfg_cache;
        return;
    end

    repo_root = fileparts(mfilename('fullpath'));
    cfg.repo_root = repo_root;

    cfg.toolbox.eeglab = resolve_path('EEG_EEGLAB_PATH', fullfile(repo_root, 'vendor', 'eeglab'));
    cfg.toolbox.neuroelf = resolve_path('EEG_NEUROELF_PATH', fullfile(repo_root, 'vendor', 'neuroelf'));
    cfg.toolbox.rodolfo = resolve_path('EEG_RODOLFO_PATH', fullfile(repo_root, 'toolbox', 'rodolfo'));
    cfg.toolbox.funcoes = resolve_path('EEG_FUNCOES_PATH', fullfile(repo_root, 'vendor', 'funcoes'));
    cfg.project_main_scripts = resolve_path('EEG_PROJECT_SCRIPTS', fullfile(repo_root, 'src'));

    addpath(cfg.toolbox.rodolfo);
    addpath(cfg.project_main_scripts);

    cfg.data.raw = resolve_path('EEG_DATA_RAW', fullfile(repo_root, 'data', 'raw'));
    cfg.data.processed = resolve_path('EEG_DATA_PROCESSED', fullfile(repo_root, 'data', 'processed'));
    cfg.data.derivatives = resolve_path('EEG_DATA_DERIVATIVES', fullfile(repo_root, 'data', 'derivatives'));
    cfg.data.external = resolve_path('EEG_DATA_EXTERNAL', fullfile(repo_root, 'data', 'external'));
    cfg.data.logs = resolve_path('EEG_DATA_LOGS', fullfile(repo_root, 'logs'));

    cfg.files.eegcoordsystem = fullfile(cfg.data.external, 'EEGcoordsystem.mat');
    cfg.files.features_name = fullfile(cfg.data.external, 'features_name_from_files_read.mat');
    cfg.files.triggersinfor = fullfile(cfg.data.external, 'triggersinfor.mat');
    cfg.files.voisSuspvsBaseline = fullfile(cfg.data.external, 'voisSuspvsBaseline.voi');

    triggers_base = ensure_folder(fullfile(cfg.data.raw, 'analysis', 'importfiles', 'triggers'));
    cfg.paths.triggers.base = triggers_base;
    cfg.paths.triggers.GA1000QRS.base = ensure_folder(fullfile(triggers_base, 'GA', '1000QRS'));
    cfg.paths.triggers.GA1000QRS.BCG = ensure_folder(fullfile(cfg.paths.triggers.GA1000QRS.base, 'BCG'));
    cfg.paths.triggers.GA1000QRS.BCG.fixed = ensure_folder(fullfile(cfg.paths.triggers.GA1000QRS.BCG, 'fixed'));
    cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered = ensure_folder(fullfile(cfg.paths.triggers.GA1000QRS.BCG.fixed, 'filtered'));
    cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref = ensure_folder(fullfile(cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered, 'inter_reref'));
    cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref.epoching = ensure_folder(fullfile(cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref, 'epoching'));
    cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref.epoching.ICAcomp = ensure_folder(fullfile(cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref.epoching, 'ICAcomp'));
    cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref.epoching.ICAcomp.ICA = ensure_folder(fullfile(cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref.epoching.ICAcomp, 'ICA'));

    cfg.paths.voi = ensure_folder(fullfile(cfg.data.external, 'voi'));
    cfg.paths.bold.vtc = ensure_folder(fullfile(cfg.data.external, 'vtc', 'vtc'));
    cfg.paths.bold.timecourses = ensure_folder(fullfile(cfg.data.external, 'BOLD_timecourses', 'BOLD_timecourses'));
    cfg.paths.bold.maps = ensure_folder(fullfile(cfg.data.derivatives, 'mapas_hrf'));
    cfg.paths.neuroelf.voxel = ensure_folder(fullfile(cfg.paths.bold.maps, 'voxel'));

    cfg.paths.logs = ensure_folder(cfg.data.logs);

    cfg_cache = cfg;
end

function path = resolve_path(env_name, default_path)
    % If env_name is set, prefer it. Otherwise build the fallback and prepare it.
    candidate = getenv(env_name);
    if ~isempty(candidate)
        if isfolder(candidate)
            path = candidate;
            return;
        end
        warning('ENV %s set to %s but that folder does not exist; falling back to %s.', env_name, candidate, default_path);
    end
    path = ensure_folder(default_path);
end

function folder = ensure_folder(folder)
    if ~isfolder(folder)
        mkdir(folder);
    end
end