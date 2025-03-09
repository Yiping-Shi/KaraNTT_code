% Generate a random polynomial of degree n-1 with coefficients in Z_q
function poly = random_poly(n, q)
    poly = randi([0, q-1], n, 1);
end