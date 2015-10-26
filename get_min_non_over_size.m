function [ min_non_over_size ] = get_min_non_over_size( boundary_time_1,boundary_label_1,boundary_time_2,boundary_label_2 )
%计算DH(boundary_1→boundary_2)使用
%   Detailed explanation goes here
min_non_over_size=[];
for i=1:length(boundary_time_1)-1
    %先将最大重叠尺寸初始化为0
    max_overlapping_size(i)=0;
    boundary_begin_time=boundary_time_1(i);
    boundary_end_time=boundary_time_1(i+1);
    boundary_label=boundary_label_1(i);


    for j=1:length(boundary_time_2)-1
        ground_begin_time=boundary_time_2(j);
        ground_end_time=boundary_time_2(j+1);
        ground_label=boundary_label_2(j);
        if ground_label==boundary_label
            if max_overlapping_size(i) < min(ground_end_time,boundary_end_time)-max(ground_begin_time,boundary_begin_time)
                max_overlapping_size(i)=min(ground_end_time,boundary_end_time)-max(ground_begin_time,boundary_begin_time);
            end
        end
    end

    min_non_over_size(i)=boundary_end_time-boundary_begin_time-max_overlapping_size(i);

end

end

