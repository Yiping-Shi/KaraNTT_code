import os

# 基本参数
q = 998244353
phi_256 = 476477967
phi = 629671588
psi = 24514907

def pow_mod(base, exp, mod):
    """计算(base^exp) % mod的高效算法"""
    result = 1
    base = base % mod
    while exp > 0:
        if exp % 2 == 1:
            result = (result * base) % mod
        exp = exp >> 1
        base = (base * base) % mod
    return result

def generate_wrom_files():
    # 确保WROM目录存在
    os.makedirs("NTT_WROM_mem_files", exist_ok=True)
    
    # 生成WROM0 (原WROM1)
    print("Generating WROM0 files...")
    for bank in range(16):
        filename = f"NTT_WROM_mem_files/wrom0_bank{bank}.txt"
        with open(filename, "w") as f:
            for addr in range(4096):
                value = (pow_mod(psi, (bank*16+addr), q) * 
                         pow_mod(phi_256, (bank*(addr//256)), q)) % q
                f.write(f"{value:08x}\n")  # 30-bit值，但用十六进制表示不超过8个字符
        print(f"  - Generated {filename}")
    
    # 生成WROM1 (原WROM2)
    print("Generating WROM1 files...")
    for bank in range(16):
        filename = f"NTT_WROM_mem_files/wrom1_bank{bank}.txt"
        with open(filename, "w") as f:
            for addr in range(4096):
                value = pow_mod(phi, (bank+16*(addr//256))*(addr%256), q)
                f.write(f"{value:08x}\n")
        print(f"  - Generated {filename}")
    
    # 生成WROM2 (原WROM3)
    print("Generating WROM2 files...")
    for bank in range(16):
        filename = f"NTT_WROM_mem_files/wrom2_bank{bank}.txt"
        with open(filename, "w") as f:
            for addr in range(16):
                value = pow_mod(phi_256, (bank*addr), q)
                f.write(f"{value:08x}\n")
        print(f"  - Generated {filename}")
    
    print("All ROM initialization files generated successfully!")

if __name__ == "__main__":
    generate_wrom_files()