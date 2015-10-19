function [ mean_feature ] = get_boundary_indieces( boundary_bands,music_length,features )
%Calculate the mean of nomalized feature
%   para1:boundary time
%   para2:music length (s)
%   para3:extracted features

%% 计算边界点的索引值
%检测出的边界点的index
boundary_index=cell(0);
for i=1:length(boundary_bands)
    cur_boundary=boundary_bands{i,1};
    cur_boundary=[cur_boundary, music_length(i)];
    cur_boundary=cur_boundary*size(features{i,1},2)/music_length(i);
    boundary_index{i,1}=round(cur_boundary);
end

% %ground truth的边界点索引值
% ground_index=cell(0);
% for i=1:length(ground)
%     cur_ground=ground{i,1};
%     cur_ground=cur_ground*size(features{i,1},2)/music_length(i);
%     ground_index{i,1}=round(cur_ground);
% end

%% 归一化
features_nomal=cell(0);
for i=1:length(features)
   cur_feature = features{i,1};
   feature_mean=mean(cur_feature,2);
   feature_std=std(cur_feature')';
   for j=1:size(cur_feature,1)
       cur_row=cur_feature(j,:);
       cur_feature(j,:)=(cur_row-feature_mean(j))/feature_std(j);
   end
   features_nomal{i,1}=cur_feature;
end

%% 计算各个边界区间的特征均值
%分离各个片段的特征
separate_feature=cell(0);

for i=1:length(boundary_index)
   cur_bound = boundary_index{i,1};
   cur_feature = features_nomal{i,1};
   for j=1:length(cur_bound)-1
       col_begin=cur_bound(j)+1;
       col_end=cur_bound(j+1);
       if(col_end>size(cur_feature,2))
           col_end=size(cur_feature,2);
       end
       separate_feature{i,1}{1,j}=cur_feature(:,col_begin:col_end);
   end
end

%均值
mean_feature=cell(0);
for i=1:length(separate_feature)
    cur_featrue=separate_feature{i,1};
    cur_featrue=cur_featrue';
    for j=1:length(cur_featrue)
       mean_feature{i,1}(:,j)=mean(cur_featrue{j,1},2);
    end
end

end

