% this script is used to do microstates analysis to the resting SZ data
%   Based on:
% Demo script for microstate analyses in EEGLAB
%   By: Thomas Koenig, University of Bern, Switzerland, 2016
%   
% Janir Ramos on 16/10/2017

clc, clear all, clc

CurrDir = pwd;                                              % gets current directory
eeglabpath = fileparts(which('eeglab.m'));                  % Getting eeglab path

% Paths to the data
SZPatientsDir = uigetdir([],'Path to the data of SZ Patients');
ControlsDir = uigetdir([],'Path to the data of Controls');

% Path to save data
SavePath   = uigetdir([],'Path to store the results');

% Initiate eeglab
eeglab

% Initiate variables for the group indeces
SZPatientsIndex = [];
ControlsIndex = [];

% Get the name of the subjects data
DirSZPatients = dir(fullfile(SZPatientsDir,'*.mat*'));
DirControls = dir(fullfile(ControlsDir,'*.mat*'));

FileNamesSZPatients = {DirSZPatients.name};
FileNamesControls = {DirControls.name};

%% Read data for Subjects

% Read the data from SZ Patients Group
for f = 1:numel(FileNamesSZPatients)
    % Loads the pre-processed EEGlab structured data 
    load(fullfile(SZPatientsDir,FileNamesSZPatients{f}));
    % concatonate the epoched eeg into continous
    EEG = eeg_epoch2continuous(EEG);
    % replace the string with another to make a useful name of the dataset
    setname = strrep(FileNamesSZPatients{f},'.mat','');
    % Make a new set
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',FileNamesSZPatients{f},'gui','off'); % And make this a new set
    % Make things average reference, if already average it does not matter
    EEG = pop_reref( EEG, []);
    % Bandpass-filter 2-20Hz (zero-lag) similar to what Thomas do
    EEG = pop_eegfiltnew(EEG, 2, 20, 424, 0, [], 0); 
    % Set the group (will appear in the statistics output)
    EEG.group = 'SZPatients'; 
    % Store what have been done
    ALLEEG = eeg_store(ALLEEG, EEG, CURRENTSET); 
    % Keep track of the groups
    SZPatientsIndex = [SZPatientsIndex CURRENTSET]; 
end


% Finally, for the controls data 
for f = 1:numel(FileNamesControls)
    % Loads the pre-processed EEGlab structured data 
    load(fullfile(ControlsDir,FileNamesControls{f}));
    % concatonate the epoched eeg into continous
    EEG = eeg_epoch2continuous(EEG);
    % replace the string with another to make a useful name of the dataset
    setname = strrep(FileNamesControls{f},'.mat','');
    % Make a new set
    [ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, 0,'setname',FileNamesControls{f},'gui','off'); % And make this a new set
    % Make things average reference, if already average it does not matter
    EEG = pop_reref( EEG, []);
    % Bandpass-filter 2-20Hz (zero-lag) similar to what Thomas do
    EEG = pop_eegfiltnew(EEG, 2, 20, 424, 0, [], 0); 
    % Set the group (will appear in the statistics output)
    EEG.group = 'Controls'; 
    % Store what have been done
    ALLEEG = eeg_store(ALLEEG, EEG, CURRENTSET); 
    % Keep track of the groups
    ControlsIndex = [ControlsIndex CURRENTSET]; 
end

AllSubjects = [SZPatientsIndex ControlsIndex];

eeglab redraw

%% Cluster the stuff
% Define the parameters for clustering
ClustPars = struct('MinClasses',3,'MaxClasses',6,'GFPPeaks',true,'IgnorePolarity',true,'MaxMaps',inf,'Restarts',20', 'UseAAHC',true);

% Loop across all subjects to identify the individual clusters
for i = 1:numel(AllSubjects )
    % Retrieve the EEG subject that we will use
    tmpEEG = eeg_retrieve(ALLEEG,AllSubjects (i)); 
    % Print the process
    fprintf(1,'Clustering dataset %s (%i/%i)\n',tmpEEG.setname,i,numel(AllSubjects )); 
    % Do the clustering within subjects
    tmpEEG = pop_FindMSTemplates(tmpEEG, ClustPars);
    % Clustering done and now we just need to store 
    ALLEEG = eeg_store(ALLEEG, tmpEEG, AllSubjects (i)); 
end

eeglab redraw

%% Now we combine the microstate maps across subjects and edit the mean
% The mean of SZPatients group
EEG = pop_CombMSTemplates(ALLEEG, SZPatientsIndex, 0, 0, 'GrandMean SZPatients');
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, numel(ALLEEG)+1,'gui','off'); % Make a new set
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); % and store it
GrandMeanSZPatientsIndex = CURRENTSET; % And keep track of it

% The mean of SZPatients group
EEG = pop_CombMSTemplates(ALLEEG, ControlsIndex, 0, 0, 'GrandMean Controls');
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, numel(ALLEEG)+1,'gui','off'); % Make a new set
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); % and store it
GrandMeanControlsIndex = CURRENTSET; % And keep track of it

% Now we want the grand-grand mean, based on the two group means
EEG = pop_CombMSTemplates(ALLEEG, [GrandMeanSZPatientsIndex GrandMeanControlsIndex], 1, 0, 'GrandGrandMean');
[ALLEEG, EEG, CURRENTSET] = pop_newset(ALLEEG, EEG, numel(ALLEEG)+1,'gui','off'); % Make a new set
[ALLEEG,EEG] = pop_ShowIndMSMaps(EEG, 4, 1, ALLEEG); % Here, we go interactive to allow the user to put the classes in the canonical order
[ALLEEG,EEG, CURRENTSET] = eeg_store(ALLEEG, EEG, CURRENTSET); % , we store it
GrandGrandMeanIndex = CURRENTSET; % and keep track of it

eeglab redraw

%% And we sort things out over means and subjects
% First, the sequence of the two group means has be adjusted based on the
% grand grand mean
ALLEEG = pop_SortMSTemplates(ALLEEG, [GrandMeanSZPatientsIndex GrandMeanControlsIndex], 1, GrandGrandMeanIndex);

% Then, we sort the individuals based on their group means
ALLEEG = pop_SortMSTemplates(ALLEEG, SZPatientsIndex, 0, GrandMeanSZPatientsIndex); % SZ Patients Group 
ALLEEG = pop_SortMSTemplates(ALLEEG, ControlsIndex, 0, GrandMeanControlsIndex); % Controls Group 

eeglab redraw

%% eventually save things
for f = 1:numel(ALLEEG)
    EEG = eeg_retrieve(ALLEEG,f);
    fname = [EEG.setname,'.vhdr'];
    pop_saveset( EEG, 'filename',fname,'filepath',SavePath);
end

%% Visualize some stuff to see if the fitting parameters appear reasonable
% These are the paramters for the continuous fitting
% FitPars = struct('nClasses',4,'lambda',1,'b',30,'PeakFit',false, 'BControl',true);

% These are the paramters for the fitting based on GFP peaks only
 FitPars = struct('nClasses',4,'lambda',1,'b',30,'PeakFit',true, 'BControl',true);


% Just a look at the first EEG
EEG = eeg_retrieve(ALLEEG,1); 
pop_ShowIndMSDyn([],EEG,0,FitPars);
pop_ShowIndMSMaps(EEG,FitPars.nClasses);

%% Here comes the stats part

% Using the individual templates
pop_QuantMSTemplates(ALLEEG, AllSubjects, 0, FitPars, []                   , fullfile(SavePath,'ResultsFromIndividualTemplates.csv'));

% And using the grand grand mean template
pop_QuantMSTemplates(ALLEEG, AllSubjects, 1, FitPars, GrandGrandMeanIndex, fullfile(SavePath,'ResultsFromGrandGrandMeanTemplate.csv'));

%% Eventually export the individual microstate maps to do statistics in Ragu

nMaps = 4;

Grouping = nan(numel(AllSubjects),1);
Grouping(SZPatientsIndex) = 1;
Grouping(ControlsIndex) = 2;

rd = SaveMSMapsForRagu(ALLEEG(AllSubjects),nMaps,Grouping);

save(fullfile(SavePath,'IndividualMaps.mat'),'rd');