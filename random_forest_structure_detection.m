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

random_index=randperm(numel(1:length(ground_feature_spec_left)));

n_test=20;

%% 选择特征
%训练特征
train_feadture=cell(0);

for i=1:length(random_index)-n_test
    train_feadture{i,1}=ground_feature_spec_left{random_index(i),1}(1:49,1:end-2);
    train_feadture{i,1}=[train_feadture{i,1};ground_feature_spec_right{random_index(i),1}(1:49,1:end-2)];
end

%测试特征
test_feature=cell(0);
offset=1;
for i=length(random_index)-n_test+1:length(random_index)
    test_feature{offset,1}=boundary_feature_spec_left{random_index(i),1}(1:49,1:end-1);
    test_feature{offset,1}=[test_feature{offset,1};boundary_feature_spec_right{random_index(i),1}(1:49,1:end-1)];
    offset=offset+1;
end

%训练标签
train_label=cell(0);

for i=1:length(random_index)-n_test
    train_label{i,1}=ground_label_new{random_index(i),1};
end

%测试标签
test_label=cell(0);
offset=1;
for i=length(random_index)-n_test+1:length(random_index)
    test_label{offset,1}=ground_label_new{random_index(i),1};
    offset=offset+1;
end


%% 训练一个随机森林
%初始化训练特征
train_X=[];
for i=1:length(train_feadture)
    train_X=[train_X train_feadture{i,1}];
end
train_X(isnan(train_X))=0;
train_X=train_X';

%初始化训练标签
train_Y=[];
for i=1:length(train_label)
    train_Y=[train_Y train_label{i,1}];
end

%森林中的树的个数
nTree=200;

B = TreeBagger(nTree,train_X,train_Y);

%% 使用训练出的随进森林进行预测
%初始化测试特征矩阵
% test_X=[];
% for i=1:length(test_feature)
%     test_X=[test_X test_feature{i,1}];
% end
% test_X(isnan(test_X))=0;
% test_X=test_X';

%初始化测试标签
test_Y=cell(0);
for i=1:length(test_label)
    test_Y{i,1}=test_label{i,1};
end

test_X=[];
predict_label=cell(0);
for i=1:length(test_feature)
    %测试特征
    test_X=test_feature{i,1}';
    %预测
    predict_label{i,1}=predict(B,test_X);
end

%初始化测试集边界点时间
test_ground=cell(0);
test_boundary_bands=cell(0);
offset=1;
for i=length(random_index)-n_test+1:length(random_index)
    test_ground{offset,1}=ground{random_index(i),1};
    test_boundary_bands{offset,1}=boundary_bands{random_index(i),1};
    offset=offset+1;
end

%预测
% predict_label = predict(B,test_X);

%% 评估预测结果
[R,P,F]=accuracy_evaluation(test_Y,predict_label,test_ground,test_boundary_bands );
mean(R)
mean(P)
mean(F)