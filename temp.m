% temp=cell(0)
% length=[];
% for i=1:182
%     temp{i,1}=plp_feature{i,1}{1,1};
%     temp{i,2}=plp_feature{i,1}{1,2};
%     temp{i,3}=plp_feature{i,1}{1,3};
%     length(i)=plp_feature{i,1}{1,3};
% end

ground=cell(0)
ground_lebal=cell(0)
for i=1:182
   ground{i,1}=grouth{i,1}{1,1}{1,2};
   ground_lebal{i,1}=grouth{i,1}{1,1}{1,3};
end