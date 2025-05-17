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
        # 每行写入一个元素
        for item in data:
            f.write(f"{item}\n")
    print(f"Result saved successfully to {filename}: {len(data)} items")

# 从文件加载结果的函数
def load_result_from_file(filename):
    if os.path.exists(filename):
        print(f"Loading result from {filename}...")
        data = []
        with open(filename, 'r') as f:
            for line in f:
                # 移除行尾的换行符，转换为整数，并添加到结果列表
                data.append(int(line.strip()))
        print(f"Loaded {len(data)} items from {filename}")
        return data
    else:
        print(f"File {filename} not found. Need to compute the result.")
        return None
    
    
# ====================================================================
# ====================================================================
def NTT_generate_twiddle_factors(Psi, q):
    # 生成第一个数组 - TW_iter0 (4x8)
    TW_iter0 = NTT_generate_TW_iter0(Psi, q)
    
    # 生成第二个数组 - TW_iter1 (16x4x8)
    TW_iter1 = NTT_generate_TW_iter1(Psi, q)
    
    # 生成第三个数组 - TW_iter2 (256x4x8)
    TW_iter2 = NTT_generate_TW_iter2(Psi, q)
    
    return {
        "TW_iter0": TW_iter0,
        "TW_iter1": TW_iter1,
        "TW_iter2": TW_iter2
    } 
    
def NTT_generate_TW_iter0(Psi, q):
    """生成TW_iter0 (4x8)数组"""
    TW_iter0 = [[0 for _ in range(8)] for _ in range(4)]

    for j in range(8):
        TW_iter0[0][j] = pow(Psi, intReverse(1, 12), q)

    for j in range(4):
        TW_iter0[1][j] = pow(Psi, intReverse(2, 12), q)
    for j in range(4, 8):
        TW_iter0[1][j] = pow(Psi, intReverse(3, 12), q)

    for j in range(2):
        TW_iter0[2][j] = pow(Psi, intReverse(4, 12), q)
    for j in range(2, 4):
        TW_iter0[2][j] = pow(Psi, intReverse(5, 12), q)
    for j in range(4, 6):
        TW_iter0[2][j] = pow(Psi, intReverse(6, 12), q)
    for j in range(6, 8):
        TW_iter0[2][j] = pow(Psi, intReverse(7, 12), q)
    
    for j in range(8):
        TW_iter0[3][j] = pow(Psi, intReverse(8 + j, 12), q)
    
    return TW_iter0

def NTT_generate_TW_iter1(Psi, q):
    """生成TW_iter1 (16x4x8)数组"""
    TW_iter1 = [[[0 for _ in range(8)] for _ in range(4)] for _ in range(16)]
    
    for i in range(16):
        for j in range(8):
            TW_iter1[i][0][j] = pow(Psi, intReverse(16 + i, 12), q)

        for j in range(4):
            TW_iter1[i][1][j] = pow(Psi, intReverse(32 + (i * 2), 12), q)
        for j in range(4, 8):
            TW_iter1[i][1][j] = pow(Psi, intReverse(33 + (i * 2), 12), q)

        for j in range(2):
            TW_iter1[i][2][j] = pow(Psi, intReverse(64 + (i * 4), 12), q)
        for j in range(2, 4):
            TW_iter1[i][2][j] = pow(Psi, intReverse(65 + (i * 4), 12), q)
        for j in range(4, 6):
            TW_iter1[i][2][j] = pow(Psi, intReverse(66 + (i * 4), 12), q)
        for j in range(6, 8):
            TW_iter1[i][2][j] = pow(Psi, intReverse(67 + (i * 4), 12), q)

        for j in range(8):
            TW_iter1[i][3][j] = pow(Psi, intReverse(128 + (i * 8) + j, 12), q)
    
    return TW_iter1

def NTT_generate_TW_iter2(Psi, q):
    """生成TW_iter2 (256x4x8)数组"""
    TW_iter2 = [[[0 for _ in range(8)] for _ in range(4)] for _ in range(256)]

    for i in range(256):
        for j in range(8):
            TW_iter2[i][0][j] = pow(Psi, intReverse(256 + i, 12), q)

        for j in range(4):
            TW_iter2[i][1][j] = pow(Psi, intReverse(512 + (i * 2), 12), q)
        for j in range(4, 8):
            TW_iter2[i][1][j] = pow(Psi, intReverse(513 + (i * 2), 12), q)

        for j in range(2):
            TW_iter2[i][2][j] = pow(Psi, intReverse(1024 + (i * 4), 12), q)
        for j in range(2, 4):
            TW_iter2[i][2][j] = pow(Psi, intReverse(1025 + (i * 4), 12), q)
        for j in range(4, 6):
            TW_iter2[i][2][j] = pow(Psi, intReverse(1026 + (i * 4), 12), q)
        for j in range(6, 8):
            TW_iter2[i][2][j] = pow(Psi, intReverse(1027 + (i * 4), 12), q)

        for j in range(8):
            TW_iter2[i][3][j] = pow(Psi, intReverse(2048 + (i * 8) + j, 12), q)
    
    return TW_iter2
    
# ===================================================================
# 16-Point NTT -> The basic Processing unit
# A: input 16-point
# TW: 4x8 array of pow(psi, psi_pow, q)
# q: modulus
# B: output 16-point
def CTBasedMergedNTT_NR_16(A,TW,q):
    N = len(A)
    B = [_ for _ in A]
    if N != 16:
        raise ValueError("Input length must be 16.")
    
    # Stage 0: {0,8} {1,9} {2,10} {3,11} {4,12} {5,13} {6,14} {7,15}
    for i in range(8):
        U = B[i]
        V = (B[i+8]*TW[0][i] % q)
        B[i]   = (U + V) % q
        B[i+8] = (U - V) % q
        
    # Stage 1: {0,4} {1,5} {2,6} {3,7} {8,12} {9,13} {10,14} {11,15}
    for i in range(4):
        for j in range(2):
            U = B[i+j*8]
            V = (B[i+j*8+4]*TW[1][i+j*4] % q)
            B[i+j*8]   = (U + V) % q
            B[i+j*8+4] = (U - V) % q

    # Stage 2: {0,2} {1,3} {4,6} {5,7} {8,10} {9,11} {12,14} {13,15}
    for i in range(2):
        for j in range(4):
            U = B[i+j*4]
            V = (B[i+j*4+2]*TW[2][i+j*2] % q)
            B[i+j*4]   = (U + V) % q
            B[i+j*4+2] = (U - V) % q
            
    # Stage 3: {0,1} {2,3} {4,5} {6,7} {8,9} {10,11} {12,13} {14,15}
    for j in range(8):
        U = B[j*2]
        V = (B[j*2+1]*TW[3][j] % q)
        B[j*2]   = (U + V) % q
        B[j*2+1] = (U - V) % q
        
    return B

# ===================================================================
# 3D Merged NTT with pre-processing (HW)
# A: input polynomial (standard order)
# Psi: 2n-th root of unity
# q: modulus
# B: output polynomial (bit-reversed order)
def NTT_3D_HW(A,Psi,q):
    N = len(A)
    B = [_ for _ in A]
    l = int(log(N,2))
    if N != 4096:
        raise ValueError("Input length must be 4096.")
    
    # Generate twiddle factors
    NTT_twiddle_factors = NTT_generate_twiddle_factors(Psi, q)
    NTT_TW_iter0 = NTT_twiddle_factors["TW_iter0"]
    NTT_TW_iter1 = NTT_twiddle_factors["TW_iter1"]
    NTT_TW_iter2 = NTT_twiddle_factors["TW_iter2"]
    
    # Iteration 0: Stage 0-3
    for i in range(256):
        ntt_16_input = [B[i + j*256] for j in range(16)]
        
        ntt_16_output = CTBasedMergedNTT_NR_16(ntt_16_input, NTT_TW_iter0, q)
        
        for j in range(16):
            B[i + j*256] = ntt_16_output[j]
    
    # Iteration 1: Stage 4-7
    for i in range(256):
        start_idx = i % 16
        block_idx = i // 16
        
        ntt_16_input = [B[start_idx + j*16 + block_idx*256] for j in range(16)]
        
        current_TW = NTT_TW_iter1[i//16]
        ntt_16_output = CTBasedMergedNTT_NR_16(ntt_16_input, current_TW, q)
        
        for j in range(16):
            B[start_idx + j*16 + block_idx*256] = ntt_16_output[j]
            
    # Iteration 2: Stage 8-11
    for i in range(256):
        ntt_16_input = B[i*16:(i+1)*16]

        current_TW = NTT_TW_iter2[i]
        ntt_16_output = CTBasedMergedNTT_NR_16(ntt_16_input, current_TW, q)
        
        for j in range(16):
            B[i*16 + j] = ntt_16_output[j]
            
    return B
# ===================================================================


# ===================================================================
# ===================================================================
def INTT_generate_twiddle_factors(Psi, q):
    # 生成第一个数组 - TW_iter0 (256x4x8)
    TW_iter0 = INTT_generate_TW_iter0(Psi, q)
    
    # 生成第二个数组 - TW_iter1 (16x4x8)
    TW_iter1 = INTT_generate_TW_iter1(Psi, q)
    
    # 生成第三个数组 - TW_iter2 (4x8)
    TW_iter2 = INTT_generate_TW_iter2(Psi, q)
    
    return {
        "TW_iter0": TW_iter0,
        "TW_iter1": TW_iter1,
        "TW_iter2": TW_iter2
    } 

def INTT_generate_TW_iter0(Psi, q):
    """生成TW_iter0 (256x4x8)数组"""
    TW_iter0 = [[[0 for _ in range(8)] for _ in range(4)] for _ in range(256)]
    
    for i in range(256):
        for j in range(8):
            TW_iter0[i][0][j] = pow(Psi, intReverse(2048 + (i * 8) + j, 12), q)
            
        for j in range(2):
            TW_iter0[i][1][j] = pow(Psi, intReverse(1024 + (i * 4), 12), q)
        for j in range(2, 4):
            TW_iter0[i][1][j] = pow(Psi, intReverse(1025 + (i * 4), 12), q)
        for j in range(4, 6):
            TW_iter0[i][1][j] = pow(Psi, intReverse(1026 + (i * 4), 12), q)
        for j in range(6, 8):
            TW_iter0[i][1][j] = pow(Psi, intReverse(1027 + (i * 4), 12), q)
            
        for j in range(4):
            TW_iter0[i][2][j] = pow(Psi, intReverse(512 + (i * 2), 12), q)
        for j in range(4, 8):
            TW_iter0[i][2][j] = pow(Psi, intReverse(513 + (i * 2), 12), q)
            
        for j in range(8):
            TW_iter0[i][3][j] = pow(Psi, intReverse(256 + i, 12), q)
            
    return TW_iter0

def INTT_generate_TW_iter1(Psi, q):
    """生成TW_iter1 (16x4x8)数组"""
    TW_iter1 = [[[0 for _ in range(8)] for _ in range(4)] for _ in range(16)]
    
    for i in range(16):            
        for j in range(8):
            TW_iter1[i][0][j] = pow(Psi, intReverse(128 + (i * 8) + j, 12), q)

        for j in range(2):
            TW_iter1[i][1][j] = pow(Psi, intReverse(64 + (i * 4), 12), q)
        for j in range(2, 4):
            TW_iter1[i][1][j] = pow(Psi, intReverse(65 + (i * 4), 12), q)
        for j in range(4, 6):
            TW_iter1[i][1][j] = pow(Psi, intReverse(66 + (i * 4), 12), q)
        for j in range(6, 8):
            TW_iter1[i][1][j] = pow(Psi, intReverse(67 + (i * 4), 12), q)
        
        for j in range(4):
            TW_iter1[i][2][j] = pow(Psi, intReverse(32 + (i * 2), 12), q)
        for j in range(4, 8):
            TW_iter1[i][2][j] = pow(Psi, intReverse(33 + (i * 2), 12), q)
            
        for j in range(8):
            TW_iter1[i][3][j] = pow(Psi, intReverse(16 + i, 12), q)
    
    return TW_iter1

def INTT_generate_TW_iter2(Psi, q):
    """生成TW_iter2 (4x8)数组"""
    TW_iter2 = [[0 for _ in range(8)] for _ in range(4)]
    
    for j in range(8):
        TW_iter2[0][j] = pow(Psi, intReverse(8 + j, 12), q)
        
    for j in range(2):
        TW_iter2[1][j] = pow(Psi, intReverse(4, 12), q)
    for j in range(2, 4):
        TW_iter2[1][j] = pow(Psi, intReverse(5, 12), q)
    for j in range(4, 6):
        TW_iter2[1][j] = pow(Psi, intReverse(6, 12), q)
    for j in range(6, 8):
        TW_iter2[1][j] = pow(Psi, intReverse(7, 12), q)

    for j in range(4):
        TW_iter2[2][j] = pow(Psi, intReverse(2, 12), q)
    for j in range(4, 8):
        TW_iter2[2][j] = pow(Psi, intReverse(3, 12), q)
        
    for j in range(8):
        TW_iter2[3][j] = pow(Psi, intReverse(1, 12), q)
     
    return TW_iter2

# +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
def DIV_2(A, q):
    if A % 2 == 0:
        return A >> 1
    else:
        return ((A>>1) + ((q+1)>>1))

# ===================================================================
# 16-Point INTT -> The basic Processing unit
# A: input 16-point
# TW: 4x8 array of pow(psi, psi_pow, q)
# q: modulus
# B: output 16-point
def GSBasedMergedINTT_RN_16(A,TW,q):
    N = len(A)
    B = [_ for _ in A]
    if N != 16:
        raise ValueError("Input length must be 16.")
    
    # Stage 0: {0,1} {2,3} {4,5} {6,7} {8,9} {10,11} {12,13} {14,15}
    for j in range(8):
        U = B[j*2]
        V = B[j*2+1]
        B[j*2]   = (U + V) % q
        B[j*2+1] = (U - V)*TW[0][j] % q
    for k in range(16):
        B[k] = DIV_2(B[k], q)
        
    # Stage 1: {0,2} {1,3} {4,6} {5,7} {8,10} {9,11} {12,14} {13,15}
    for i in range(2):
        for j in range(4):
            U = B[i+j*4]
            V = B[i+j*4+2]
            B[i+j*4]   = (U + V) % q
            B[i+j*4+2] = (U - V)*TW[1][i+j*2] % q
    for k in range(16):
        B[k] = DIV_2(B[k], q)
            
    # Stage 2: {0,4} {1,5} {2,6} {3,7} {8,12} {9,13} {10,14} {11,15}
    for i in range(4):
        for j in range(2):
            U = B[i+j*8]
            V = B[i+j*8+4]
            B[i+j*8]   = (U + V) % q
            B[i+j*8+4] = (U - V)*TW[2][i+j*4] % q
    for k in range(16):
        B[k] = DIV_2(B[k], q)
    
    # Stage 3: {0,8} {1,9} {2,10} {3,11} {4,12} {5,13} {6,14} {7,15}
    for i in range(8):
        U = B[i]
        V = B[i+8]
        B[i]   = (U + V) % q
        B[i+8] = (U - V)*TW[3][i] % q
    for k in range(16):
        B[k] = DIV_2(B[k], q)
            
    return B

# ===================================================================
# 3D Merged INTT with post-processing (HW)
# A: input polynomial (bit-reversed order)
# Psi_inv: 2n-th root of unity
# q: modulus
# B: output polynomial (standard order)
def INTT_3D_HW(A,Psi,q):
    N = len(A)
    B = [_ for _ in A]
    l = int(log(N,2))
    if N != 4096:
        raise ValueError("Input length must be 4096.")
    
    # Generate twiddle factors
    INTT_twiddle_factors = INTT_generate_twiddle_factors(Psi, q)
    INTT_TW_iter0 = INTT_twiddle_factors["TW_iter0"]
    INTT_TW_iter1 = INTT_twiddle_factors["TW_iter1"]
    INTT_TW_iter2 = INTT_twiddle_factors["TW_iter2"]
    
    # Iteration 0: Stage 0-3
    for i in range(256):
        intt_16_input = B[i*16:(i+1)*16]

        current_TW = INTT_TW_iter0[i]
        intt_16_output = GSBasedMergedINTT_RN_16(intt_16_input, current_TW, q)
        
        for j in range(16):
            B[i*16 + j] = intt_16_output[j]
            
    # Iteration 1: Stage 4-7
    for i in range(256):
        start_idx = i % 16
        block_idx = i // 16
        
        intt_16_input = [B[start_idx + j*16 + block_idx*256] for j in range(16)]
        
        current_TW = INTT_TW_iter1[i//16]
        intt_16_output = GSBasedMergedINTT_RN_16(intt_16_input, current_TW, q)
        
        for j in range(16):
            B[start_idx + j*16 + block_idx*256] = intt_16_output[j]
            
    # Iteration 2: Stage 8-11
    for i in range(256):
        intt_16_input = [B[i + j*256] for j in range(16)]
        
        intt_16_output = GSBasedMergedINTT_RN_16(intt_16_input, INTT_TW_iter2, q)
        
        for j in range(16):
            B[i + j*256] = intt_16_output[j]
    
    return B
# ===================================================================


# ===================================================================
def NTTBasedModPolMul_NWC_merge_3D_HW(A,B,psi,psi_inv,q):
    A_ntt = NTT_3D_HW(A,psi,q)
    B_ntt = NTT_3D_HW(B,psi,q)
    
    C_ntt = [(x*y) % q for x,y in zip(A_ntt,B_ntt)]
    
    C = INTT_3D_HW(C_ntt,psi_inv,q)
    return C



# ====================================================================
if __name__ == "__main__":
    # Parameters (NWC)
    n       = 4096
    q       = 998244353
    w       = 883940940
    w_inv   = 226510976
    psi     = 730033
    psi_inv = 312023405
    
    
    # Load NTT_baseline results
    N_BASELINE = load_result_from_file("./Results/N.txt")
    
    # Random polynomial generation
    RANDOM_SEED = 2025
    random.seed(RANDOM_SEED)
    print(f"Using random seed: {RANDOM_SEED}")
    print("")
    
    A = [random.randint(0,q-1) for _ in range(n)]
    B = [random.randint(0,q-1) for _ in range(n)]
    
    print("-------- Sanity check for polynomial multiplication operations --------")
    print("")
    
    # Check NTT-based polynomial multiplication methods
    print("Computing N_HW = NTTBasedModPolMul_NWC_merge_3D_HW(A, B, psi, psi_inv, q)...")
    start_time = time.time()
    N_HW = NTTBasedModPolMul_NWC_merge_3D_HW(A,B,psi,psi_inv,q)
    nwc_time = time.time() - start_time
    print(f"N_HW computation completed in {nwc_time:.2f} seconds.")
    print("")
    
    print("NTTBasedModPolMul_NWC_merge_3D_HW --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(N_HW,N_BASELINE)]) == 0) else "Wrong"))
    print("")
    
    print(f"N_HW[1803:1803+16]: {N_HW[1803:1803+16]}")