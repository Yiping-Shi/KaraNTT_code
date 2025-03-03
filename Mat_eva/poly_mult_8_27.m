clear
clc
close

%% Init
rng(1);
a = randi([1, 10], 8, 1);
b = randi([1, 10], 8, 1);

%% Evaluation
EVAL_1 = [1 0; 1 1; 0 1];
EVAL_2 = kron(EVAL_1, EVAL_1);
EVAL_3 = kron(EVAL_2, EVAL_1);

A = EVAL_3 * a;
B = EVAL_3 * b;

%% Element-wise Mult
C = A .* B;

%% Interpolation
INTERP_1 = [1 0 0; -1 1 -1; 0 0 1];

INTERP_2_temp = kron(INTERP_1, INTERP_1);
INTERP_2 = zeros(7,9);
INTERP_2(1:2,:) = INTERP_2_temp(1:2,:);
INTERP_2(3,:)   = INTERP_2_temp(3,:) + INTERP_2_temp(4,:);
INTERP_2(4,:)   = INTERP_2_temp(5,:);
INTERP_2(5,:)   = INTERP_2_temp(6,:) + INTERP_2_temp(7,:);
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


c_temp = INTERP_3 * C;

%% Normalization
NORM = eye(8,15);
NORM(1:7,9:15) = NORM(1:7,9:15) - eye(7,7);
c = NORM * c_temp;

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