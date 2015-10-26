function [ R,P,F ] = accuracy_evaluation( ground_labels,predict_label,ground_time,boundary_time )
%boundary_time=boundary_time';
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
predict_label_offset=0;
%ground_label_array=[];
%recall
R=[];
%precise
P=[];
%F-measure
F=[];
for i=1:length(ground_labels)
    cur_ground_label=ground_labels{i,1};
    cur_ground_time=ground_time{i,1};
    %补0
    cur_ground_time=[0;cur_ground_time];
    cur_boundary_time=boundary_time{i,1};
    cur_boundary_label=predict_label{i,1};
    
    cur_boundary_label_temp=[];
    for j=1:length(cur_boundary_label)
        temp=cur_boundary_label(j);
        cur_boundary_label_temp(j)=str2num(temp{1,1});
    end
    cur_boundary_label=cur_boundary_label_temp;
    
    %最大重叠尺寸
    max_overlapping_size=[];
    %最小不重叠尺寸
    min_non_over_size=[];
    
    boundary_end_time=cur_boundary_time(end);

    min_non_over_size=get_min_non_over_size(cur_boundary_time,cur_boundary_label,cur_ground_time,cur_ground_label);
    R(end+1)=1-sum(min_non_over_size)/boundary_end_time;
    min_non_over_size=get_min_non_over_size(cur_ground_time,cur_ground_label,cur_boundary_time,cur_boundary_label);
    P(end+1)=1-sum(min_non_over_size)/boundary_end_time;
    F=(2*R.*P)./(R+P);    
    
end



end

