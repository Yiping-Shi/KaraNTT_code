clear
clc
close

%% Init
a = randi([1, 10], 16, 1);
b = randi([1, 10], 16, 1);

%% Evaluation
EVAL_1 = [1 0; 1 1; 0 1];
EVAL_2 = kron(EVAL_1, EVAL_1);
EVAL_4 = kron(EVAL_2, EVAL_2);

A = EVAL_4 * a;
B = EVAL_4 * b;

%% Element-wise Mult
C = A .* B;

%% Interpolation
INTERP_1 = [1 0 0; -1 1 -1; 0 0 1];

INTERP_2_temp = kron(INTERP_1, INTERP_1);
INTERP_2 = zeros(7,9);
INTERP_2(1:2,:) = INTERP_2_temp(1:2,:);
INTERP_2(3,:) = INTERP_2_temp(3,:) + INTERP_2_temp(4,:);
INTERP_2(4,:) = INTERP_2_temp(5,:);
INTERP_2(5,:) = INTERP_2_temp(6,:) + INTERP_2_temp(7,:);
INTERP_2(6:7,:) = INTERP_2_temp(8:9,:);

INTERP_3_temp = kron(INTERP_2, INTERP_1);
INTERP_3 = zeros(15, 27);
INTERP_3(1:2,:)    = INTERP_3_temp(1:2,:);
INTERP_3(3,:)      = INTERP_3_temp(3,:) + INTERP_3_temp(4,:);
INTERP_3(4,:)      = INTERP_3_temp(5,:);
INTERP_3(5,:)      = INTERP_3_temp(6,:) + INTERP_3_temp(7,:);
INTERP_3(6,:)      = INTERP_3_temp(8,:);
INTERP_3(7,:)      = INTERP_3_temp(9,:) + INTERP_3_temp(10,:);
INTERP_3(8,:)      = INTERP_3_temp(11,:);
INTERP_3(9,:)      = INTERP_3_temp(12,:) + INTERP_3_temp(13,:);
INTERP_3(10,:)     = INTERP_3_temp(14,:);
INTERP_3(11,:)     = INTERP_3_temp(15,:) + INTERP_3_temp(16,:);
INTERP_3(12,:)     = INTERP_3_temp(17,:);
INTERP_3(13,:)     = INTERP_3_temp(18,:) + INTERP_3_temp(19,:);
INTERP_3(14:15,:)  = INTERP_3_temp(20:21,:);

INTERP_4_temp = kron(INTERP_3, INTERP_1);
INTERP_4 = zeros(31, 81);
INTERP_4(1:2,:)    = INTERP_4_temp(1:2,:);
INTERP_4(3,:)      = INTERP_4_temp(3,:) + INTERP_4_temp(4,:);
INTERP_4(4,:)      = INTERP_4_temp(5,:);
INTERP_4(5,:)      = INTERP_4_temp(6,:) + INTERP_4_temp(7,:);
INTERP_4(6,:)      = INTERP_4_temp(8,:);
INTERP_4(7,:)      = INTERP_4_temp(9,:) + INTERP_4_temp(10,:);
INTERP_4(8,:)      = INTERP_4_temp(11,:);
INTERP_4(9,:)      = INTERP_4_temp(12,:) + INTERP_4_temp(13,:);
INTERP_4(10,:)     = INTERP_4_temp(14,:);
INTERP_4(11,:)     = INTERP_4_temp(15,:) + INTERP_4_temp(16,:);
INTERP_4(12,:)     = INTERP_4_temp(17,:);
INTERP_4(13,:)     = INTERP_4_temp(18,:) + INTERP_4_temp(19,:);
INTERP_4(14,:)     = INTERP_4_temp(20,:);
INTERP_4(15,:)     = INTERP_4_temp(21,:) + INTERP_4_temp(22,:);
INTERP_4(16,:)     = INTERP_4_temp(23,:);
INTERP_4(17,:)     = INTERP_4_temp(24,:) + INTERP_4_temp(25,:);
INTERP_4(18,:)     = INTERP_4_temp(26,:);
INTERP_4(19,:)     = INTERP_4_temp(27,:) + INTERP_4_temp(28,:);
INTERP_4(20,:)     = INTERP_4_temp(29,:);
INTERP_4(21,:)     = INTERP_4_temp(30,:) + INTERP_4_temp(31,:);
INTERP_4(22,:)     = INTERP_4_temp(32,:);
INTERP_4(23,:)     = INTERP_4_temp(33,:) + INTERP_4_temp(34,:);
INTERP_4(24,:)     = INTERP_4_temp(35,:);
INTERP_4(25,:)     = INTERP_4_temp(36,:) + INTERP_4_temp(37,:);
INTERP_4(26,:)     = INTERP_4_temp(38,:);
INTERP_4(27,:)     = INTERP_4_temp(39,:) + INTERP_4_temp(40,:);
INTERP_4(28,:)     = INTERP_4_temp(41,:);
INTERP_4(29,:)     = INTERP_4_temp(42,:) + INTERP_4_temp(43,:);
INTERP_4(30:31,:)  = INTERP_4_temp(44:45,:);

% c_temp = INTERP_4 * C;

%% Normalization
NORM = eye(16,31);
NORM(1:15,17:31) = NORM(1:15,17:31) - eye(15,15);
% c = NORM * c_temp;
POSTprocess = NORM*INTERP_4;
c = POSTprocess * C;

%% Verification
ref = conv(a,b);
c_ref = NORM * ref;

fprintf('c = \n');
disp(c');
fprintf('c_ref = \n');
disp(c_ref');

if isequal(c, c_ref)
    disp('Verification Passed');
else
    disp('Verification Failed');
end
fprintf('\n');

%% Sparse Matrix Analysis
figure('Name','Sparsity Pattern of EVAL_4');
spy(EVAL_4);
title('Sparsity Pattern of EVALUALTION 4 (81x16)');
grid on;

figure('Name','Sparsity Pattern of (NORM*INTERP)_4');
spy(POSTprocess);
title('Sparsity Pattern of (NORM * INTERPOLATION 4) (16x81)');
grid on;

%% Row-wise Nonzero Distribution Analysis
eval_row_nnz = sum(EVAL_4 ~= 0, 2); % 按行求和
figure('Name','Row-wise Nonzero Distribution of EVAL_4');
histogram(eval_row_nnz, 'BinMethod','integers', 'FaceColor',[0.2 0.6 0.9]);
xlabel('Number of Nonzeros per Row');
ylabel('Row Count');
title(sprintf('Distribution (Mean=%.1f, Max=%d)', mean(eval_row_nnz), max(eval_row_nnz)));
xticks(0:max(eval_row_nnz)); 
grid on;
text(0.7*max(eval_row_nnz), 0.8*max(ylim), ...
    sprintf('Total Rows: %d\nStd Dev: %.2f', size(EVAL_4,1), std(eval_row_nnz)),...
    'FontSize',10);

post_row_nnz = sum(POSTprocess ~= 0, 2); % 按行求和
figure('Name','Row-wise Nonzero Distribution of (NORM*INTERP)_4');
histogram(post_row_nnz, 'BinMethod','integers', 'FaceColor',[0.2 0.6 0.9]);
xlabel('Number of Nonzeros per Row');
ylabel('Row Count');
title(sprintf('Distribution (Mean=%.1f, Max=%d)', mean(post_row_nnz), max(post_row_nnz)));
xticks(0:max(post_row_nnz)); 
grid on;
text(0.7*max(post_row_nnz), 0.8*max(ylim), ...
    sprintf('Total Rows: %d\nStd Dev: %.2f', size(POSTprocess,1), std(post_row_nnz)),...
    'FontSize',10);


%% EVALUATION Analysis
disp('-------- EVALUATION 4 (81x16) --------');
eval_row_counts = sum(EVAL_4 == 1, 2);
[eval_row_idx, eval_col_idx] = find(EVAL_4 == 1);
eval_positions = accumarray(eval_row_idx, eval_col_idx, [size(EVAL_4,1), 1], @(x){x});
for i = 1 : size(EVAL_4,1)
    fprintf('Row %d: %d ones at columns %s\n',...
        i-1, eval_row_counts(i), mat2str(eval_positions{i}-1));
end
fprintf("\n");

%% INTERPOLATION Analysis
disp('-------- NORM * INTERPOLATION 4 (16x81) --------');
interp_row_counts = sum(POSTprocess ~= 0, 2);
[interp_row_idx, interp_col_idx] = find(POSTprocess ~= 0);
interp_positions = accumarray(interp_row_idx, interp_col_idx, [size(POSTprocess,1), 1], @(x){x});
for i = 1 : size(POSTprocess,1)
    fprintf('Row %d: %d ones at columns %s\n',...
        i-1, interp_row_counts(i), mat2str(interp_positions{i}-1));
end
