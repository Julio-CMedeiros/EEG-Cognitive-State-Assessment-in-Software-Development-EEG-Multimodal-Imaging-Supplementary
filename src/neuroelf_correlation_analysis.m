% ----------------------------------------------
% Script Name: neuroelf_correlation_analysis.m
% Author: Julio Medeiros
% Email: juliomedeiros@dei.uc.pt
% Institution: University of Coimbra (UC), Centre for Informatics and Systems of the University of Coimbra (UC)
% Date: 10/09/2023
% Description: This script performs correlation analysis on BOLD time courses and pre-processed EEG features using Neuroelf toolbox.
% ----------------------------------------------



clear, clc, close all;
cfg = project_config();
addpath(cfg.toolbox.neuroelf);

% Load necessary data
load(fullfile(cfg.data.raw, 'dataset_ALL_hrf_and_features.mat'))
load(fullfile(cfg.data.raw, 'feature_name_and_idx.mat'))

% Configuration
configs = struct();

tasks={'cruz1','codigobug','cruz2','codigoneutro','cruz3','texto'};
bold_contrast={'voisBugvsBaseline','voisCodesBugvsCodesNeutro','voisCodesBugvsTxts','voisCodesNeutrovsTxts','voisSuspvsBaseline'};

task_for_analyse=2;
contrast_for_analyse=5;

configs.dataRoot = cfg.paths.bold.vtc;

% Run / Subject Lists
feedbacks = { 'af' 'vf' 'tf' };
feedbacks_vtc = { 'fa' 'fv', 'trans'};

cd(cfg.paths.bold.timecourses)
bold_files=dir('*.mat');
bold_files_names={bold_files.name};

subjects = {all_data_structure{:,3}}';
subjects_names = {all_data_structure{:,3}}';
%% Iteration

transformed_features = {'mean', 'max', 'min'};
delays_hrf = {'hrf_4';'hrf_5';'hrf_6';'hrf_7'};

for sbji = 1:length(subjects)
    tic
    
    % Subject Name and Folder Name
    subject = subjects{sbji};
    subjectname = subjects_names{sbji};
    
    fprintf('---- Subject %s ----\n',subjectname);
    
    % Select VTC
    cd(configs.dataRoot)
    % Select .vtc file to process
    configs.vtcfile = fullfile( configs.dataRoot,...
        [subject '_MIA_SCCTBL_3DMCTS_SD3DSS4.00mm_THPGLMF2c_TAL.vtc'] );
    
    if logical(sum(ismember(bold_files_names,strcat(subject,'_',bold_contrast{contrast_for_analyse},'.mat'))))
        bold_mat = fullfile(cfg.paths.bold.timecourses, sprintf('%s_%s.mat', subject, bold_contrast{contrast_for_analyse}));
        if ~isfile(bold_mat)
            warning('Bold time course %s missing.', bold_mat);
            continue
        end
        load(bold_mat)
        bold_signal=voi_tc;
        tasks_events=all_data_structure{sbji, 4}.ownevents.(tasks{task_for_analyse});
        bold_start=(round(tasks_events(1).latency/1000)/3)+2+1; % +2 por ser os 2 TR que removo iniciais e +1 porque o índice no vetor a começar

        %% Correlation Analysis
        for hrf_delay = 1:length(delays_hrf)
            predictors = [];
            header = {};
            maps_root = fullfile(cfg.paths.derivatives, strcat('mapas_',delays_hrf{hrf_delay}));
            resultsfolder = fullfile(maps_root, subjectname);
            if ~isfolder(resultsfolder)
                mkdir(resultsfolder);
            end
            
            for transformed_feat = 1:length(transformed_features)
                for features_type = 1:length({feature_name_and_idx{:,1}})
                    
                    % load features from file
                    features=all_data_structure{sbji, 4}.hrf.(delays_hrf{hrf_delay}).codigobug.(transformed_features{transformed_feat})(:,features_type);
                    
                    % Condition name = feature name
                    conditionName  = sprintf('%s_%s', transformed_features{transformed_feat}, feature_name_and_idx{features_type});
                    
                    % feature identification
                    name = sprintf('%s_%s_%s', subject, delays_hrf{hrf_delay}, conditionName);
                    header = [header {name}];
                    predictors = cat(2, predictors, features);
                end
            end
            
            vtc = xff(configs.vtcfile );
            
            predictors=predictors(2:end-10,:);
            
            task_duration=size(predictors(:,1),1);
            
            vtc.VTCData=vtc.VTCData(bold_start+2:bold_start+2+task_duration-1,:,:,:);  %+2 porque tamos a tirar os primeiros 3 segundos (=TR) para ter em conta o delay
            vtc.NrOfVolumes=size(vtc.VTCData,1);
            
            %% Run correlations
            for i = 1:length(header)
                
                name = header{i};
                features = predictors(:, i);
                
                map = vtc.Correlate(features);                
                map.SaveAs( [resultsfolder sprintf('/%s.vmp', name) ]);
                
            end
            clearvars map vtc features  predictors
        end
    end
    toc
end
disp
