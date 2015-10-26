clear all;
close all;

%ground truth
load('ground_truth_v7.mat');

%��⵽�ı߽��
load('best_boundary.mat');
boundary_bands=boundary_bands';

%% ��ȡѵ��/��������
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

%% ѡ������
%ѵ������
train_feadture=cell(0);

for i=1:length(random_index)-n_test
    train_feadture{i,1}=ground_feature_spec_left{random_index(i),1}(1:49,1:end-2);
    train_feadture{i,1}=[train_feadture{i,1};ground_feature_spec_right{random_index(i),1}(1:49,1:end-2)];
end

%��������
test_feature=cell(0);
offset=1;
for i=length(random_index)-n_test+1:length(random_index)
    test_feature{offset,1}=boundary_feature_spec_left{random_index(i),1}(1:49,1:end-1);
    test_feature{offset,1}=[test_feature{offset,1};boundary_feature_spec_right{random_index(i),1}(1:49,1:end-1)];
    offset=offset+1;
end

%ѵ����ǩ
train_label=cell(0);

for i=1:length(random_index)-n_test
    train_label{i,1}=ground_label_new{random_index(i),1};
end

%���Ա�ǩ
test_label=cell(0);
offset=1;
for i=length(random_index)-n_test+1:length(random_index)
    test_label{offset,1}=ground_label_new{random_index(i),1};
    offset=offset+1;
end


%% ѵ��һ�����ɭ��
%��ʼ��ѵ������
train_X=[];
for i=1:length(train_feadture)
    train_X=[train_X train_feadture{i,1}];
end
train_X(isnan(train_X))=0;
train_X=train_X';

%��ʼ��ѵ����ǩ
train_Y=[];
for i=1:length(train_label)
    train_Y=[train_Y train_label{i,1}];
end

%ɭ���е����ĸ���
nTree=200;

B = TreeBagger(nTree,train_X,train_Y);

%% ʹ��ѵ���������ɭ�ֽ���Ԥ��
%��ʼ��������������
% test_X=[];
% for i=1:length(test_feature)
%     test_X=[test_X test_feature{i,1}];
% end
% test_X(isnan(test_X))=0;
% test_X=test_X';

%��ʼ�����Ա�ǩ
test_Y=cell(0);
for i=1:length(test_label)
    test_Y{i,1}=test_label{i,1};
end

test_X=[];
predict_label=cell(0);
for i=1:length(test_feature)
    %��������
    test_X=test_feature{i,1}';
    %Ԥ��
    predict_label{i,1}=predict(B,test_X);
end

%��ʼ�����Լ��߽��ʱ��
test_ground=cell(0);
test_boundary_bands=cell(0);
offset=1;
for i=length(random_index)-n_test+1:length(random_index)
    test_ground{offset,1}=ground{random_index(i),1};
    test_boundary_bands{offset,1}=boundary_bands{random_index(i),1};
    offset=offset+1;
end

%Ԥ��
% predict_label = predict(B,test_X);

%% ����Ԥ����
[R,P,F]=accuracy_evaluation(test_Y,predict_label,test_ground,test_boundary_bands );
mean(R)
mean(P)
mean(F)