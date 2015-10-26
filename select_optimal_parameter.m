% accuracy=cell(0);
%  count=1;
% for kernel_width=2:256
%    for principal_component_count=1:9
%        [r,p,f]=boundary_detection_plp(kernel_width,principal_component_count);
%        accuracy{kernel_width-1,principal_component_count}={r,p,f,kernel_width,principal_component_count};
%        count/(255*9)*100
%        count=count+1;
%    end
% end


 count=1;
[M,N]=size(accuracy);
for i=1:M
   for j=1:N
       accu_f(i,j)=accuracy{i,j}{3};
       count/(M*N)*100
       count=count+1;
   end
end

