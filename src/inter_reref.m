cfg = project_config();
EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it
addpath(genpath(cfg.toolbox.rodolfo))
addpath(genpath(cfg.repo_root))

base_dir = cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered;
output_dir = cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref;
if ~isfolder(output_dir)
    mkdir(output_dir);
end

cd(base_dir)

files = dir(fullfile(base_dir, '*.set'));
chans={'O2','O1','OZ','PZ','P4','CP4','P8','C4','TP8','T8','P7','P3','CP3','CZ','FC4','FT8','TP7','C3','FZ','F4','F8','T7','FT7','FC3','F3','FP2','F7','FP1','PO5','PO3','P1','POZ','P2','PO4','CP2','P6','PO6','CP6','C6','PO8','PO7','P5','CP5','CP1','C1','C2','FC2','FC6','C5','FC1','F2','F6','FC5','F1','AF4','AF8','F5','AF7','AF3','FPZ'};

container={};
contador=0;


for i=50:51
    filename=files(i).name;
    EEG = pop_loadset('filename',filename,'filepath',base_dir);
    
    
    [EEG_identified,indelec,~,~] = pop_rejchan_modified(EEG, 'elec',[1:60] ,'threshold',3,'norm','on','measure','spec','freqrange',[1 100]);
    indelec
%     if isempty(indelec)
        eegplot( EEG.data, 'srate', EEG.srate,'limits', [EEG.xmin EEG.xmax]*1000, 'events', EEG.event,'winlength', 15);
%     end
    
    [~,ch_std] = myBiweight(EEG.data);
    bad_ch_ind_1 = myFindOutliers(ch_std);
    % mean correlation of top 4 correlation coefficients
    ch_r_raw = corr(EEG.data');
    ch_r_raw = sort(ch_r_raw);
    ch_r = mean(ch_r_raw(end-4:end-1,:)); % top 4 correlation coefficients excluding self-correlation
    bad_ch_ind_2 = myFindOutliers(ch_r);
    % remove and interpolate bad channels
    bad_ch = unique([bad_ch_ind_1,bad_ch_ind_2])
    
    filename
    
    container_aux=[];
    inter=input('Interpolar canais? 1 (sim), 0 (nao): ');
    
    if inter==1
        while inter==1
            canais=input(' Canal ou canais para interpolacao entre paresenteses rectos [ ]: ');
            if canais==0
                inter=0;
            else
                EEG = pop_interp(EEG, canais, 'spherical');
                disp(strcat('Canais',{' '}, chans{canais},{' - '},num2str(canais),{' - '},'interpolados.'));
                EEG = eeg_checkset( EEG );
                eegplot( EEG.data, 'srate', EEG.srate,'limits', [EEG.xmin EEG.xmax]*1000, 'events', EEG.event,'winlength', 15);
                inter=input('Interpolar mais canais: 1 (sim), 0 (n�o): ');
                container_aux=[container_aux, canais];
            end
            
        end
        
    end
    
    if inter>1
        pop_eegplot( EEG, 1, 1, 1);
        inter=input('Valor introduzido errado. Interpolar canais? 1 (sim), 0 (nao): ');
        if inter==1
            while inter==1
                canais=input(' Canal ou canais para interpolacao entre paresenteses rectos [ ]: ');
                if canais==0
                    inter=0;
                else
                    EEG = pop_interp(EEG, canais, 'spherical');
                    disp(strcat('Canais',{' '}, chans{canais},{' '},'interpolados.'));
                    EEG = eeg_checkset( EEG );
                    eegplot( EEG.data, 'limits', [EEG.xmin EEG.xmax]*1000,'winlength', 50);
                    inter=input('Interpolar mais canais: 1 (sim), 0 (n�o): ');
                    container_aux=[container_aux, canais];
                end
            end
        end
    end
    EEG.channelinterpolated=container_aux;
    if isempty(container_aux)~=0
        contador=contador+1;
        container{contador,1}=i;
        container{contador,2}=filename;
        container{contador,3}=[unique(container_aux)];
    end
    close all
    EEG = pop_reref( EEG, []);
    EEG.setname=strcat(filename(1:end-4),'_inter_reref');
    EEG = pop_saveset( EEG, 'filename',strcat(EEG.setname,'.set'),'filepath',output_dir);
    EEG = eeg_checkset( EEG );
end