% Naive polynomial multiplication (for verification)
function result = poly_mul_naive(a, b, q)
    n = length(a);
    
    % Convert to column vector
    if size(a, 2) > size(a, 1)
        a = a';
    end
    if size(b, 2) > size(b, 1)
        b = b';
    end
    
    % Initialize result
    result_full = zeros(2*n-1, 1);
    
    % Standard polynomial multiplication
    for i = 1:n
        for j = 1:n
            result_full(i+j-1) = mod_add(result_full(i+j-1), mod_mul(a(i), b(j), q), q);
        end
    end
    
    % Reduction in the ring (x^n = -1)
    result = zeros(n, 1);
    for i = 1:n
        result(i) = result_full(i);
    end
    for i = n+1:2*n-1
        result(i-n) = mod_sub(result(i-n), result_full(i), q);
    end
end