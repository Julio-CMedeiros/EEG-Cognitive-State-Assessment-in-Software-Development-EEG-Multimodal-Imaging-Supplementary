% Scripts to calculate the relative amplitude of frequency bands
%
%   Janir Ramos da Cruz @IST and @EPFL, 08/11/2017

% Directory management
clc, clear all, clc

CurrDir = pwd;                                    % gets current directory

% Paths to the data
SubjectsDir = uigetdir([],'Path to the data of Subjects');

% Subjects pre-processed data files
Subject_data = dir(fullfile(SubjectsDir,'*preprocess.mat'));

% The pool of subjects
Subject_pool = {Subject_data(:).name}';

% Loop across subjects
for iSubject = 1:size(Subject_pool,1)
    
    % Get and load the subject
    EEGFile = fullfile(SubjectsDir,Subject_pool{iSubject});
    load(EEGFile);
    
    % For the first run of subjects, claim some memory to store individual
    % subjects values for different bands
    % subject x channels
    if iSubject == 1
       Delta = zeros(size(Subject_pool,1),size(EEG.data,1)); 
       Theta = zeros(size(Subject_pool,1),size(EEG.data,1));
       Alpha = zeros(size(Subject_pool,1),size(EEG.data,1));
       Beta = zeros(size(Subject_pool,1),size(EEG.data,1));
       Gamma = zeros(size(Subject_pool,1),size(EEG.data,1));
    end
    
    % Claim some memory for the calculations for different bands
    % channels x epochs
    tmpDelta = zeros(size(EEG.data,1),size(EEG.data,3));
    tmpTheta = zeros(size(EEG.data,1),size(EEG.data,3));
    tmpAlpha = zeros(size(EEG.data,1),size(EEG.data,3));
    tmpBeta = zeros(size(EEG.data,1),size(EEG.data,3));
    tmpGamma = zeros(size(EEG.data,1),size(EEG.data,3));
    
    % Loop for each channel
    for ichan = 1:size(EEG.data,1)
        % Loop for each segment to have a better estimate
        for iepoch = 1:size(EEG.data,3)
            % for delta - from 1 to 4 Hz
            tmpDelta(ichan,iepoch) = relAmplitude(EEG.data(ichan,:,iepoch),EEG.srate,1,4,1,70);
            
            % for theta - from 4 to 8 Hz
            tmpTheta(ichan,iepoch) = relAmplitude(EEG.data(ichan,:,iepoch),EEG.srate,4,8,1,70);
            
            % for alpha - from 8 to 13 Hz
            tmpAlpha(ichan,iepoch) = relAmplitude(EEG.data(ichan,:,iepoch),EEG.srate,8,13,1,70);
            
            % for beta - from 13 to 30 Hz
            tmpBeta(ichan,iepoch) = relAmplitude(EEG.data(ichan,:,iepoch),EEG.srate,13,30,1,70);
            
            % for gamma - from 30 to 70 Hz
            tmpGamma(ichan,iepoch) = relAmplitude(EEG.data(ichan,:,iepoch),EEG.srate,30,70,1,70);
        end
    end
    
    % Assign the biweight estimate of the mean to avoid influence of
    % outliers
    [Delta(iSubject,:),~] = myBiweight(tmpDelta);
    [Theta(iSubject,:),~] = myBiweight(tmpTheta);
    [Alpha(iSubject,:),~] = myBiweight(tmpAlpha);
    [Beta(iSubject,:),~] = myBiweight(tmpBeta);
    [Gamma(iSubject,:),~] = myBiweight(tmpGamma);
    
end