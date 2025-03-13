# Modular inverse (https://stackoverflow.com/questions/4798654/modular-multiplicative-inverse-function-in-python)
def egcd(a, b):
    if a == 0:
        return (b, 0, 1)
    else:
        g, y, x = egcd(b % a, a)
        return (g, x - (b // a) * y, y)

def modinv(a, m):
    g, x, y = egcd(a, m)
    if g != 1:
        raise Exception('Modular inverse does not exist')
    else:
        return x % m
    

# Test
q = 998244353
g = 3
# -------------------
phi_256 = pow(g, (q-1)//256, q)
phi_256_inv = modinv(phi_256, q)
print(f"phi_256: {phi_256}")
print(f"phi_256_inv: {phi_256_inv}")
# -------------------
phi = pow(g, (q-1)//65536, q)
phi_inv = modinv(phi, q)
print(f"phi: {phi}")
print(f"phi_inv: {phi_inv}")
# -------------------
psi = pow(g, (q-1)//(65536*2), q)
psi_inv = modinv(psi, q)
print(f"psi: {psi}")
print(f"psi_inv: {psi_inv}")

