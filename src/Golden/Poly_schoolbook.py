import random
import time
from tqdm import tqdm
import os
import json

# A,B: same degree polynomials
# q: coefficient modulus
# C: output polynomial
def SchoolbookPolMul(A, B, q):
    C = [0] * (2 * len(A))
    # 添加进度条
    for indexA, elemA in tqdm(enumerate(A), total=len(A), desc="Schoolbook multiplication"):
        for indexB, elemB in enumerate(B):
            C[indexA + indexB] = (C[indexA + indexB] + elemA * elemB) % q
    return C

# A: input polynomial
# F: reduction polynomial
# q: coefficient modulus
# D: output polynomial
# Assuming coefficient of largest degree of F is 1
def PolRed(A,F,q):
    if len(A) < len(F):
        return A
    else:
        D = [_ for _ in A]
        R = [(-x) % q for x in F[0:len(F)-1]]
        # 添加进度条
        for i in tqdm(range(len(D)-1, len(F)-2, -1), desc="Polynomial reduction"):
            for j in range(len(R)):
                D[i-1-j] = (D[i-1-j] + D[i]*R[len(R)-1-j]) % q
            D[i] = 0
        return D[0:len(F)-1]
    
# A,B: input polynomials in x^n-1
# q: coefficient modulus
# D: output polynomial in x^n-1
def SchoolbookModPolMul_PWC(A, B, q):
    C = [0] * (2 * len(A))
    D = [0] * (len(A))
    # 添加进度条
    for indexA, elemA in tqdm(enumerate(A), total=len(A), desc="PWC multiplication"):
        for indexB, elemB in enumerate(B):
            C[indexA + indexB] = (C[indexA + indexB] + elemA * elemB) % q

    for i in range(len(A)):
        D[i] = (C[i] + C[i + len(A)]) % q
    return D

# A,B: input polynomials in x^n+1
# q: coefficient modulus
# D: output polynomial in x^n+1
def SchoolbookModPolMul_NWC(A, B, q):
    C = [0] * (2 * len(A))
    D = [0] * (len(A))
    # 添加进度条
    for indexA, elemA in tqdm(enumerate(A), total=len(A), desc="NWC multiplication"):
        for indexB, elemB in enumerate(B):
            C[indexA + indexB] = (C[indexA + indexB] + elemA * elemB) % q

    for i in range(len(A)):
        D[i] = (C[i] - C[i + len(A)]) % q
    return D

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


if __name__ == "__main__":
    # Parameters (NWC)
    n       = 4096
    q       = 998244353
    w       = 883940940
    w_inv   = 226510976
    psi     = 730033
    psi_inv = 312023405
    
    # File paths
    RESULTS_DIR = "Results"
    D0_FILE = os.path.join(RESULTS_DIR, "D0.txt")
    C0_FILE = os.path.join(RESULTS_DIR, "C0.txt")
    C1_FILE = os.path.join(RESULTS_DIR, "C1.txt")
    
    # Random polynomial generation
    RANDOM_SEED = 2025
    random.seed(RANDOM_SEED)
    print(f"Using random seed: {RANDOM_SEED}")
    
    A = [random.randint(0,q-1) for _ in range(n)]
    B = [random.randint(0,q-1) for _ in range(n)]
    
    # reduce functions
    pwc  = [-1]+[0]*(n-1)+[1]
    nwc  =  [1]+[0]*(n-1)+[1]
    
    print("-------- Sanity check for polynomial multiplication operations --------")
    print("")
    
    # Check reference implementations with timing
    D0 = load_result_from_file(D0_FILE)
    if D0 is None:
        print("Computing D0 = SchoolbookPolMul(A, B, q)...")
        start_time = time.time()
        D0 = SchoolbookPolMul(A, B, q)
        d0_time = time.time() - start_time
        print(f"D0 computation completed in {d0_time:.2f} seconds.")
        
        # Save D0 to file for future use
        save_result_to_file(D0, D0_FILE)
    else:
        d0_time = 0  # Loaded from file 
        
    print("\nComputing DR0 = PolRed(D0, pwc, q)...")
    start_time = time.time()
    DR0 = PolRed(D0, pwc, q)
    dr0_time = time.time() - start_time
    print(f"DR0 computation completed in {dr0_time:.2f} seconds.")
    
    print("\nComputing DR1 = PolRed(D0, nwc, q)...")
    start_time = time.time()
    DR1 = PolRed(D0, nwc, q)
    dr1_time = time.time() - start_time
    print(f"DR1 computation completed in {dr1_time:.2f} seconds.")
        
    
    # Try to load C0 from file, if not available, compute it
    C0 = load_result_from_file(C0_FILE)
    if C0 is None:
        print("\nComputing C0 = SchoolbookModPolMul_PWC(A, B, q)...")
        start_time = time.time()
        C0 = SchoolbookModPolMul_PWC(A, B, q)
        c0_time = time.time() - start_time
        print(f"C0 computation completed in {c0_time:.2f} seconds.")
        
        # Save C0 to file for future use
        save_result_to_file(C0, C0_FILE)
    else:
        c0_time = 0  # Loaded from file
    
    # Try to load C1 from file, if not available, compute it
    C1 = load_result_from_file(C1_FILE)
    if C1 is None:
        print("\nComputing C1 = SchoolbookModPolMul_NWC(A, B, q)...")
        start_time = time.time()
        C1 = SchoolbookModPolMul_NWC(A, B, q)
        c1_time = time.time() - start_time
        print(f"C1 computation completed in {c1_time:.2f} seconds.")
        
        # Save C1 to file for future use
        save_result_to_file(C1, C1_FILE)
    else:
        c1_time = 0  # Loaded from file
        
    
    
    print("\nVerifying results:")
    print("SchoolbookModPolMul_PWC  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(DR0,C0)]) == 0) else "Wrong"))
    print("SchoolbookModPolMul_NWC  --> " + ("Correct" if(sum([abs(x-y) for x,y in zip(DR1,C1)]) == 0) else "Wrong"))
    print("")