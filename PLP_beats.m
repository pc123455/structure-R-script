clear;
FilePath = 'D:\У�����Լ�\Test';
DirFile = dir(FilePath);      %�оٸ�·����,�����ļ�
%%����������ȡ����
newfs = 44100;  % �µĲ�����
WindowLength = 1024;% ����С����λ������
Overlap = 0;    % �ص����ֵĲ�������
bplot = 0;      % �Ƿ�ͼ
blockcount = 10;% һ���������֡��
smoothwindow = 32;% ƽ������С
%% read grouthtruth
%load('grouthtrue.mat');
%����ground truth
load('ground_truth.mat');
loop_count=0;
[FileNum, FileDim] = size(DirFile);                 %�ļ�������
index = 0;
for i = 1: FileNum
    file{i} = DirFile(i,1).name;
end
index = 0;
an_index = 0;
for i = 1: FileNum
    [path, name, ext] = fileparts(DirFile(i,1).name);
    if(DirFile(i,1).isdir == 1) %��ȡ��Ŀ¼�µ��ļ�
        filename{i} = DirFile(i,1).name;           %��ȡ�ļ���
        filename{i} = strcat(FilePath,'\',filename{i});%·����+�ļ���
        filename{i} = strcat(filename{i},'\'); % ��ת����Ŀ¼
        %% �оٸ�·���£���չ��Ϊwav�ļ�
        subdir = dir(fullfile(filename{i},'*.wav'));
        [m,n] = size(subdir);
        if m ~= 0
            index = index + 1;
        end
        for j = 1:m 
            loop_count=loop_count+1
            %j
            subfile = subdir(j,1).name;% �ļ���                 
            fileTest{index,j}  = strcat(filename{i}, subfile);%·����
            %��wav�ļ�
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
                   % ������������ֵ
                   %b = mean(b,2); % convert to mono
%                     if fs ~= newfs,
%                         b = resample(b, newfs, fs);% �ز���
%                     end
               else                
                [a fs] = wavread(fileTest{index,j},[q q + 1048573]);
                 a=a(:,2);
                % ������������ֵ
%                a = mean(a,2); % convert to mono
%                 if fs ~= newfs,
%                     a = resample(a,newfs,fs);% �ز���
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
               x = resample(x,newfs,fs); % �ز���
           end
            
           
           %%  ��ȡ��Ƶ����
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
            % ����Ƶʱ����ӵ�beats��ĩβ
            beats = [beats duration];           
            beatsResult{index,j}=beats;

            cutpoint = beats * fs;
            %������������
            ceps=[];
            spec=[];
            lpcas=[];
            %%��Ƶ�ָ�,��ȡ����
            [ceps,spec,lpcas]=rastaplp(x,fix(length(x)*100/beats_count),0);

            plp_feature{index,j} = {ceps,spec};
            plp_feature{index,j}={plp_feature{index,j},subfile,length(x)/newfs};
         end
    end
end
%�Ѱ�Ԫ�����Ϊһ��
plp_feature = plp_feature(:)
%�жϰ�ԪԪ���Ƿ�Ϊ�գ��յİ�Ԫ������Ϊ0
idx = cellfun(@(x)~isempty(x),plp_feature,'UniformOutput',true);
%ɾ���յİ�ԪԪ��
plp_feature = plp_feature(idx);
