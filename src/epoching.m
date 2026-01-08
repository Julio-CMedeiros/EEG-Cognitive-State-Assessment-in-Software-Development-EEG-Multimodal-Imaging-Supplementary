clear all; close all; clc

cfg = project_config();
addpath(cfg.toolbox.eeglab);
addpath(genpath(cfg.toolbox.rodolfo));
eeglab;

% EEG = pop_loadset('filename','AB16092019_run01_GA_ANC0_factor2_win21_re250hz_QRS_BCG_BCG_fixed_filtered_1_45hz_inter_reref.set','filepath',input_dir);


%
input_dir = cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref;
output_dir = cfg.paths.triggers.GA1000QRS.BCG.fixed.filtered.inter_reref.epoching;
if ~isfolder(output_dir)
    mkdir(output_dir);
end

cd(input_dir);
files = dir(fullfile(input_dir, '*.set'));

for i=1
    tic
    filename=files(i).name;
    disp(">>>>>>>>>>>")
    disp(strcat(">>>>>>",{' '},filename,{' '},'<<<<<<'))
    disp(">>>>>>>>>>>")
    EEG = pop_loadset('filename',filename,'filepath',input_dir);
    EEG = eeg_checkset( EEG );


dataset = eeg_regepochs( EEG, 'limits', [0 1.5], 'rmbase', NaN, 'recurrence', 1.5);
dataset = eeg_checkset( dataset );

EEG = eeg_regepochs( EEG, 'limits', [0 1.5], 'rmbase', NaN, 'recurrence', 1.5,'extractepochs','off');
EEG = eeg_checkset( EEG );

epochs_idx=find(strncmp('X', { EEG.event.type }, 1)==1);


amp_diffs = zeros(size(dataset.data,1),size(dataset.data,3));
for iChan = 1:size(dataset.data,1)
    for itrial = 1:size(dataset.data,3)
        amp_diffs(iChan,itrial) = max(dataset.data(iChan,:,itrial)) - min(dataset.data(iChan,:,itrial));
    end
end
[epoch_amp_d,~] = myBiweight(amp_diffs');
% Epoch variance or the mean GFP
epoch_GFP = mean(squeeze(std(dataset.data,0,2)));
% Epoch's mean deviation from channel means.
[means,~] = myBiweight(dataset.data(:,:)); % channel mean for all epochs
epoch_m_dev = zeros(1,size(dataset.data,3));
for itrial = 1:size(dataset.data,3)
    epoch_m_dev(itrial) = mean(abs(squeeze(mean(dataset.data(:,:,itrial),2))' - means));
end

% Find the bad trials
Rej_ep_amp_d = myFindOutliers(epoch_amp_d);
Rej_ep_GFP = myFindOutliers(epoch_GFP);
Rej_ep_mdev = myFindOutliers(epoch_m_dev);
Rej_epoch = unique([Rej_ep_amp_d Rej_ep_GFP Rej_ep_mdev]);

bad_epochs=[];
for rr=1:length(Rej_epoch)
    bad_epochs=[bad_epochs; EEG.event(epochs_idx(Rej_epoch(rr))).latency EEG.event(epochs_idx(Rej_epoch(rr)+1)).latency-1];
end

eventos={EEG.event.type};
aux_1=double(strcmp(eventos,'X'));aux_2=double(strcmp(eventos,'qrs')); aux_3=double(strcmp(eventos,'keypad5')); 
aux_total=[aux_1',aux_2',aux_3'];
spotting=logical(sum(aux_total,2));
main_eventos=EEG.event(~spotting);

visualization=bad_epochs;
visualization=[visualization, repmat([0.65 1 1 zeros(1,60)],length(bad_epochs),1)];
    
for rr=1:length(main_eventos)
    visualization=[visualization; [main_eventos(rr).latency main_eventos(rr).latency+125] 1 0.25 0.25 zeros(1,60)];
end


eegplot( EEG.data,'srate', EEG.srate,'limits', [EEG.xmin EEG.xmax]*1000, 'events', EEG.event,'winlength', 20, 'winrej',visualization)

hold off

LastName = arrayfun(@num2str,[1:length(Rej_epoch)],'un',0);
Epoch_n=Rej_epoch';
Start = bad_epochs(:,1)/EEG.srate;
End = bad_epochs(:,2)/EEG.srate;
T = table(Epoch_n,Start,End,'RowNames',LastName);
figure
uitable('Data',T{:,:},'ColumnName',T.Properties.VariableNames,...
    'RowName',T.Properties.RowNames,'Units', 'Normalized', 'Position',[0, 0, 1, 1]);

flag=1000000;
epochs_to_keep=[];
while flag~=0
    flag=input('Epoch idx to keep: (Press 0 to stop)');
    epochs_to_keep=[epochs_to_keep, flag]
end
epochs_to_keep=epochs_to_keep(1:end-1);
epochs_to_remove=[1:length(bad_epochs)];
epochs_to_remove(epochs_to_keep)=[];
epochs_to_remove=flip(epochs_to_remove);


for rem=1:length(epochs_to_remove)
    EEG = pop_select( EEG,'nopoint',[bad_epochs(epochs_to_remove(rem),1) bad_epochs(epochs_to_remove(rem),2)] );
end

EEG.setname=strcat(filename(1:end-4),'_epoching');
    EEG = pop_saveset( EEG, 'filename',strcat(EEG.setname,'.set'),'filepath',output_dir);
EEG = eeg_checkset( EEG );

end
%
% % Remove the bad trials
% dataset = pop_select(dataset,'notrial',Rej_epoch);
% dataset_eog = pop_select(dataset_eog,'notrial',Rej_epoch);
% % Count the bad trials
% bad_trials = bad_trials + length(Rej_epoch);
%
% EEG=dataset;
%
% xtmp = EEG.data(:,:);
% for ichan = 1:size(xtmp,1)
%     % input arguments - data, sampling rate, fraction of the
%     % data to apply the hanning, size of the data segment
%     xtmp(ichan,:) = hann_intersection(xtmp(ichan,:), EEG.srate, 1/5, EEG.srate*epoch);
% end
%
% % copy data and check the set, the set check is already epoched
% % again but it's okay since already hanninged
% EEG.data = xtmp;