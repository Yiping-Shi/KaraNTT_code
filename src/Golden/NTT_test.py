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

# # 保存结果到文件的函数
# def save_result_to_file(data, filename):
#     # 确保目录存在
#     os.makedirs(os.path.dirname(filename), exist_ok=True)
    
#     print(f"Saving result to {filename}...")
#     with open(filename, 'w') as f:
#         json.dump(data, f)
#     print(f"Result saved successfully to {filename}")

# # 从文件加载结果的函数
# def load_result_from_file(filename):
#     if os.path.exists(filename):
#         print(f"Loading result from {filename}...")
#         with open(filename, 'r') as f:
#             return json.loads(f.read())
#     else:
#         print(f"File {filename} not found. Need to compute the result.")
#         return None

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





# ===================================================================
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
            filename = f"./NTT_results/Stage{int(log(m, 2))}.txt"
            save_result_to_file(B, filename)
            m = 2*m
            
    return B


if __name__ == "__main__":
    # Parameters (NWC)
    n       = 4096
    q       = 998244353
    w       = 883940940
    w_inv   = 226510976
    psi     = 730033
    psi_inv = 312023405
    
    # Random polynomial generation
    RANDOM_SEED = 2025
    random.seed(RANDOM_SEED)
    print(f"Using random seed: {RANDOM_SEED}")
    
    A = [random.randint(0,q-1) for _ in range(n)]
    
    # Baseline
    print("Computing NTT using the baseline method...")
    start_time = time.time()
    A_ntt = CTBasedMergedNTT_NR(A,psi,q)
    ntt_baseline_time = time.time() - start_time
    print(f"NTT_baseline time: {ntt_baseline_time:.2f} seconds")
    print("")
    
    save_result_to_file(A_ntt, "./NTT_results/NTT_baseline.txt")
    