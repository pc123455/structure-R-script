%function get_music_boundary_indices(music_length,boundaries,features)

clear all;
close all;

%% ��������
%��������plp��������
load('plp_features_just_plp_v7.mat');

%��⵽�ı߽��
load('best_boundary.mat');
boundary_bands=boundary_bands';

%�����ܳ���
load('music_length.mat');

%ground truth
load('ground_truth_v7.mat');

%ground label
load('ground_truth_label_v7.mat');
ground_label_new=prepare_ground_labels(ground_label);

for i=1:size(ground,1)
   ground{i,1}=[0, ground{i,1}',music_length(i)];
end
%% ��������
plp_left=cell(0);
spec_left=cell(0);

for i=1:length(plp_feature)
    plp_left{i,1}=plp_feature{i,1}{1,1};
    spec_left{i,1}=plp_feature{i,1}{1,2};
end

%% ��ȡ���߽�㻮�ֺ�������ľ�ֵ
boundary_feature=get_boundary_indieces(boundary_bands,music_length,plp_left);
ground_feature=get_boundary_indieces(ground,music_length,plp_left);


%% �Լ���õ���������Ԥ���� �������ݸ�ʽ
%���ȼ���ground�����Ƭ�θ���
ncol=[];
for i=1:length(ground_feature)
    cur_mean_feature=ground_feature{i,1};
    ncol(end+1)=size(cur_mean_feature,2);
end

ncol=max(ncol);

%Ԥ����ѵ������ ʹ��0��ground��������չΪ������� 
for i=1:length(ground_feature)
    ground_feature{i,1}(isnan(ground_feature{i,1}))=0;
    ground_feature{i,1}=[ground_feature{i,1},zeros(size(ground_feature{i,1},1),ncol-size(ground_feature{i,1},2))];
end

%Ԥ����ѵ������ ʹ��0��ground��label��չΪ������� 
for i=1:length(ground_label_new)
    %ground_label_new{i,1}(isnan(ground_feature{i,1}))=0;
    ground_label_new{i,1}=[ground_label_new{i,1},zeros(size(ground_label_new{i,1},1),ncol-size(ground_label_new{i,1},2))];
end
%% ���ò���ֵ
%�ڵ���
nNodes=ncol;
%״̬��
nStates=8;
%ѵ��������
nInstances=182;
%ѵ������
X=[];
for i=1:length(ground_label_new)
    X=[X;ground_label_new{i,1}];
end
y = int32(X);
%�ڽӾ���
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
%��������
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