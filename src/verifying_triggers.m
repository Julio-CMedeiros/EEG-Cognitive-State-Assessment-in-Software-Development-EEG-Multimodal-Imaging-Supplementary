cfg = project_config();
addpath(cfg.toolbox.eeglab);
eeglab
clear all; close all; clc

triggers_dir = cfg.paths.triggers.base;
cd(triggers_dir)

files=dir(fullfile(triggers_dir,'*.set'));

container_infor={};
container_99_files=[];
container_15_files=[];

contador=0;

for i=1:length(files)
    
    name_file=files(i).name;
    EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
        EEG = pop_loadset('filename',name_file,'filepath',triggers_dir);
    EEG = eeg_checkset( EEG );
    
    if sum(ismember({EEG.event.type},'99'))==0
        contador=contador+1;
        container_infor{contador,1}=i;
        container_infor{contador,2}=name_file;
        container_infor{contador,3}=99;
        container_99_files=[container_99_files;i]
    end
    
    if sum(ismember({EEG.event.type},'15'))<3
        contador=contador+1;
        container_infor{contador,1}=i;
        container_infor{contador,2}=name_file;
        container_infor{contador,3}=15;
        container_infor{contador,4}=sum(ismember({EEG.event.type},'15'));
        container_15_files=[container_15_files;i];
    end
end

save(fullfile(cfg.repo_root,'triggersinfor.mat'),'container_infor','container_99_files','container_15_files')

