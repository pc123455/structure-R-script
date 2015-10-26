clear all;
close all;

%ground truth
load('ground_truth_v7.mat');

%检测到的边界点
load('best_boundary.mat');
boundary_bands=boundary_bands';

%% 获取训练/测试特征
[ boundary_feature_left,...
  boundary_feature_right,...
  boundary_feature_mfcct,...
  boundary_feature_spec_left,...
  boundary_feature_spec_right,...
  ground_feature_left,...
  ground_feature_right,...
  ground_feature_mfcc,...
  ground_feature_spec_left,...
  ground_feature_spec_right,...
  ground_label_new] = get_segment_feature();

ground_feature_left=ground_feature_spec_left;
ground_feature_right=ground_feature_spec_right;


%% 对计算好的特征进行预处理 调整数据格式
%首先计算ground中最大片段个数
ncol=[];
for i=1:length(ground_feature_left)
    cur_mean_feature=ground_feature_left{i,1};
    ncol(end+1)=size(cur_mean_feature,2);
end

%ncol=max(ncol);
ncol=18;

%预处理训练数据 使用0将ground的特征扩展为最大列数 
for i=1:length(ground_feature_left)
    ground_feature_left{i,1}(isnan(ground_feature_left{i,1}))=0;
    ground_feature_left{i,1}=[ground_feature_left{i,1},zeros(size(ground_feature_left{i,1},1),ncol-size(ground_feature_left{i,1},2))];
    
    ground_feature_right{i,1}(isnan(ground_feature_right{i,1}))=0;
    ground_feature_right{i,1}=[ground_feature_right{i,1},zeros(size(ground_feature_right{i,1},1),ncol-size(ground_feature_right{i,1},2))];
    
    ground_feature_mfcc{i,1}(isnan(ground_feature_mfcc{i,1}))=0;
    ground_feature_mfcc{i,1}=[ground_feature_mfcc{i,1},zeros(size(ground_feature_mfcc{i,1},1),ncol-size(ground_feature_mfcc{i,1},2))];
end

%预处理训练数据 使用0将ground的label扩展为最大列数 
for i=1:length(ground_label_new)
    %ground_label_new{i,1}(isnan(ground_feature_left{i,1}))=0;
    ground_label_new{i,1}=[ground_label_new{i,1},zeros(size(ground_label_new{i,1},1),ncol-size(ground_label_new{i,1},2))];
    ground_label_new{i,1}(ground_label_new{i,1}==0)=8;
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
adj = adj';
%adj(end,:)=0;
%adj(end,end)=1;

edgeStruct = UGM_makeEdgeStruct(adj,nStates);
nEdges = edgeStruct.nEdges;
maxState = max(nStates);



%% Training (with node features, but no edge features)

% Make simple bias features
nFeatures = 98;
Xnode = zeros(nInstances,nFeatures,nNodes);
Xedge = ones(nInstances,1,nEdges);
%设置特征
for i=1:length(ground_feature_left)
    %size(ground_feature_left{i,1})
    %size(ground_feature_right{i,1})
    Xnode(i,:,:)=[ground_feature_left{i,1}(1:49,:);ground_feature_right{i,1}(1:49,:)];
end
Xnode = [ones(nInstances,1,nNodes) Xnode];
Xnode=Xnode+1;
nNodeFeatures = size(Xnode,2);

% Make nodeMap
nodeMap = ones(nNodes,maxState,nNodeFeatures,'int32');
for f = 1:nNodeFeatures
    nodeMap(:,1,f) = f;
    nodeMap(:,2,f) = f;
    nodeMap(:,3,f) = f;
    nodeMap(:,4,f) = f;
    nodeMap(:,5,f) = f;
    nodeMap(:,6,f) = f;
%     nodeMap(:,7,f) = f;
%     nodeMap(:,8,f) = f;
%     nodeMap(:,9,f) = f;
%     nodeMap(:,10,f) = f;
%     nodeMap(:,11,f) = f;
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

% Example of making potentials for the first training example
instance = 1;
edgeStruct.useMex=0;
[nodePot,edgePot] = UGM_CRF_makePotentials(w,Xnode,Xedge,nodeMap,edgeMap,edgeStruct,instance);
%fprintf('(paused)\n');
%pause

%% Now see what samples in July look like

%测试集特征
%XtestNode = X; % Turn on bias and indicator variable for July
%XtestNode = repmat(XtestNode,[1 1 nNodes]);
XtestNode=Xnode(1,:,:);

sharedFeatures=1:19;

%XtestEdge = UGM_makeEdgeFeatures(XtestNode,edgeStruct.edgeEnds,sharedFeatures);
XtestEdge = ones(182,1,nEdges);

[nodePot,edgePot] = UGM_CRF_makePotentials(w,XtestNode,XtestEdge,nodeMap,edgeMap,edgeStruct);
%nodeBel = UGM_Decode_Exact(nodePot,edgePot,edgeStruct);
samples = UGM_Sample_Chain(nodePot,edgePot,edgeStruct);
figure;
imagesc(samples')
%title('Samples from CRF model (for July)');


% %% Training with L2-regularization
% 
% % Set up regularization parameters
% lambda = 10*ones(size(w));
% lambda(1) = 0; % Don't penalize node bias variable
% lambda(14:17) = 0; % Don't penalize edge bias variable
% regFunObj = @(w)penalizedL2(w,@UGM_CRF_NLL,lambda,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct,@UGM_Infer_Chain);
% 
% % Optimize
% w = zeros(nParams,1);
% w = minFunc(regFunObj,w);
% NLL = UGM_CRF_NLL(w,Xnode,Xedge,y,nodeMap,edgeMap,edgeStruct,@UGM_Infer_Chain)
