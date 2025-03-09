% Polynomial multiplication based on Karatsuba (using transformation matrix)
function result = poly_mul_karatsuba_matrix(a, b, q, EVAL, POSTprocess)
    % Convert the polynomial to column vector
    if size(a, 2) > size(a, 1)
        a = a';
    end
    if size(b, 2) > size(b, 1)
        b = b';
    end
    
    % Step 1: Evaluate the polynomial in the evaluation domain
    A_eval = mod(EVAL * a, q);
    B_eval = mod(EVAL * b, q);
    
    % Step 2: Multiply the polynomials in the evaluation domain
    C_eval = zeros(size(A_eval));
    for i = 1:length(A_eval)
        C_eval(i) = mod_mul(A_eval(i), B_eval(i), q);
    end
    
    % Step 3: Interpolate the polynomial in the evaluation domain
    % Attention: POSTprocess already includes interpolation and normalization
    result = mod(POSTprocess * C_eval, q);
end