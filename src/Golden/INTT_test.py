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
            filename = f"./INTT_results/Stage{11-int(log(m, 2))}.txt"
            save_result_to_file(B, filename)
    
    # 最后的步骤：乘以N的逆
    N_inv = modinv(N, q)
    for i in tqdm(range(N), desc="Final Normalization"):
        B[i] = (B[i] * N_inv) % q
        
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
    print("Computing INTT using the baseline method...")
    start_time = time.time()
    A_intt = GSBasedMergedINTT_RN(A,psi_inv,q)
    intt_baseline_time = time.time() - start_time
    print(f"INTT_baseline time: {intt_baseline_time:.2f} seconds")
    print("")
    
    save_result_to_file(A_intt, "./INTT_results/INTT_baseline.txt")