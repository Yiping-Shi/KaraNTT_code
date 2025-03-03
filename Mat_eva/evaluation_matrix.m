clc
clear
close all

%% 构造Evaluation矩阵
% 2  --> 3
EVAL_1 = [1 0; 1 1; 0 1];
% 4  --> 9
EVAL_2 = kron(EVAL_1, EVAL_1);
% 8  --> 27
EVAL_3 = kron(EVAL_2, EVAL_1);
% 16 --> 81
EVAL_4 = kron(EVAL_3, EVAL_1);
% 32 --> 243
EVAL_5 = kron(EVAL_4, EVAL_1);
% 64 --> 729
EVAL_6 = kron(EVAL_5, EVAL_1);

%% 统计加法数量
nz_num = sum(EVAL_6,2);

% 定义目标值列表（必须包含所有可能值）
target_values = [1, 2, 4, 8, 16, 32, 64]; 
% 统计各值出现次数
counts = sum(nz_num == target_values, 1)';  % 结果列为[7x1]向量
% 显示结果（可选）
disp(table(target_values', counts, ...
          'VariableNames', {'nnz', '出现行数'}));

%% 分析稀疏矩阵
% 非零元素分布图
figure(1);
spy(EVAL_6);
figure(2);
spy(EVAL_4);
figure(3);
subplot(2,3,1);
spy(EVAL_6(1:3, 1:2));
subplot(2,3,2);
spy(EVAL_6(1:9, 1:4));
subplot(2,3,3);
spy(EVAL_6(1:27, 1:8));
subplot(2,3,4);
spy(EVAL_6(1:81, 1:16));
subplot(2,3,5);
spy(EVAL_6(1:243, 1:32));
subplot(2,3,6);
spy(EVAL_6(1:729, 1:64));
% LU分解
[L, U, P] = lu(EVAL_6);

%% 分析16-81的计算过程
% % 沿行方向求和，结果为81x1向量
% row_counts = sum(EVAL_4 == 1, 2);
% % 获取所有1的行列索引
% [row_idx, col_idx] = find(EVAL_4 == 1);
% % 将结果按行分组存储为cell数组
% positions = accumarray(row_idx, col_idx, [size(EVAL_4,1), 1], @(x){x});
% for i = 1 : size(EVAL_4,1)
%     fprintf('Row %d: %d ones at columns %s\n',...
%         i, row_counts(i), mat2str(positions{i}));
% end

%% 分析64-729的计算过程
% 沿行方向求和，结果为729x1向量
row_counts = sum(EVAL_6 == 1, 2);
% 获取所有1的行列索引
[row_idx, col_idx] = find(EVAL_6 == 1);
% 将结果按行分组存储为cell数组
positions = accumarray(row_idx, col_idx, [size(EVAL_6,1), 1], @(x){x});
for i = 1 : size(EVAL_6,1)
    fprintf('Row %d: %d ones at columns %s\n',...
        i, row_counts(i), mat2str(positions{i}));
end
