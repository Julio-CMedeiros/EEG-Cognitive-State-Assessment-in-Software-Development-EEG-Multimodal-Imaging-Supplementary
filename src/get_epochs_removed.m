% clear all; close all; clc
close all, clc
cfg = project_config();
addpath(cfg.toolbox.eeglab)
addpath(genpath(cfg.toolbox.rodolfo))
eeglab
%
input_dir = cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref;
cd(input_dir)
files=dir(fullfile(input_dir,'*.set'));
infor

for i=1:length(files)
    tic
    filename=files(i).name;
    disp(">>>>>>>>>>>")
    disp(strcat(">>>>>>",{' '},filename,{' '},'<<<<<<'))
    disp(">>>>>>>>>>>")
    EEG = pop_loadset('filename',filename,'filepath',fullfile(input_dir,'epoching'));
    EEG = eeg_checkset(EEG);
    output=EEG.epochsremovidos;
    container=[i,




fileID = fopen(fullfile(cfg.paths.logs,'epoching_infor.txt'),'a+');
fprintf(fileID,strcat(filename,' >>>>> e removed(',num2str(EEG.epochsremovidos),'): ',num2str(rem),' \n'));
fclose(fileID);
end