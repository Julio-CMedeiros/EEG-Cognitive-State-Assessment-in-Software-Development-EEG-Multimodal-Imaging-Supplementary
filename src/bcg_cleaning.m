% ----------------------------------------------
% Script Name: bcg_cleaning.m
% Author: Julio Medeiros
% Email: juliomedeiros@dei.uc.pt
% Institution: University of Coimbra (UC), Centre for Informatics and Systems of the University of Coimbra (UC)
% Date: 10/09/2023
% Description: This script is used to preprocess Ballistocardiogram (BCG) from the EEG data using EEGLAB using EEGLAB with the FMRIB Plug-in.
% ----------------------------------------------

% ----------------------------------------------
% ----------------------------------------------
% Add the necessary paths and initialize EEGLAB
% ----------------------------------------------
cfg = project_config();
addpath(cfg.toolbox.eeglab);
eeglab;

base_dir = cfg.paths.triggers.GA1000QRS.base;
bcg_save_dir = cfg.paths.triggers.GA1000QRS.BCG;
if ~isfolder(bcg_save_dir)
    mkdir(bcg_save_dir);
end

cd(base_dir);

% ----------------------------------------------
% List EEG data files in the directory
% ----------------------------------------------
files = dir(fullfile(base_dir, '*.set'));

% ----------------------------------------------
% Loop through each EEG data file for preprocessing
% ----------------------------------------------
for i = 1:length(files)
    filename = files(i).name;

    % Load the EEG data
    EEG = pop_loadset('filename', filename, 'filepath', base_dir);

    % Preprocess EEG data
    EEG = eeg_checkset(EEG);
    EEG = pop_fmrib_pas(EEG, 'qrs', 'obs', 3);
    EEG = eeg_checkset(EEG);

    % Update file name
    EEG.setname = strcat(filename(1:end-4), '_BCG');

    % Save the preprocessed EEG data
    EEG = pop_saveset(EEG, 'filename', strcat(EEG.setname, '.set'), 'filepath', bcg_save_dir);
    EEG = eeg_checkset(EEG);
end
