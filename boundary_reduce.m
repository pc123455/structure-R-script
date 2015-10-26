function [ reduced_boundaries ] = boundary_reduce( boundary_features,boundary_label,boundary_time )
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

%距离参数，设定为欧几里德距离
distfn = 'seuclidean';

%合并阈值
threshold=0.1;

for i=1:length(boundary_features)
    cur_features=boundary_features{i,1};
    cur_label=boundary_label{i,1};
    cur_time=boundary_time{i,1};
    
    %计算各个片段之间的距离
    sm = squareform(pdist(cur_features, distfn));
    
    for j=1:length(cur_time)
        
    end
end

end

