% Generate test vectors
function generate_test_vectors(num_vectors, EVAL, POSTprocess, q)
    % Open file
    fid = fopen('test_vectors.txt', 'w');
    
    fprintf(fid, '// Karatsuba polynomial multiplication test vectors (based on matrix transformation)\n');
    fprintf(fid, '// Format: a, b, result (each polynomial has 16 coefficients)\n');
    fprintf(fid, '// Modulus q = %d\n\n', q);
    
    for i = 1:num_vectors
        % Generate random polynomials
        a = random_poly(16, q);
        b = random_poly(16, q);
        result = poly_mul_karatsuba_matrix(a, b, q, EVAL, POSTprocess);
        
        % Verify result
        result_naive = poly_mul_naive(a, b, q);
        
        % Write test vectors
        fprintf(fid, '// Test vector %d\n', i);
        fprintf(fid, 'a: ');
        fprintf(fid, '%d ', a');
        fprintf(fid, '\n');
        
        fprintf(fid, 'b: ');
        fprintf(fid, '%d ', b');
        fprintf(fid, '\n');
        
        fprintf(fid, 'result: ');
        fprintf(fid, '%d ', result');
        fprintf(fid, '\n\n');
        
        % Verify if results match
        if ~all(result == result_naive)
            fprintf('Warning: Test vector %d results do not match!\n', i);
            fprintf('Karatsuba matrix method result: %s\n', mat2str(result'));
            fprintf('Naive method result: %s\n', mat2str(result_naive'));
        end
    end
    
    fclose(fid);
    fprintf('Generated %d test vectors to test_vectors.txt\n', num_vectors);
end