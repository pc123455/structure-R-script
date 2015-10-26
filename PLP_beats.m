clear;
FilePath = 'D:\校正测试集\Test';
DirFile = dir(FilePath);      %列举该路径下,所有文件
%%设置特征提取参数
newfs = 44100;  % 新的采样率
WindowLength = 1024;% 窗大小，单位采样点
Overlap = 0;    % 重叠部分的采样点数
bplot = 0;      % 是否画图
blockcount = 10;% 一个块包含的帧数
smoothwindow = 32;% 平滑窗大小
%% read grouthtruth
%load('grouthtrue.mat');
%载入ground truth
load('ground_truth.mat');
loop_count=0;
[FileNum, FileDim] = size(DirFile);                 %文件的数量
index = 0;
for i = 1: FileNum
    file{i} = DirFile(i,1).name;
end
index = 0;
an_index = 0;
for i = 1: FileNum
    [path, name, ext] = fileparts(DirFile(i,1).name);
    if(DirFile(i,1).isdir == 1) %读取子目录下的文件
        filename{i} = DirFile(i,1).name;           %获取文件名
        filename{i} = strcat(FilePath,'\',filename{i});%路径名+文件名
        filename{i} = strcat(filename{i},'\'); % 跳转到子目录
        %% 列举该路径下，扩展名为wav文件
        subdir = dir(fullfile(filename{i},'*.wav'));
        [m,n] = size(subdir);
        if m ~= 0
            index = index + 1;
        end
        for j = 1:m 
            loop_count=loop_count+1
            %j
            subfile = subdir(j,1).name;% 文件名                 
            fileTest{index,j}  = strcat(filename{i}, subfile);%路径名
            %打开wav文件
           total_bytes=wavread(fileTest{index,j},'size');
           total_samples=total_bytes(1,1);
%            if total_samples > 0
%                an_index = an_index + 1;
%            end
           %sample_ends=total_samples/2;
           %runtime=ceil(sample_ends/65535);
           runtime=ceil(total_samples/1048574);
           x=[];
           a=[];
           c=[];
           q=1;          
            % read wave file    
           if 1048574<total_samples
            for s=1:runtime              
               if q+1048573 > total_samples
                   [ b fs] = wavread(fileTest{index,j},[q total_samples]); 
                    b=b(:,2);
                   % 左右声道做均值
                   %b = mean(b,2); % convert to mono
%                     if fs ~= newfs,
%                         b = resample(b, newfs, fs);% 重采样
%                     end
               else                
                [a fs] = wavread(fileTest{index,j},[q q + 1048573]);
                 a=a(:,2);
                % 左右声道做均值
%                a = mean(a,2); % convert to mono
%                 if fs ~= newfs,
%                     a = resample(a,newfs,fs);% 重采样
%                 end
                q = q + 1048573; 
                x = cat(1,x,a);
               end
            end
                x = cat(1,x,b);            
           else
            [x fs] = wavread(fileTest{index,j});
              % convert to mono
              %x = mean(x,2);
              x=x(:,2)
           end
           if fs ~= newfs,
               x = resample(x,newfs,fs); % 重采样
           end
            
           
           %%  提取音频特征
            duration = total_samples / fs;
            % read beat tracking parameters
            p = bt_parms;
            % generate the onset detection function
            df = onset_detection_function(x,p);
            % strip any trailing zeros
            while (df(end)==0)
                df = df(1:end-1);
            end 
            % get periodicity path
            ppath = periodicity_path(df,p);
            mode = 0; % use this to run normal algorithm.
            % find beat locations
            beats = dynamic_programming(df,p,ppath,mode);
            beats_count = length(beats);
            % 把音频时长添加到beats的末尾
            beats = [beats duration];           
            beatsResult{index,j}=beats;

            cutpoint = beats * fs;
            %重置特征数据
            ceps=[];
            spec=[];
            lpcas=[];
            %%音频分割,提取特征
            [ceps,spec,lpcas]=rastaplp(x,fix(length(x)*100/beats_count),0);

            plp_feature{index,j} = {ceps,spec};
            plp_feature{index,j}={plp_feature{index,j},subfile,length(x)/newfs};
         end
    end
end
%把胞元矩阵变为一列
plp_feature = plp_feature(:)
%判断胞元元素是否为空，空的胞元的索引为0
idx = cellfun(@(x)~isempty(x),plp_feature,'UniformOutput',true);
%删除空的胞元元素
plp_feature = plp_feature(idx);
