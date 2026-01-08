cfg = project_config();
EEG.etc.eeglabvers = '14.1.2'; % this tracks which version of EEGLAB is being used, you may ignore it

base_dir = cfg.paths.triggers.GA1000QRS.BCG.fixed;
filtered_dir = fullfile(base_dir, 'filtered');
if ~isfolder(filtered_dir)
    mkdir(filtered_dir);
end

cd(base_dir);

files = dir(fullfile(base_dir, '*.set'));

for i=1:length(files)
    filename=files(i).name;
    EEG = pop_loadset('filename',filename,'filepath',base_dir);
    EEG = eeg_checkset( EEG );
    EEG=pop_chanedit(EEG, 'lookup',fullfile(cfg.toolbox.eeglab,'plugins','dipfit2.3','standard_BESA','standard-10-5-cap385.elp'));
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [],1,[],1,[],0);
    EEG = eeg_checkset( EEG );
    EEG = pop_eegfiltnew(EEG, [],45,[],0,[],0);
    EEG = eeg_checkset( EEG );
    EEG.referencesdata=EEG.data(63:66,:);
    EEG = pop_select( EEG,'nochannel',{'M2' 'M1' 'VEOG' 'EKG' 'PulseOx' 'Trigger'});
    EEG = eeg_checkset( EEG );
    EEG.setname=strcat(filename(1:end-4),'_filtered_1_45hz');
    EEG = pop_saveset( EEG, 'filename',strcat(EEG.setname,'.set'),'filepath',filtered_dir);
    EEG = eeg_checkset( EEG );
end
