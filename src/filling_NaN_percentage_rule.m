clear all;close all; clc;

cfg = project_config();
dataset_dir = fullfile(cfg.data.raw, 'dataset');
cd(dataset_dir)

files=dir('*');
tasks={'cruz1','codigobug','cruz2','codigoneutro','cruz3','texto'};

percentage_of_features_with_outliers=25;

for p=3:length(files)
% for p=5
    tic
    name_file=files(p).name;
    
    cd(fullfile(dataset_dir,name_file))
    files_inside=dir('*.mat');
    
    for pp=1:length(files_inside)
%         for pp=2
         
        load(files_inside(pp).name)
        
        for e=1:length(tasks)
            task_data=data.(tasks{e});
            task_data=fillmissing(task_data,'linear',2);
            
            outliers_idx=isoutlier(task_data,2);
            [row,col,v]=find(outliers_idx==1);
            n_outliers=sum(outliers_idx);
            col_to_interpolate=find(n_outliers>(2100*(percentage_of_features_with_outliers/100)));
            
            for inter=1:length(col_to_interpolate)
                rows_to_inter=find(col==col_to_interpolate(inter));
                for idx_to_inter=1:length(rows_to_inter)
                    task_data(row(rows_to_inter(idx_to_inter)),col_to_interpolate(inter))=NaN;
                end
            end
            
            task_data=fillmissing(task_data,'linear',2);
                
%             task_data=fillmissing(task_data,'makima',2);
%             task_data= filloutliers(task_data,'linear','percentiles',[1 98],2); %ver outliers presentes em todas as features e usar linear
            data.(tasks{e})=task_data;
        end
        target_dir = fullfile(cfg.data.processed, 'dataset_filled', name_file);
        if ~isfolder(target_dir)
            mkdir(target_dir);
        end
        save(fullfile(target_dir, files_inside(pp).name), "data");
        
    end
    toc
end