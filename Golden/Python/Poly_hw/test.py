import random
import time
from tqdm import tqdm
import os
import json
import numpy as np
from math import log

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
    
# Bit-Reverse integer
def intReverse(a,n):
    b = ('{:0'+str(n)+'b}').format(a)
    return int(b[::-1],2)

# 保存结果到文件的函数
def save_result_to_file(data, filename):
    # 确保目录存在
    os.makedirs(os.path.dirname(filename), exist_ok=True)
    
    print(f"Saving result to {filename}...")
    with open(filename, 'w') as f:
        json.dump(data, f)
    print(f"Result saved successfully to {filename}")

# 从文件加载结果的函数
def load_result_from_file(filename):
    if os.path.exists(filename):
        print(f"Loading result from {filename}...")
        with open(filename, 'r') as f:
            return json.loads(f.read())
    else:
        print(f"File {filename} not found. Need to compute the result.")
        return None




# ==========================================================

# NTT-Based Modular Polynomial Multiplication with f(x)=x^n+1 (Negative Wrapped Convolution)
# -- with separate pre-processing and post-processing
# A,B: n-1 degree polynomials
# w, w_inv: twiddle factors
# q: coefficient modulus
# C: n-1 degree polynomial
# C(x)=A(x)*B(X) --> C=PostProc(INTT_n(NTT_n(PreProc(A)) . NTT_n(PreProc(B))))
def NTTBasedModPolMul_NWC_baseline(A,B,w,w_inv,psi,psi_inv,q):
    A_p = [(x*pow(psi,i,q)) % q for i,x in enumerate(A)]
    B_p = [(x*pow(psi,i,q)) % q for i,x in enumerate(B)]

    A_ntt = Radix2_DIT_Iterative_NTT_NR(A_p,w,q)
    B_ntt = Radix2_DIT_Iterative_NTT_NR(B_p,w,q)

    C_ntt = [(x*y) % q for x,y in zip(A_ntt,B_ntt)]

    # C_p = Radix2_DIF_Iterative_INTT_RN(C_ntt,w_inv,q)
    C_p = Radix2_DIT_Iterative_INTT_RN(C_ntt,w_inv,q)

    C = [(x*pow(psi_inv,i,q)) % q for i,x in enumerate(C_p)]
    return C

# From paper: NTTU: An Area-Efficient Low-POwer NTT-Uncoupled Architecture for NTT-Based Multiplication
# Iterative Radix-2 Decimation-in-Time (DIT) (CT) NTT - NR
# A: input polynomial (standard order)
# W: twiddle factor
# q: modulus
# B: output polynomial (bit-reversed order)
def Radix2_DIT_Iterative_NTT_NR(A,W,q):
    N = len(A)
    B = [_ for _ in A]

    for s in range(int(log(N,2)),0,-1):
        m = 2**s
        for k in range(int(N/m)):
            TW = pow(W,intReverse(k,int(log(N,2))-s)*int(m/2),q)
            for j in range(int(m/2)):
                u = B[k*m+j]
                t = (TW*B[k*m+j+int(m/2)]) % q

                B[k*m+j]          = (u+t) % q
                B[k*m+j+int(m/2)] = (u-t) % q

    return B

# Iterative Radix-2 Decimation-in-Time (DIT) (CT) NTT - RN
# A: input polynomial (bit-reversed order)
# W: twiddle factor
# q: modulus
# B: output polynomial (standard order)
def Radix2_DIT_Iterative_INTT_RN(A,W,q):
    N = len(A)
    B = [_ for _ in A]

    v = int(N/2)
    m = 1

    while m<N:
        np = 2*m
        lp = np*(v-1)
        for k in range(m):
            j = k
            jl = k + lp
            jt = k*v
            TW = pow(W,jt,q)
            while j < (jl+1):
                temp = (TW*B[j+m]) % q
                B[j+m] = (B[j] - temp) % q
                B[j]   = (B[j] + temp) % q
                j = j+np
        v = int(v/2)
        m = 2*m
        
    # 最后的步骤：乘以N的逆
    N_inv = modinv(N, q)
    for i in range(N):
        B[i] = (B[i] * N_inv) % q

    return B


# Iterative Radix-2 Decimation-in-Frequency (DIF) (GS) NTT - RN
# A: input polynomial (reversed order)
# W: twiddle factor
# q: modulus
# B: output polynomial (bit-standard order)
def Radix2_DIF_Iterative_INTT_RN(A,W,q):
    N = len(A)
    B = [_ for _ in A]

    m = 1
    v = N
    d = 1

    while v>1:
        for jf in range(m):
            j = jf
            jt = 0
            while j<(N-1):
                # bit-reversing jt
                TW = pow(W,intReverse(jt,int(log(N>>1,2))),q)

                temp = B[j]

                B[j]   = (temp + B[j+d]) % q
                B[j+d] = (temp - B[j+d])*TW % q

                jt = jt+1
                j = j + 2*m
        m = 2*m
        v = int(v/2)
        d = 2*d
        
    # 最后的步骤：乘以N的逆
    N_inv = modinv(N, q)
    for i in range(N):
        B[i] = (B[i] * N_inv) % q

    return B


# ==========================================================

# NTT-Based Modular Polynomial Multiplication with f(x)=x^n+1 (Negative Wrapped Convolution)
# -- with merged pre-processing and post-processing
# A,B: n-1 degree polynomials
# w, w_inv: twiddle factors
# q: coefficient modulus
# C: n-1 degree polynomial
# C(x)=A(x)*B(X) --> C=INTT_n(MergedNTT_n(A) . MergedNTT_n(B))
def NTTBasedModPolMul_NWC_merge(A,B,psi,psi_inv,q):
    A_ntt = CTBasedMergedNTT_NR(A,psi,q)
    B_ntt = CTBasedMergedNTT_NR(B,psi,q)
    
    C_ntt = [(x*y) % q for x,y in zip(A_ntt,B_ntt)]
    
    C = GSBasedMergedINTT_RN(C_ntt,psi_inv,q)
    # C = CTBasedMergedINTT_RN(C_ntt,psi_inv,q)
    return C

# Merged NTT with pre-processing (optimized) (iterative)
# This is not NTT, this is pre-processing + NTT
# (see: https://eprint.iacr.org/2016/504.pdf)
# A: input polynomial (standard order)
# Psi: 2n-th root of unity
# q: modulus
# B: output polynomial (bit-reversed order)
def CTBasedMergedNTT_NR(A,Psi,q):
    N = len(A)
    B = [_ for _ in A]
    l = int(log(N,2))
    t = N
    m = 1
    
    # 计算总迭代次数
    total_iterations = sum([N//(2**(i+1)) for i in range(int(log(N, 2)))])
    
    with tqdm(total=total_iterations, desc="CTBasedMergedNTT_NR Progress") as pbar:
        while(m < N):
            t = int(t/2)
            for i in range(m):
                j1 = 2*i*t
                j2 = j1 + t - 1
                Psi_pow = intReverse(m+i, l)
                S = pow(Psi, Psi_pow, q)
                for j in range(j1, j2+1):
                    U = B[j]
                    V = (B[j+t]*S) % q
                    B[j]   = (U+V) % q
                    B[j+t] = (U-V) % q
                pbar.update(1)  # 每完成一个i的迭代更新进度条
            m = 2*m
            
    return B

def CTBasedMergedINTT_RN(A,Psi,q):
    N = len(A)
    B = [_ for _ in A]
    l = int(log(N,2))
    
    v = int(N/2)
    m = 1
    
    # 计算总迭代次数
    total_iterations = sum([N//(2**(i+1)) for i in range(int(log(N, 2)))])
    
    with tqdm(total=total_iterations, desc="CTBasedMergedINTT_RN Progress") as pbar:
        while(m < N):
            np = 2*m
            lp = np*(v-1)
            for i in range(m):
                j = i
                jl = i + lp
                # Psi_pow = intReverse(m+i, l)
                Psi_pow = m+i
                S = pow(Psi, Psi_pow, q)
                while j < (jl+1):
                    U = B[j]
                    V = (B[j+m]*S) % q
                    B[j]   = (U+V) % q
                    B[j+m] = (U-V) % q
                    j = j+np
                pbar.update(1)  # 每完成一个i的迭代更新进度条
            v = int(v/2)
            m = 2*m
            
    # 最后的步骤：乘以N的逆
    N_inv = modinv(N, q)
    for i in tqdm(range(N), desc="Final Normalization"):
        B[i] = (B[i] * N_inv) % q
            
    return B


# Merged INTT with post-processing (optimized) (iterative)
# This is not NTT, this is pre-processing + NTT
# (see: https://eprint.iacr.org/2016/504.pdf)
# A: input polynomial (Bit-reversed order)
# Psi: 2n-th root of unity
# q: modulus
# B: output polynomial (standard order)
def GSBasedMergedINTT_RN(A,Psi,q):
    N = len(A)
    B = [_ for _ in A]
    l = int(log(N,2))
    t = 1
    m = N
    
    # 计算总迭代次数
    total_iterations = sum([N//(2**(i+1)) for i in range(int(log(N, 2)))])
    
    with tqdm(total=total_iterations, desc="GSBasedMergedINTT_RN Progress") as pbar:
        while(m > 1):
            j1 = 0
            h = int(m/2)
            for i in range(h):
                j2 = j1 + t - 1
                Psi_pow = intReverse(h+i, l)
                S = pow(Psi, Psi_pow, q)
                for j in range(j1, j2+1):
                    U = B[j]
                    V = B[j+t]
                    B[j]   = (U+V) % q
                    B[j+t] = (U-V)*S % q
                j1 = j1 + 2*t
                pbar.update(1)  # 每完成一个i的迭代更新进度条
            t = 2*t
            m = int(m/2)
    
    # 最后的步骤：乘以N的逆
    N_inv = modinv(N, q)
    for i in tqdm(range(N), desc="Final Normalization"):
        B[i] = (B[i] * N_inv) % q
        
    return B






if __name__ == "__main__":
    # Parameters (NWC)
    # n       = 65536
    # q       = 998244353
    # w       = 80928016
    # w_inv   = 163063506
    # psi     = 8996
    # psi_inv = 498345419
    
    # Parameters (NWC)
    n       = 4096
    q       = 998244353
    w       = 883940940
    w_inv   = 226510976
    psi     = 730033
    psi_inv = 312023405
    
    # File paths
    RESULTS_DIR = "poly_schoolbook_results"
    D0_FILE = os.path.join(RESULTS_DIR, "D0.txt")
    C0_FILE = os.path.join(RESULTS_DIR, "C0.txt")
    C1_FILE = os.path.join(RESULTS_DIR, "C1.txt")
    N_FILE  = os.path.join(RESULTS_DIR, "N.txt")
    N_BASELINE_FILE = os.path.join(RESULTS_DIR, "N_baseline.txt")
    
    # Random polynomial generation
    RANDOM_SEED = 2025
    random.seed(RANDOM_SEED)
    print(f"Using random seed: {RANDOM_SEED}")
    
    A = [random.randint(0,q-1) for _ in range(n)]
    B = [random.randint(0,q-1) for _ in range(n)]
    
    print("-------- Sanity check for polynomial multiplication operations --------")
    print("")
    
    # Import Schoolbook results
    D0 = load_result_from_file(D0_FILE)
    C0 = load_result_from_file(C0_FILE)
    C1 = load_result_from_file(C1_FILE)
    
    # Check NTT-based polynomial multiplication methods
    print("Computing N_merge = NTTBasedModPolMul_NWC_merge(A, B, psi, psi_inv, q)...")
    start_time = time.time()
    N_merge = NTTBasedModPolMul_NWC_merge(A,B,psi,psi_inv,q)
    nwc_time = time.time() - start_time
    print(f"N computation completed in {nwc_time:.2f} seconds.")
    # Save N to file for future use
    save_result_to_file(N_merge, N_FILE)
    
    # print("NTTBasedModPolMul_NWC_merge --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(N_merge,C1)]) == 0) else "Wrong"))
    print("")
    
    
    # Check NTT-based polynomial multiplication methods for baseline
    print("Computing N_baseline = NTTBasedModPolMul_NWC_baseline(A, B, w, w_inv, psi, psi_inv, q)...")
    start_time = time.time()
    N_baseline = NTTBasedModPolMul_NWC_baseline(A,B,w,w_inv,psi,psi_inv,q)
    baseline_time = time.time() - start_time
    print(f"N_baseline computation completed in {baseline_time:.2f} seconds.")
    # Save N_baseline to file for future use
    save_result_to_file(N_baseline, N_BASELINE_FILE)
    
    print("NTTBasedModPolMul_NWC_baseline --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(N_baseline,C1)]) == 0) else "Wrong"))
    print("")