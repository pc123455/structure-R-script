% function computer_time = boundary_detection(distfnIndex, ...
%     filter_n,fftsize,W0,kernel_width, ...
%     AMPLSUM_LOW_THRESHOLD,AMPLSUM_MEAN_RANGE,...
%     featureIndex)

%function [r,p,f]=boundary_detection_plp(kernel_width,principal_component_count)

distfnIndex=0;
filter_n=10;
fftsize=1024;
W0=6;
kernel_width=118;
AMPLSUM_LOW_THRESHOLD=0.2;
AMPLSUM_MEAN_RANGE=5;
featureIndex=7;
principal_component_count=9;
debug=0;
%%
%This phase tries to detect the segment boundaries(also called
%transitions)of a song,
%input parameter
%   distfnIndex: distance function-- 0 : euclidean;1 : cosine
%   filter_n: number frames of moving average filter
%   fftsize: number of fft
%   WO:  minimal length of a segment
%   kernel_width: the width of the gaussian kernel
%   AMPLSUM_LOW_THRESHOLD: sum of amp threshold
%   AMPLSUM_MEAN_RANGE: sum of amp the count of frame
%   featureIndex: feature index
%       1 : mfcc
%       2 : chorma
%       3 : mfcc + chorma
%       4 : spec_ratio
%       5 : spec_ratio + energy
%       6 : spec_ratio + energy + mfcc
%output parameter
%   computer_time:boundary time

%%read beats cell
load('beats182.mat');
% load('beats.mat');

%%read beat-synchronous audio features
load('mfcc_features182.mat');
% load('mfcc_features_stereo182.mat');
load('chorma_features182.mat');

load('plp_features_just_plp.mat');

%% read beat-synchronous audio amp
% load('amp182.mat');
load('amp_stereo182.mat');

%% read grouthtruth
% load('grouthtrue.mat');
load('ground_truth.mat');
%% read audio duration
% load('duration182.mat');
load('duration.mat');
%% read spectro energy
% load('new_band_energy_stereo.mat');
% load('new_band_energy.mat');
load('new_band_energy_5bands')
% 	override: baseline: each 20 sec one bound
equallen = 30;
%debug = 0;
if distfnIndex == 0
    distfn = 'seuclidean';
else
    distfn = 'cosine';
end

%% set the parameter
% parameter for fir1 and moving average filter
% filter_n = 50;
% fftsize = 1024;
% % minimal length of a segment, ie minimal distance between two boundaries(in seconds)
% W0 = 6;
% % set the sum of amp threshold and the count of frame
% AMPLSUM_LOW_THRESHOLD = 0.2;
% AMPLSUM_MEAN_RANGE = 5;
% % the width of the gaussian kernel
% kernel_width = 32;
% boundary_bands=cell(0);
%load('temp.mat');
spec=cell(0);
boundary_bands=cell(0);
plp_spec=cell(0);
for i=1:length(spec_ratio)
    temp=spec_ratio{i,1};
    spec_ratio{i,1}=temp{1,1};
    temp=spec_energy{i,1};
    spec_energy{i,1}=temp{1,1};
    temp=plp_feature{i,1};
    music_length(i)=temp{1,3};
    plp_feature{i,1}=temp{1,1};
    plp_spec{i,1}=plp_feature{i,1}{1,1};
end

for i=1:length(spec_ratio)
    spec{i}=[spec_energy{i,1};spec_ratio{i,1}'] ;
    %spec{i}=[spec_ratio{i,1}'] ;
end

%% set the feature
feature=cell(0);
skip=[];
switch featureIndex
    case 1
        feature = new_mfcc;
    case 2
        feature = new_chorma;
    case 3
        feature = [new_mfcc new_chorma];
    case 4
        feature = spec_ratio;
    case 5
        feature = spec;
    case 6
        %         feature = [spec' new_mfcc]
        for i=1:length(spec)
            temp1=spec{1,i};
            temp2=new_mfcc{i,1};
            temp3=new_chorma{i,1};
            if size(temp1,2)==size(temp2,2) && size(temp3,2)==size(temp2,2)% && size(temp1,2)==length(new_amp{i,1})
                % spec{1,i}=[spec{1,i};new_mfcc{i,1}];
                mfcc_temp=new_mfcc{i,1};
                %计算mfcc的一阶差分
                mfcc_diff_1=[mfcc_temp(:,1),diff(mfcc_temp')'];
                %计算mfcc的二阶差分
                mfcc_diff_2=[mfcc_temp(:,1),mfcc_diff_1(:,1),diff(mfcc_temp',2)'];
                chorma_temp=new_chorma{i,1};
                spec_temp=spec{1,i};
                feature{end+1,1}=[spec_temp(2:end,:);mfcc_temp;mfcc_diff_1;mfcc_diff_2;temp3];
            else
                skip(end+1)=i;
            end
        end
        %feature=spec;
    case 7
        feature = plp_spec;
    otherwise
        feature = new_mfcc;
end

%去掉beats中被跳过的条目
for i=1:length(skip)
    beats(skip(end-i+1))=[];
end
%去掉ground truth中被跳过的条目
for i=1:length(skip)
    ground_set(skip(end-i+1))=[];
end
%去掉amp中被跳过的条目
for i=1:length(skip)
    new_amp(skip(end-i+1))=[];
end

% general the checker gauss filter
% kernel = checkergauss(kernel_width);
kernel = get_gaussian_checkboard_kernel(kernel_width);
% shading interp;
num_piece = length(feature);
num_begin = 1;
%num_piece = 182;
for i = num_begin:num_piece
    
    [a, mean_beat_interval] = getBeatIntervals(beats{i});
    
    beatlen = length(beats{i});
    featlen = length(feature{i,1}');
    if beatlen ~= featlen
        %msgbox('feature frames doesnot equal to the beat number');
    end
    % calc amplitude sums
    amplsums = zeros(length(beats{i})+1, 1);
    
    %对特征进行PCA计算
    [coef,score,latent,t2] = princomp(feature{i,1}');
    %     sm = squareform(pdist(feature{i,1}', distfn));
    clear sm;
    %sm是相似矩阵
    sm = squareform(pdist(score(:,1:principal_component_count), distfn));
    if debug
        figure;
        imagesc(sm);
        colormap(1-gray);title(['Similarity Matrix (d_{sm}: ' distfn ')']);
        xlabel('frames');ylabel('frames');
    end
    % set all NaN to 0
    sm(isnan(sm)) = 0;
    similarity_matrix{i,1} = sm;
    feature{i}(isnan(feature{i})) = 0;
    % calculating novelty score
    %     disp('calculating novelty score...');
    if iscell(kernel)
        Narray = zeros(size(kernel, 1),length(sm));
        for j = 1: length(kernel)
            Narry(j,:) = getNoveltyScore(sm, kernel{j});
        end
    else
        N = getNoveltyScore(sm, kernel);
        %         N(N-mean(N)*1.5<0)=0;
        Narray = zeros(1,length(sm));
        Narray(1,:) = N;
    end
    if debug
        figure; % plot nov-score
        hold on;
        for j = 1:size(Narray,1)
            time_temp=1:size(feature{i,1},2);
            time_temp=music_length(i)*time_temp/size(feature{i,1},2);
            plotNoveltyScore(Narray(1,:), fftsize, 22050, 'b--',time_temp);
        end
        ground_truth=ground_set{i};
        ground_truth{1,2}
        ground_truth=ground_truth{1,1};
        ground_truth=ground_truth{1,1};
        plot(ground_truth,0.7,'bo');
    end
    % extract boundaries (local maximas)
    %     disp('extracting boundaries...')
    %     i
    % filter moving average
    %     Nh = normalizeToMax1(circshift(filter(gaussmf(ones(1,filter_n),[filter_n/4 filter_n/2]),1, N),...
    %                                             floor(filter_n* -1/2)+1));
    Nh = normalizeToMax1(circshift(filter(ones(1,filter_n),1, N),...
        floor(filter_n* -1/2)+1));
    %     Nh = smooth(N,filter_n,'moving');
    Nharray = zeros(1,length(sm));
    
    Nharray(1,:) = Nh;
    %     Nh_dct=dct(Nh);
    %     Nh_dct(100:end)=0;
    %     Nh=idct(Nh_dct);
    % extract boundaries
    %     Nh=diff(Nh);
    %new_amp{i}=smooth(new_amp{i},filter_n*2,'moving');%对振幅进行平滑处理
    
    amp_dct=dct(new_amp{i});
    amp_dct(100:end)=0;
    new_amp{i}=idct(amp_dct);
    
    
    [bounds_array, maximas_array, Nhgr2] ...
        = extractBoundariesFromNh_plp(Nh, N, W0, beats{i}, new_amp{i},music_length(i));
    %     bounds_array=findpeaks(N);
    maximas_array(end+1)=0;
    %
    bounds_indices = get_bounds_indices_from_bounds...
        (bounds_array, beats{i}, feature{i});
    
    if debug
        for j = 1:size(Nharray,1)
            plotNoveltyScore(Nharray(j,:), fftsize, 22050, 'c', time_temp);
            for k=1:length(maximas_array)
                if maximas_array(k)~=0%maximas_array(k)
                    %                     plot(beats{i}(k),0.7 , 'r*');
                    plot(bounds_array,0.7 , 'r*');
                end
            end
        end
        %plot(beats{i}, new_amp{i}, 'g');
        legend('N', 'H_N', 'boundaries');
    end
    
    
    %使用振幅对边界点进行筛选
    %bounds_array=boundary_filter(bounds_array,bounds_indices,new_amp{i},5,0.1,15,0.9);
    
    if debug
        for j = 1:size(Nharray,1)
            plotNoveltyScore(Nharray(j,:), fftsize, 22050, 'c', time_temp);
            for k=1:length(maximas_array)
                if maximas_array(k)~=0%maximas_array(k)
                    %                     plot(beats{i}(k),0.7 , 'r*');
                    plot(bounds_array,0.75 , 'rx');
                end
            end
        end
        plot(beats{i}, new_amp{i}, 'g');
        plot(beats{i}, abs([new_amp{i}(1);diff(new_amp{i})]), 'm');
        legend('N', 'H_N', 'boundaries');
        grid on
    end
    
    %     disp('Clustering...');
    % prepare to cluster
    % perfectBounds		1: load boundaries from ground truth XML
    %					0: calculate bounds by Phase 1
    perfectBounds = 0;
    % pca_comps			number of pca coeffs, 0 is no pca
    pca_comps = 3;
    % verbose2			0|value > 0
    %					verbose for clustering (3 means: 3d scatterplot of segments)
    verbose2 = 0;
    % Overview of modes
    %              Features | Cluster method
    % ---------------------------------------
    % means      | means    | k-means
    % clusterdata| means    | agglomerative
    % voting     | each frm | k-means
    % dtw        | dtw      | k-means
    mode = {'means','clusterdata','voting','dtw'};
    
    %bounds = equallen/2: equallen: duration{i};
    bounds = bounds_array;
    
    annot.param = cell(0);
    annot.debug = cell(0);
    annot.segs  = cell(0);
    
        [annot, segm_cands_features, segm_before_first_bound, ...
                    segm_after_last_bound] = ...
                        prepare_segm_features(annot, feature{i}, ...
                            bounds_indices, bounds_array, 1, perfectBounds, ...
                            pca_comps, mode{1}, W0, verbose2,duration{i});
    
    % joining of segments
    % threshold for joining two consecutive segmetns to one
    joinThreshold = 0.1;
    if joinThreshold > 0
        joiniter = 1;
        % calc SM matrix for segments
        SM_segs = calcSM_segs(segm_cands_features, verbose2);
        
        k=1;
        bounds_dropped3 = []; % merged
        while k <= length(annot.segs)-1
            if k>=size(SM_segs,2)
                break;
            end
            if abs (SM_segs(k, k+1)) < joinThreshold
                % delete bound, depending on whether seg is before first bound
                % segm_before_first_bound is 0 or 1
                i_to_del = k + (1-segm_before_first_bound);
                if verbose2
                    disp(['merging segments ' num2str(k) ' and ' num2str(k+1)...
                        '. New segment ranging from ' num2str(bounds(max(1, k-1)))...
                        ' to ' num2str(bounds(k+1))]);
                end
                bounds_dropped3 = push(bounds_dropped3, bounds(i_to_del));
                bounds(i_to_del) = [];
                bounds_indices(i_to_del) = [];
                
                annot.segs  = cell(0);
                
                [annot, segm_cands_features, segm_before_first_bound, segm_after_last_bound]...
                    = prepare_segm_features(annot, feature{i}, bounds_indices, bounds, ...
                    0, perfectBounds, pca_comps, mode{1}, W0, verbose2, duration{i});
                SM_segs = calcSM_segs(segm_cands_features, verbose2);
                
                joiniter = joiniter + 1;
                %k = k + 1;
            else
                k = k+1;
            end
        end
    end
    
    seg_length = length(annot.segs);
    if seg_length ~= 0
        end_time = annot.segs{seg_length}.end_sec;
        %         bound_time{i} = [0 bounds end_time];
        bound_time{i} = [0 bounds_array end_time];
    else
        %         bound_time{i} = 0;
        bound_time{i} = [0 bounds_array];
    end
    %      bound_time{i} = [0 bounds_array];
    
    
    % ====================== CLUSTERING ==========================
    if ~strcmp(mode, 'clusterdata')
        annot.params = cellpush(annot.params, {'Cluster method', 'k-means'});
        ei_clustermethod = 'kmeans';
    else
%         annot.params = cellpush(annot.params, {'Cluster method', 'agglomerative (Matlab clusterdata)'});
        annot.params = {'Cluster method', 'agglomerative (Matlab clusterdata)'};
        ei_clustermethod = 'aggl';
    end
    boundary_bands{i}=bound_time{i};
end
computer_time = bound_time';
save('computer_time.mat','computer_time');
%clearvars('-except','boundary_bands');


save('temp.mat','boundary_bands','skip','-v7');
clear;
load('temp.mat');
load('ground_truth.mat');

%% 计算准确率

for i=1:length(boundary_bands)
    temp=ground_set{i,1};
    temp=temp{1,1};
    ground_truth{i}=temp{1,1};
end

hit=0;
%减去时间为0的点
bround_cal=0;
bround_ground=0;
offset=0;
p_simple_wav=[];
r_simple_wav=[];
f_simple_wav=[];


for i=1:length(boundary_bands)
    hit_simple_wav=0;
    boundary=boundary_bands{i};
    ground=ground_truth{i};
    bround_cal=bround_cal+length(boundary);
    bround_ground=bround_ground+length(ground);
    for j=1:length(boundary)
        for k=1:length(ground)
           if abs(boundary(j)-ground(k))<=3
              hit=hit+1;
              hit_simple_wav=hit_simple_wav+1;
              break;
           end
        end
    end
    p_simple_wav(i)=hit_simple_wav/length(boundary);
    r_simple_wav(i)=hit_simple_wav/length(ground);
    f_simple_wav(i)=2*r_simple_wav(i)*p_simple_wav(i)/(p_simple_wav(i)+r_simple_wav(i));
end
r=hit/bround_ground
p=hit/bround_cal
f=2*p*r/(p+r)
