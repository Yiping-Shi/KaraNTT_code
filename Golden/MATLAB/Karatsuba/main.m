%% Karatsuba Polynomial Multiplication Reference Model - Based on Transformation Matrix
% Polynomial ring computation for FHE context (N=16, q=998244353)

clear;
close all;
clc;

%% Global Parameters Definition
N = 16;         % Polynomial order
q = 998244353;  % Modulus (prime near 2^30) 
% q = 17;

%% Main Function

% Construct transformation matrices
[EVAL, INTERP, POSTprocess] = build_transform_matrices();

% Analyze matrix structure
analyze_matrices(EVAL, INTERP, POSTprocess);
fprintf('\n');
% Generate RTL-compatible matrix definitions
% generate_rtl_matrices(EVAL, POSTprocess);
extract_matrix_patterns(EVAL, POSTprocess);
fprintf('\n');
% Performance comparison test
compare_methods(1000, q, EVAL, POSTprocess);
fprintf('\n');
% Generate RTL test vectors
% generate_test_vectors(20, EVAL, POSTprocess, q);

% Trace computation path
% trace_computation_path(POSTprocess);

% Demonstrate a simple example
fprintf('\nSimple Example Demonstration:\n');
a = randi([1, 10], 16, 1);
b = randi([1, 10], 16, 1);

fprintf('Polynomial a: %s\n', mat2str(a'));
fprintf('Polynomial b: %s\n', mat2str(b'));

% Compute using matrix method
result_matrix = poly_mul_karatsuba_matrix(a, b, q, EVAL, POSTprocess);
fprintf('Matrix Method Result: %s\n', mat2str(result_matrix'));

% Verify using naive method
result_naive = poly_mul_naive(a, b, q);
fprintf('Naive Method Result: %s\n', mat2str(result_naive'));

if all(result_matrix == result_naive)
    fprintf('Results Match! ✓\n');
else
    fprintf('Results Do Not Match! ✗\n');
end