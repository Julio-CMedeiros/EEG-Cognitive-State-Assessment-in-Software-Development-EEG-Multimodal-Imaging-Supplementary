cfg = project_config();
addpath(cfg.toolbox.funcoes)

voi = xff(fullfile(cfg.paths.voi, 'voisSuspvsBaseline.voi'));
% neuroelf_gui('openfile', xff('C:/Users/JulioMedeiros/Desktop/neuroelf-matlab-master/neuroelf-matlab-master/_files/colin/colin_brain.vmr'), [true],[true])

hrf=[4,5,6,7];

feat_nr = 2;

sub_name={subj_id(:).name};

files_present={'ID15_run1_hrf_4_mean_FC6_total_power.png','ID15_run2_hrf_4_mean_FC6_total_power.png','ID15_run3_hrf_4_mean_FC6_total_power.png','ID15_run4_hrf_4_mean_FC6_total_power.png'};


stats = [];
img = {};
cont = 0;
figure_root = fullfile(cfg.paths.derivatives, 'neuroelf_mapas');
individual_dir = fullfile(figure_root, 'imagens', 'individual');
summary_dir = fullfile(figure_root, 'imagens');
if ~isfolder(individual_dir)
    mkdir(individual_dir);
end
if ~isfolder(summary_dir)
    mkdir(summary_dir);
end

for pp = 1:length(files_present)
    
    file_id_name = char(files_present(pp));
    file_aux_all = split(file_id_name,'_');
    file_aux_name = strcat(file_aux_all{1},'_',file_aux_all{2});
    
    aux_feat = char(file_id_name);
    aux_feat_find = find(aux_feat=='_');
    file_aux_feat = aux_feat(aux_feat_find(4)+1:end-4);
    
    hrf_delay = str2double(aux_feat(aux_feat_find(3)+1));
       
    ID_stats = find([ismember(sub_name,{file_aux_name})]==1);
    
    feat_list = best(subj_id(ID_stats).id,:);
    
    feat_stats = find([ismember(feat_list,{file_aux_feat})]==1);
    
    
        ID_stats = ID_stats;
    
        map_path = fullfile(cfg.paths.derivatives, strcat('mapas_hrf_', num2str(hrf_delay)), file_aux_name, strcat(file_id_name(1:end-4), '.vmp'));
        if ~isfile(map_path)
            warning('Map file %s missing, skipping.', map_path);
            continue
        end
        vmp = neuroelf_gui('openfile', xff(map_path));
        vmp.MaskWithVMR(xff(0,'object',fullfile(cfg.toolbox.neuroelf,'_files','colin','colin_brain.vmr')));
    
        file_id_name
    
    stats = [stats; stacking_dice(ID_stats,feat_stats), stacking_correlation(ID_stats,feat_stats), stacking_correlation_max(ID_stats,feat_stats)];
    
        tresh = vmp.Map.FDRThresholds(2,2)
        max = stacking_correlation_max(ID_stats,feat_stats)/100
    
        figure('Name',strcat(file_id_name))
        cont = 0;    
        for j = 1:3
            cont = cont + 1;
            pause
            img{pp,j} = screencapture(0, 'Position', [1100 220 790 800]);
            subplot(1,3,cont)
            imshow(img{pp,j})
            im_to_save = img{pp,j};
            imwrite(im_to_save, fullfile(individual_dir, file_id_name));
        end
end


%%
for i=1:length(img)
    for j=1:3
        im_to_save = img{i,j};
        imwrite(im_to_save, fullfile(summary_dir, sprintf('suj9_run%d_%d.png', i, j)));
    end
end
