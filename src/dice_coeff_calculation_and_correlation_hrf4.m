clear all; clc;
cfg = project_config();

vmr = xff(fullfile(cfg.toolbox.neuroelf, '_files', 'colin', 'colin.vmr'));

% voi_file = xff('voisSuspvsBaseline.voi');
voi_file = fullfile(cfg.paths.voi, 'voisSuspvsBaseline.voi');

aux_boundingbox=xff(fullfile(cfg.paths.derivatives, 'mapas_hrf_5', 'ID01_run1', 'ID01_run1_hrf_5_max_C1_abs_theta_relative_power.vmp'));

tic

voi = getuniquecoords_boundaries_VOI_new(voi_file);

toc

delays_hrf = {'hrf_4','hrf_5','hrf_6','hrf_7'};
voxels_vl={'voi1','voi2','voi3','voi4','voi5','voi6'};

nr_features=6300;
nr_runs=46;

for hrf_delay = 1:length(delays_hrf)
    
    maps_dir = fullfile(cfg.paths.derivatives, strcat('mapas_',delays_hrf{hrf_delay}));
    if ~isfolder(maps_dir)
        warning('Map directory %s does not exist; create it or set EEG_DATA_DERIVATIVES accordingly.', maps_dir);
    end
    cd(maps_dir)

    files = dir('*');
    
    final_matrix_real_dice.all = single(zeros(nr_runs,nr_features));
    
    final_matrix_adapted_dice.all = single(zeros(nr_runs,nr_features));
    
    final_matrix_nondice_EEG.all = single(zeros(nr_runs,nr_features));
    
    final_matrix_nondice_VOI.all = single(zeros(nr_runs,nr_features));
    
    significant_threshold_05 = zeros(nr_runs,nr_features);
    
    for vl=1:6
        final_matrix_real_dice.(voxels_vl{vl}) = single(zeros(nr_runs,nr_features));
        
        final_matrix_adapted_dice.(voxels_vl{vl}) = single(zeros(nr_runs,nr_features));
        
        final_matrix_nondice_EEG.(voxels_vl{vl}) = single(zeros(nr_runs,nr_features));
        
        final_matrix_nondice_VOI.(voxels_vl{vl}) = single(zeros(nr_runs,nr_features));
        
        for cont = 1:46
            
            correlation_matrix{cont,vl} = single([zeros(length(voi.VOI(vl).Coordsunique), nr_features)]);
        end
        
    end
    
    
    label_matrix={};
    
    contador = 0;
    
    
    
    for p = 3:size(files,1)
        p
        tic
        
        contador = contador+1;
        
        subject_run_id_path = strcat(files(p).folder,'/',files(p).name);
        
        cd(subject_run_id_path)
        file_ids = dir('*.vmp');
        tic
        for f = 1:size(file_ids,1)
            %         for f = 1:2
            %             f
            %             tic
            file_id_path = strcat(file_ids(f).folder,'/',file_ids(f).name);
            map = xff(file_id_path);
            map.MaskWithVMR(vmr);
            
            % possible p-value thresholds: 1 = 0.1000    2 = 0.0500    0.0400    0.0300    0.0200    0.0100    0.0050    0.0010
            thresh = map.Map.FDRThresholds(2,2);
            
            corr_values_map = map.Map.VMPData;
            
            map.Map.VMPData(:) = abs(map.Map.VMPData(:)) >= thresh;
            
            % save binary mask map as vmp
            %         voi = xff('C:/Users/JulioMedeiros/Downloads/voisSuspvsBaseline.voi');
            
            nVoxelsMap = sum(map.Map.VMPData(:));
            nVoxelsVOIs = 0;
            nVoxelsOverlap = 0;
            
            significant_threshold_05(contador,f) = thresh;
            
            for v= 1:voi.NrOfVOIs
                
                %     nVoxelsVOIs = nVoxelsVOIs + voi.VOI(v).NrOfVoxels;
                
                
                %             for tal=1:voi.VOI(v).NrOfVoxels
                %                 voi.VOI(v).Coords(tal, :) = tal2ind(voi.VOI(v).Voxels(tal, : ) , map.Boundingbox);
                %             end
                %
                %             voi.VOI(v).Coordsunique = unique(voi.VOI(v).Coords,'row');
                % voi
                
                nVoxelsVOIs = nVoxelsVOIs + size(voi.VOI(v).Coordsunique,1);
                
                nVoxelsVOIs_single = size(voi.VOI(v).Coordsunique,1);
                
                nVoxelsOverlap_single = 0;
                
                correlation_values_per_voi=single([]);
                
                for i = 1:size(voi.VOI(v).Coordsunique,1)
                    coords = voi.VOI(v).Coordsunique(i, :);
                    
                    if map.Map.VMPData(coords(1), coords(2), coords(3))
                        correlation_values_per_voi = [correlation_values_per_voi; corr_values_map(coords(1), coords(2), coords(3)) * 100];
                    end
                    
                    nVoxelsOverlap_single = nVoxelsOverlap_single + map.Map.VMPData(coords(1), coords(2), coords(3));
                    
                end
                
                final_matrix_real_dice.(voxels_vl{v})(contador,f) = single((2 * nVoxelsOverlap_single / (nVoxelsMap + nVoxelsVOIs_single)) * 100);
                
                final_matrix_adapted_dice.(voxels_vl{v})(contador,f) = single((nVoxelsOverlap_single / min(nVoxelsMap, nVoxelsVOIs_single)) * 100);
                
                final_matrix_nondice_EEG.(voxels_vl{v})(contador,f) = single((nVoxelsOverlap_single/nVoxelsMap) * 100);
                
                final_matrix_nondice_VOI.(voxels_vl{v})(contador,f) = single((nVoxelsOverlap_single/nVoxelsVOIs_single) * 100);
                
                
                nVoxelsOverlap = nVoxelsOverlap + nVoxelsOverlap_single;
%                 
%                 correlation_values_per_voi_aux = correlation_values_per_voi( abs(correlation_values_per_voi) >= thresh) * 100;
                
                if ~isempty(correlation_values_per_voi)
                    correlation_matrix{contador,v}(1:length(correlation_values_per_voi),f) = correlation_values_per_voi;
                end
                
                correlation_matrix{contador,v}=sort(correlation_matrix{contador,v},'descend');
                
            end           
            
            
            final_matrix_real_dice.all(contador,f)=single((2 * nVoxelsOverlap / (nVoxelsMap + nVoxelsVOIs)) * 100);
            
            final_matrix_adapted_dice.all(contador,f)=single((nVoxelsOverlap / min(nVoxelsMap, nVoxelsVOIs)) * 100);
            
            final_matrix_nondice_EEG.all(contador,f)=single((nVoxelsOverlap / nVoxelsMap) * 100);
            
            final_matrix_nondice_VOI.all(contador,f)=single((nVoxelsOverlap / nVoxelsVOIs) * 100);
            
        end
        toc
    end
    %     figure
    %     heatmap(final_matrix.all)
    %     title(delays_hrf{hrf_delay})
    save(fullfile(cfg.paths.derivatives, sprintf('final_matrix_dice_adapted_coeff_%s.mat', delays_hrf{hrf_delay})), 'final_matrix_real_dice','final_matrix_adapted_dice','final_matrix_nondice_EEG','final_matrix_nondice_VOI','correlation_matrix','significant_threshold_05','-v7.3')
end






