%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%FIX triggers 99 manually with notepad eyetracking notes%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all; close all; clc;
cfg = project_config();
addpath(cfg.toolbox.eeglab)
eeglab
load(fullfile(cfg.repo_root,'triggersinfor.mat'))
triggers_dir = cfg.paths.triggers.base;
problems_dir = fullfile(triggers_dir,'problemas');
if ~isfolder(problems_dir)
    mkdir(problems_dir);
end

% 
% %% LOAD
% % files = [5,25]
% for i=25
%     if container_infor{i,3}==99
%         fprintf('Missing trigger 99 in -->>> %s \n',container_infor{i,2})
%         EEG = pop_loadset('filename',container_infor{i,2},'filepath','C:\\Users\\JulioMedeiros\\Desktop\\analysis\\importfiles\\');
%         EEG = eeg_checkset( EEG );
%     end
% end
% %% Event edit 99
% 
% notepad_99=0.0275651174775
% notepad_next_event=30221.2948157;
% EEG_next_event=[656342.840909091];
% 
% duracao=notepad_next_event-notepad_99;
% 
% EEG = pop_editeventvals(EEG,'insert',{1 [] [] []},'changefield',{1 'type' 99},'changefield',{1 'latency' 1/10000});
% EEG = eeg_checkset( EEG );
% 
% %% SAVE fixed
% EEG = pop_saveset( EEG, 'filename',container_infor{i,2},'filepath','C:\\Users\\JulioMedeiros\\Desktop\\analysis\\importfiles\\triggers\\');
% EEG = eeg_checkset( EEG );
% clear notepad_99; clear notepad_next_event; clear EEG_next_event; clear duracao
% 
% %% SAVE non fixed
% EEG = pop_saveset( EEG, 'filename',container_infor{i,2},'filepath','C:\\Users\\JulioMedeiros\\Desktop\\analysis\\importfiles\\triggers\\problemas');
% EEG = eeg_checkset( EEG );
% clear notepad_99; clear notepad_next_event; clear EEG_next_event; clear duracao


%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%FIX triggers 99 manually with notepad eyetracking notes%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

files = [1,2,3,4,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,26,27,28,29,30,31];

for i=27:length(files)
    i
    if container_infor{files(i),3}==15
        fprintf('Missing %d triggers 15 in \n -->>> %s \n',(3-container_infor{files(i),4}),container_infor{files(i),2})
        EEG = pop_loadset('filename',container_infor{files(i),2},'filepath',triggers_dir);
        EEG = eeg_checkset( EEG );
    end


%%% Event edit 15

missing=input('N� of 15 triggers missing?');

if missing ~= 0
    notepad_inicio_event=input('notepad_inicio_event: ');
    for mm=1:missing
        notepad_15=input('notepad_15: ');
        
        eventos={EEG.event.type};
        log_idx=strcmp(eventos,'99');
        idx=find(log_idx==1);
        EEG_inicio_event= EEG.event(idx).latency;
        
        duracao=notepad_15-notepad_inicio_event;
        
        EEG = pop_editeventvals(EEG,'insert',{1 [] [] []},'changefield',{1 'type' 15},'changefield',{1 'latency' [EEG_inicio_event+duracao*10]/10000});
        EEG = eeg_checkset( EEG );

    end
end

gravar=input('Save fixed (1) or Save problem (0):');

if gravar==1
    %%SAVE fixed
    EEG = pop_saveset( EEG, 'filename',container_infor{files(i),2},'filepath',triggers_dir);
    EEG = eeg_checkset( EEG );
    clear notepad_15; clear notepad_inicio_event; clear EEG_inicio_event; clear duracao
    
elseif gravar==0
    %%SAVE non fixed
%     EEG = pop_saveset( EEG, 'filename',container_infor{i,2},'filepath','C:\\Users\\JulioMedeiros\\Desktop\\analysis\\importfiles\\triggers\\problemas');
%     EEG = eeg_checkset( EEG );
    status=movefile(fullfile(triggers_dir,container_infor{files(i),2}),problems_dir);
    status=movefile(fullfile(triggers_dir,[container_infor{files(i),2}(1:end-4) '.fdt']),problems_dir);
    clear notepad_15; clear notepad_inicio_event; clear EEG_inicio_event; clear duracao
end
end