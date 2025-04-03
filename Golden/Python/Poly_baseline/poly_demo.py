from math import log
from random import randint
import numpy as np

from generate_prime import *
from helper import *
from ntt import *
from poly import *

# Parameter generation

# Determine n and bit-size of q, then find a q satisfying
# the condition: q = 1 (mod 2n) or q = 1 (mod n)
#
# Based on n and q, polynomial multiplication parameters

# Parameters
mod     = 2 # if 1 --> q = 1 (mod n), if 2 --> q = 1 (mod 2n)
n       = 256
q_bit   = 13

q       = 0
w       = 0
w_inv   = 0
psi     = 0
psi_inv = 0

# Generate parameters
wfound = False
while(not(wfound)):
    q = generate_large_prime(q_bit)

    # check q = 1 (mod n or 2n)
    while (not ((q % (mod*n)) == 1)):
        q = generate_large_prime(q_bit)

    # generate NTT parameters
    for i in range(2,q-1):
        wfound = isrootofunity(i,mod*n,q)
        if wfound:
            if mod == 1:
                psi    = 0
                psi_inv= 0
                w      = i
                w_inv  = modinv(w,q)
            else:
                psi    = i
                psi_inv= modinv(psi,q)
                w      = pow(psi,2,q)
                w_inv  = modinv(w,q)
            break

# Print parameters
print("Parameters (NWC)")
print("n      : {}".format(n))
print("q      : {}".format(q))
print("w      : {}".format(w))
print("w_inv  : {}".format(w_inv))
print("psi    : {}".format(psi))
print("psi_inv: {}".format(psi_inv))
print("")

#NOTE: Comment Out Reference Method for Large Parameters

# Demo
# Random A,B
A = [randint(0,q-1) for _ in range(n)]
B = [randint(0,q-1) for _ in range(n)]

# Evaluator
Evaluator = Poly()

# reduce functions
pwc  = [-1]+[0]*(n-1)+[1]
nwc  =  [1]+[0]*(n-1)+[1]

print("-------- Sanity check for polynomial multiplication operations --------")
print("")

# Check reference implementations
D0 = Evaluator.SchoolbookPolMul(A,B,q)
DR0= Evaluator.PolRed(D0,pwc,q) # reduce with x^n-1
DR1= Evaluator.PolRed(D0,nwc,q) # reduce with x^n+1
C0 = Evaluator.SchoolbookModPolMul_PWC(A,B,q)
C1 = Evaluator.SchoolbookModPolMul_NWC(A,B,q)

print("SchoolbookModPolMul_PWC  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(DR0,C0)]) == 0) else "Wrong"))
print("SchoolbookModPolMul_NWC  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(DR1,C1)]) == 0) else "Wrong"))
print("")

# Check NTT-based polynomial multiplication methods
N0 = Evaluator.NTTBasedPolMul(A,B,psi,psi_inv,q)
N1 = Evaluator.NTTBasedModPolMul_PWC(A,B,w,w_inv,q)
N2 = Evaluator.NTTBasedModPolMul_NWC_v1(A,B,w,w_inv,psi,psi_inv,q)
N3 = Evaluator.NTTBasedModPolMul_NWC_v2(A,B,psi,psi_inv,q)

print("NTTBasedPolMul           --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(N0,D0)]) == 0) else "Wrong"))
print("NTTBasedModPolMul_PWC    --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(N1,C0)]) == 0) else "Wrong"))
print("NTTBasedModPolMul_NWC_v1 --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(N2,C1)]) == 0) else "Wrong"))
print("NTTBasedModPolMul_NWC_v2 --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(N3,C1)]) == 0) else "Wrong"))
print("")

# Check CRT-based polynomial multiplication methods
T0 = Evaluator.CRTBasedModPolMul_PWC(A,B,w,w_inv,q)
T1 = Evaluator.CRTBasedModPolMul_NWC_FD1(A,B,psi,psi_inv,q)
T2 = Evaluator.CRTBasedModPolMul_NWC_FD2(A,B,w,w_inv,q)
T3 = Evaluator.CRTBasedModPolMul_NWC_FDV(A,B,psi,psi_inv,q,findeg=1)
T4 = Evaluator.CRTBasedModPolMul_NWC_FDV(A,B,w,w_inv,q,findeg=2)
T5 = Evaluator.CRTBasedModPolMul_NWC_FDV(A,B,w**2 % q,w_inv**2 % q,q,findeg=4)
T6 = Evaluator.CRTBasedModPolMul_NWC_FDV(A,B,w**4 % q,w_inv**4 % q,q,findeg=8)

print("CRTBasedModPolMul_PWC                  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(T0,C0)]) == 0) else "Wrong"))
print("CRTBasedModPolMul_NWC_FD1              --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(T1,C1)]) == 0) else "Wrong"))
print("CRTBasedModPolMul_NWC_FD2              --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(T2,C1)]) == 0) else "Wrong"))
print("CRTBasedModPolMul_NWC_FDV  (findeg=1)  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(T3,C1)]) == 0) else "Wrong"))
print("CRTBasedModPolMul_NWC_FDV  (findeg=2)  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(T4,C1)]) == 0) else "Wrong"))
print("CRTBasedModPolMul_NWC_FDV  (findeg=4)  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(T5,C1)]) == 0) else "Wrong"))
print("CRTBasedModPolMul_NWC_FDV  (findeg=8)  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(T6,C1)]) == 0) else "Wrong"))
print("")


ring,findeg = 0,1
R0 = Evaluator.CRTBasedModPolMul_Unified(A,B,psi,psi_inv,q,ring,findeg) # NWC - findeg=2
ring,findeg = 0,2
R1 = Evaluator.CRTBasedModPolMul_Unified(A,B,w,w_inv,q,ring,findeg) # NWC - findeg=2
ring,findeg = 0,4
R2 = Evaluator.CRTBasedModPolMul_Unified(A,B,w**2 % q,w_inv**2 % q,q,ring,findeg) # NWC - findeg=4

print("CRTBasedModPolMul_Unified (NWC  - findeg=1)  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(R0,C1)]) == 0) else "Wrong"))
print("CRTBasedModPolMul_Unified (NWC  - findeg=2)  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(R1,C1)]) == 0) else "Wrong"))
print("CRTBasedModPolMul_Unified (NWC  - findeg=4)  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(R2,C1)]) == 0) else "Wrong"))
