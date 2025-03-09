% Comparison function
function compare_methods(num_tests, q, EVAL, POSTprocess)
    fprintf('Comparing polynomial multiplication methods (using %d random tests):\n', num_tests);
    
    for i = 1:num_tests
        % Generate random polynomials
        a = random_poly(16, q);
        b = random_poly(16, q);
        
        % Karatsuba matrix method
        tic;
        result_k = poly_mul_karatsuba_matrix(a, b, q, EVAL, POSTprocess);
        time_k = toc;
        
        % Naive method
        tic;
        result_n = poly_mul_naive(a, b, q);
        time_n = toc;
        
        % Verify results
        if ~all(result_k == result_n)
            fprintf('Test %d: Results do not match!\n', i);
        end
        
        % Collect times
        times_k(i) = time_k;
        times_n(i) = time_n;
    end
    
    % Output performance comparison
    fprintf('Average time for naive method: %.6f seconds\n', mean(times_n));
    fprintf('Average time for Karatsuba matrix method: %.6f seconds\n', mean(times_k));
    fprintf('Performance improvement: %.2f times\n', mean(times_n)/mean(times_k));
end