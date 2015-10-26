function [ boundary_feature_left,...
            boundary_feature_right,...
            boundary_feature_mfcct,...
            boundary_feature_spec_left,...
            boundary_feature_spec_right,...
            ground_feature_left,...
            ground_feature_right,...
            ground_feature_mfcc,...
            ground_feature_spec_left,...
            ground_feature_spec_right,...
            ground_label_new] = get_segment_feature()
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
%% 加载数据
%左声道的plp和谱特征
load('plp_features_just_plp_v7.mat');

%右声道的plp和谱特征
load('plp_features_just_plp_right_v7.mat');

%双声道的MFCC特征
load('mfcc_features_stereo182.mat');

%检测到的边界点
load('best_boundary.mat');
boundary_bands=boundary_bands';

%音乐总长度
load('music_length.mat');

%ground truth
load('ground_truth_v7.mat');

%ground label
load('ground_truth_label_v7.mat');
ground_label_new=prepare_ground_labels(ground_label);

for i=1:size(ground,1)
   ground{i,1}=[0, ground{i,1}',music_length(i)];
end
%% 分离特征
plp_left=cell(0);
spec_left=cell(0);
plp_right=cell(0);
spec_right=cell(0);

for i=1:length(plp_feature)
    plp_left{i,1}=plp_feature{i,1}{1,1};
    spec_left{i,1}=plp_feature{i,1}{1,2};
    plp_right{i,1}=plp_feature_right{i,1}{1,1};
    spec_right{i,1}=plp_feature_right{i,1}{1,2};
end

%% 获取按边界点划分后的特征的均值
boundary_feature_left=get_boundary_indieces(boundary_bands,music_length,plp_left);
boundary_feature_right=get_boundary_indieces(boundary_bands,music_length,plp_right);
boundary_feature_mfcct=get_boundary_indieces(boundary_bands,music_length,new_mfcc);
boundary_feature_spec_left=get_boundary_indieces(boundary_bands,music_length,spec_left);
boundary_feature_spec_right=get_boundary_indieces(boundary_bands,music_length,spec_right);
ground_feature_left=get_boundary_indieces(ground,music_length,plp_left);
ground_feature_right=get_boundary_indieces(ground,music_length,plp_right);
ground_feature_mfcc=get_boundary_indieces(ground,music_length,new_mfcc);
ground_feature_spec_left=get_boundary_indieces(ground,music_length,spec_left);
ground_feature_spec_right=get_boundary_indieces(ground,music_length,spec_right);

end

