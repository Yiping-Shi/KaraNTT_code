clear
clc
close

%% Init
a = randi([1, 10], 4, 1);
b = randi([1, 10], 4, 1);

%% Evaluation
EVAL_1 = [1 0; 1 1; 0 1];
EVAL_2 = kron(EVAL_1, EVAL_1);

A = EVAL_2 * a;
B = EVAL_2 * b;

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

c_temp = INTERP_2 * C;

%% Normalization
NORM = eye(4,7);
NORM(1:3,5:7) = NORM(1:3,5:7) - eye(3,3);
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
fprintf("a = \n");
disp(a');
fprintf("b = \n");
disp(b');
fprintf("c_temp = \n");
disp(c_temp');
fprintf("ref = \n");
disp(ref');