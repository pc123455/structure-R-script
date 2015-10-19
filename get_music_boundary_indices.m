%function get_music_boundary_indices(music_length,boundaries,features)

clear all;
close all;

%% 加载数据
%左声道的plp和谱特征
load('plp_features_just_plp_v7.mat');

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

for i=1:length(plp_feature)
    plp_left{i,1}=plp_feature{i,1}{1,1};
    spec_left{i,1}=plp_feature{i,1}{1,2};
end

%% 获取按边界点划分后的特征的均值
boundary_feature=get_boundary_indieces(boundary_bands,music_length,plp_left);
ground_feature=get_boundary_indieces(ground,music_length,plp_left);


%% 对计算好的特征进行预处理 调整数据格式
%首先计算ground中最大片段个数
ncol=[];
for i=1:length(ground_feature)
    cur_mean_feature=ground_feature{i,1};
    ncol(end+1)=size(cur_mean_feature,2);
end

ncol=max(ncol);

%预处理训练数据 使用0将ground的特征扩展为最大列数 
for i=1:length(ground_feature)
    ground_feature{i,1}(isnan(ground_feature{i,1}))=0;
    ground_feature{i,1}=[ground_feature{i,1},zeros(size(ground_feature{i,1},1),ncol-size(ground_feature{i,1},2))];
end

%预处理训练数据 使用0将ground的label扩展为最大列数 
for i=1:length(ground_label_new)
    %ground_label_new{i,1}(isnan(ground_feature{i,1}))=0;
    ground_label_new{i,1}=[ground_label_new{i,1},zeros(size(ground_label_new{i,1},1),ncol-size(ground_label_new{i,1},2))];
end
%% 设置参数值
%节点数
nNodes=ncol;
%状态数
nStates=8;
%训练样本数
nInstances=182;
%训练矩阵
X=[];
for i=1:length(ground_label_new)
    X=[X;ground_label_new{i,1}];
end
y = int32(X);
%邻接矩阵
adj = zeros(nNodes);
for i = 1:nNodes-1
    adj(i,i+1) = 1;
end
adj = adj+adj';
%adj(end,:)=0;
%adj(end,end)=1;

edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;
maxState = max(nStates);

%% Training (no features)
% Make simple bias features
Xnode = ones(nInstances,1,nNodes);
Xedge = ones(nInstances,1,nEdges);

% Make nodeMap
nodeMap = zeros(nNodes,maxState,'int32');
nodeMap(:,1) = 1;

edgeMap = zeros(maxState,maxState,nEdges,'int32');
edgeMap(1,1,:) = 2;
edgeMap(2,1,:) = 3;
edgeMap(1,2,:) = 4;

% Initialize weights
nParams = max([nodeMap(:);edgeMap(:)]);
w = zeros(nParams,1);

% Optimize
w = minFunc(@UGM_CRF_NLL,randn(size(w)),[],Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct,@UGM_Infer_Chain)

% Example of making potentials for the first training example
instance = 1;
[nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct,instance);
nodePot(1,:)
edgePot(:,:,1)
fprintf('(paused)\n');
%pause
%% Training (with node features, but no edge features)

% Make simple bias features
nFeatures = 9;
Xnode = zeros(nInstances,nFeatures,nNodes);
%设置特征
for i=1:length(ground_feature)
    Xnode(i,:,:)=ground_feature{i,1};
end
Xnode = [ones(nInstances,1,nNodes) Xnode];
nNodeFeatures = size(Xnode,2);

% Make nodeMap
nodeMap = zeros(nNodes,maxState,nNodeFeatures,'int32');
for f = 1:nNodeFeatures
    nodeMap(:,1,f) = f;
end

% Make edgeMap
edgeMap = zeros(maxState,maxState,nEdges,'int32');
edgeMap(1,1,:) = nNodeFeatures+1;
edgeMap(2,1,:) = nNodeFeatures+2;
edgeMap(1,2,:) = nNodeFeatures+3;

% Initialize weights
nParams = max([nodeMap(:);edgeMap(:)]);
w = zeros(nParams,1);

% Optimize
w = minFunc(@UGM_CRF_NLL,w,[],Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct,@UGM_Infer_Chain)
fprintf('(paused)\n');
pause


%% Do conditional decoding/inference/sampling in learned model (given features)

clamped = zeros(nNodes,1);
clamped(1:2) = 2;

condDecode = UGM_Decode_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Decode_Chain)
condNodeBel = UGM_Infer_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Infer_Chain)
condSamples = UGM_Sample_Conditional(nodePot,edgePot,edgeStruct,clamped,@UGM_Sample_Chain);

figure(2);
imagesc(condSamples')
title('Conditional samples from CRF model (for December)');
fprintf('(paused)\n');
pause