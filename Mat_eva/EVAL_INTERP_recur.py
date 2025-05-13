import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.sparse import coo_matrix

def build_transform_matrices():
    """构建转换矩阵（Python版本）"""
    # 构建EVAL矩阵
    EVAL_1 = np.array([[1, 0], [1, 1], [0, 1]])
    EVAL_2 = np.kron(EVAL_1, EVAL_1)
    EVAL_4 = np.kron(EVAL_2, EVAL_2)
    EVAL = EVAL_4
    
    # 构建INTERP矩阵
    # 第一级
    INTERP_1 = np.array([[1, 0, 0], 
                        [-1, 1, -1], 
                        [0, 0, 1]])
    
    # 第二级
    INTERP_2_temp = np.kron(INTERP_1, INTERP_1)
    INTERP_2 = np.zeros((7, 9))
    INTERP_2[0:2, :] = INTERP_2_temp[0:2, :]
    INTERP_2[2, :] = INTERP_2_temp[2, :] + INTERP_2_temp[3, :]
    INTERP_2[3, :] = INTERP_2_temp[4, :]
    INTERP_2[4, :] = INTERP_2_temp[5, :] + INTERP_2_temp[6, :]
    INTERP_2[5:7, :] = INTERP_2_temp[7:9, :]
    
    # 第三级
    INTERP_3_temp = np.kron(INTERP_2, INTERP_1)
    INTERP_3 = np.zeros((15, 27))
    INTERP_3[0:2, :] = INTERP_3_temp[0:2, :]                # MATLAB(1:2,:)
    INTERP_3[2, :] = INTERP_3_temp[2, :] + INTERP_3_temp[3, :]  # MATLAB(3+4)
    INTERP_3[3, :] = INTERP_3_temp[4, :]                     # MATLAB(5)
    INTERP_3[4, :] = INTERP_3_temp[5, :] + INTERP_3_temp[6, :]  # MATLAB(6+7)
    INTERP_3[5, :] = INTERP_3_temp[7, :]                     # MATLAB(8)
    INTERP_3[6, :] = INTERP_3_temp[8, :] + INTERP_3_temp[9, :]  # MATLAB(9+10)
    INTERP_3[7, :] = INTERP_3_temp[10, :]                    # MATLAB(11)
    INTERP_3[8, :] = INTERP_3_temp[11, :] + INTERP_3_temp[12, :]  # MATLAB(12+13)
    INTERP_3[9, :] = INTERP_3_temp[13, :]                    # MATLAB(14)
    INTERP_3[10, :] = INTERP_3_temp[14, :] + INTERP_3_temp[15, :]  # MATLAB(15+16)
    INTERP_3[11, :] = INTERP_3_temp[16, :]                    # MATLAB(17)
    INTERP_3[12, :] = INTERP_3_temp[17, :] + INTERP_3_temp[18, :]  # MATLAB(18+19)
    INTERP_3[13:15, :] = INTERP_3_temp[19:21, :]              # MATLAB(20:21)
    
    # 第四级（简化为直接使用原始逻辑）
    INTERP_4_temp = np.kron(INTERP_3, INTERP_1)
    INTERP_4 = np.zeros((31, 81))
    INTERP_4[0:2, :] = INTERP_4_temp[0:2, :]                # MATLAB(1:2,:)
    INTERP_4[2, :] = INTERP_4_temp[2, :] + INTERP_4_temp[3, :]  # MATLAB(3+4)
    INTERP_4[3, :] = INTERP_4_temp[4, :]                     # MATLAB(5)
    INTERP_4[4, :] = INTERP_4_temp[5, :] + INTERP_4_temp[6, :]  # MATLAB(6+7)
    INTERP_4[5, :] = INTERP_4_temp[7, :]                     # MATLAB(8)
    INTERP_4[6, :] = INTERP_4_temp[8, :] + INTERP_4_temp[9, :]  # MATLAB(9+10)
    INTERP_4[7, :] = INTERP_4_temp[10, :]                    # MATLAB(11)
    INTERP_4[8, :] = INTERP_4_temp[11, :] + INTERP_4_temp[12, :]  # MATLAB(12+13)
    INTERP_4[9, :] = INTERP_4_temp[13, :]                    # MATLAB(14)
    INTERP_4[10, :] = INTERP_4_temp[14, :] + INTERP_4_temp[15, :]  # MATLAB(15+16)
    INTERP_4[11, :] = INTERP_4_temp[16, :]                    # MATLAB(17)
    INTERP_4[12, :] = INTERP_4_temp[17, :] + INTERP_4_temp[18, :]  # MATLAB(18+19)
    INTERP_4[13, :] = INTERP_4_temp[19, :]                    # MATLAB(20)
    INTERP_4[14, :] = INTERP_4_temp[20, :] + INTERP_4_temp[21, :]  # MATLAB(21+22)
    INTERP_4[15, :] = INTERP_4_temp[22, :]                    # MATLAB(23)
    INTERP_4[16, :] = INTERP_4_temp[23, :] + INTERP_4_temp[24, :]  # MATLAB(24+25)
    INTERP_4[17, :] = INTERP_4_temp[25, :]                    # MATLAB(26)
    INTERP_4[18, :] = INTERP_4_temp[26, :] + INTERP_4_temp[27, :]  # MATLAB(27+28)
    INTERP_4[19, :] = INTERP_4_temp[28, :]                    # MATLAB(29)
    INTERP_4[20, :] = INTERP_4_temp[29, :] + INTERP_4_temp[30, :]  # MATLAB(30+31)
    INTERP_4[21, :] = INTERP_4_temp[31, :]                    # MATLAB(32)
    INTERP_4[22, :] = INTERP_4_temp[32, :] + INTERP_4_temp[33, :]  # MATLAB(33+34)
    INTERP_4[23, :] = INTERP_4_temp[34, :]                    # MATLAB(35)
    INTERP_4[24, :] = INTERP_4_temp[35, :] + INTERP_4_temp[36, :]  # MATLAB(36+37)
    INTERP_4[25, :] = INTERP_4_temp[37, :]                    # MATLAB(38)
    INTERP_4[26, :] = INTERP_4_temp[38, :] + INTERP_4_temp[39, :]  # MATLAB(39+40)
    INTERP_4[27, :] = INTERP_4_temp[40, :]                    # MATLAB(41)
    INTERP_4[28, :] = INTERP_4_temp[41, :] + INTERP_4_temp[42, :]  # MATLAB(42+43)
    INTERP_4[29:31, :] = INTERP_4_temp[43:45, :]              # MATLAB(44:45)
    
    INTERP = INTERP_4
    
    # 构建POSTprocess矩阵
    NORM = np.eye(16, 31)
    NORM[:15, 16:31] -= np.eye(15)
    POSTprocess = NORM @ INTERP
    
    return EVAL, INTERP, POSTprocess

def build_eval_matrix(k):
    # 构建EVAL矩阵
    EVAL_1 = np.array([[1, 0], [1, 1], [0, 1]])
    
    if k == 1:
        EVAL = EVAL_1
    else:
        EVAL_prev = build_eval_matrix(k-1)
        EVAL = np.kron(EVAL_prev, EVAL_1)
    
    return EVAL

def build_interp_matrix(k):
    # 构建INTERP矩阵
    INTERP_1 = np.array([[1, 0, 0], 
                        [-1, 1, -1], 
                        [0, 0, 1]])
    
    if k == 1:
        INTERP = INTERP_1
    else:
        INTERP_prev = build_interp_matrix(k-1)
        INTERP_temp = np.kron(INTERP_prev, INTERP_1)
        # Caluculate dimensions
        input_rows  = 2**k-1
        input_cols  = 3**(k-1)
        output_rows = 2**(k+1)-1
        output_cols = 3**k
        # Initialize INTERP matrix
        INTERP = np.zeros((output_rows, output_cols))
        # Reshape
        for i in range(input_rows):
            INTERP[i*2, :]   += INTERP_temp[i*3, :]
            INTERP[i*2+1, :] += INTERP_temp[i*3+1, :]
            INTERP[i*2+2, :] += INTERP_temp[i*3+2, :]
    
    return INTERP


def plot_sparsity(matrices, titles):
    """优化版稀疏矩阵可视化，含底部标注"""
    sns.set_style("whitegrid")
    plt.rcParams.update({
        'font.size': 12,
        'axes.labelsize': 12,
        'xtick.labelsize': 10,
        'ytick.labelsize': 10
    })
    
    fig, axes = plt.subplots(2, 2, figsize=(20, 16))  # 增加总高度
    axes = axes.ravel()
    
    # 调整布局参数（关键）
    plt.subplots_adjust(
        wspace=0.2, 
        hspace=0.26,  # 增加行间距
        bottom=0.2   # 增加底部空间
    )
    
    # 预定义标注内容
    captions = [
        "(a) Evaluation Matrix / Preprocessing Matrix",
        "(b) Interpolation Matrix",
        "(c) Normalization Matrix",
        "(d) Postprocessing Matrix"
    ]
    
    color_dict = {1: '#0072B2', -1: '#D55E00'}
    
    for idx, (ax, mat, title) in enumerate(zip(axes, matrices, titles)):
        sparse_mat = coo_matrix(mat)
        unique_vals = np.unique(mat)
        
        # 生成颜色序列
        colors = [
            color_dict[val] if val in color_dict else '#1f77b4' 
            for val in mat[sparse_mat.row, sparse_mat.col]
        ]
        
        # 绘制散点
        sc = ax.scatter(sparse_mat.col, sparse_mat.row,
                       s=25, c=colors, alpha=0.8, linewidth=0.5)
        
        # 添加底部标注（关键修改）
        ax.text(0.5, -0.14,  # x=50%位置，y轴下方延伸
               captions[idx],
               transform=ax.transAxes,  # 使用轴坐标系
               ha='center', va='top',   # 水平居中，垂直顶部对齐
               fontsize=13,
               fontweight='semibold',
               color='#2F2F2F')
        
        # 动态生成图例
        legend_elements = [
            plt.Line2D([0], [0], marker='o', color='w',
                      markerfacecolor=color_dict[val], markersize=8,
                      label=str(val))
            for val in [1, -1] if val in unique_vals
        ]
        
        if legend_elements:
            ax.legend(handles=legend_elements,
                    loc='lower right',
                    bbox_to_anchor=(1, -0.13),
                    ncol=2,
                    framealpha=0.9,
                    fontsize=8)
        
        # 坐标设置（移除标题）
        ax.set_xlabel('Column Index', labelpad=8)
        ax.set_ylabel('Row Index', labelpad=8)
        ax.invert_yaxis()
        ax.grid(True, linestyle=':', alpha=0.3)

    # 统一保存设置
    plt.savefig('sparse_matrix.png', 
               dpi=800, 
               bbox_inches='tight',  # 自动计算边界
               pad_inches=0.2)      # 额外边距

def analyze_matrices(EVAL, INTERP, NORM, POSTprocess):
    """矩阵分析函数"""
    print("Analysis of evaluation matrix (EVAL):")
    print(f"Size: {EVAL.shape}")
    print(f"Non-zero elements: {np.count_nonzero(EVAL)} ({100*np.count_nonzero(EVAL)/EVAL.size:.2f}%)")
    print(f"Unique values: {np.unique(EVAL)}\n")
    
    print("Analysis of interpolation matrix (INTERP):")
    print(f"Size: {INTERP.shape}")
    print(f"Non-zero elements: {np.count_nonzero(INTERP)} ({100*np.count_nonzero(INTERP)/INTERP.size:.2f}%)")
    print(f"Unique values: {np.unique(INTERP)}\n")

    print("Analysis of normalization matrix (NORM):")
    print(f"Size: {NORM.shape}")
    print(f"Non-zero elements: {np.count_nonzero(NORM)} ({100*np.count_nonzero(NORM)/NORM.size:.2f}%)")
    print(f"Unique values: {np.unique(NORM)}\n")
    
    print("Analysis of post-processing matrix (POSTprocess):")
    print(f"Size: {POSTprocess.shape}")
    print(f"Non-zero elements: {np.count_nonzero(POSTprocess)} ({100*np.count_nonzero(POSTprocess)/POSTprocess.size:.2f}%)")
    print(f"Unique values: {np.unique(POSTprocess)}\n")
    
    # 绘制矩阵结构
    plot_sparsity([EVAL, INTERP, NORM, POSTprocess], 
                 ['Evaluation / Preprocessing Matrix', 'Interpolation Matrix', 'Normalization Matrix', 'Postprocessing Matrix'])

# 主程序
if __name__ == "__main__":
    EVAL_x, INTERP_x, POSTprocess_x = build_transform_matrices()
    k = 4
    EVAL = build_eval_matrix(k)
    INTERP = build_interp_matrix(k)
    # 构建POSTprocess矩阵
    if k == 1:
        POSTprocess = INTERP
    else:
        NORM = np.eye(2**k, 2**(k+1)-1)
        NORM[:(2**k-1), (2**k):(2**(k+1)-1)] -= np.eye(2**k-1)
        POSTprocess = NORM @ INTERP

    if np.array_equal(EVAL, EVAL_x):
        print("EVAL matrix is correct.")
    else:
        print("EVAL matrix is incorrect.")
    
    if np.array_equal(INTERP, INTERP_x):
        print("INTERP matrix is correct.")
    else:
        print("INTERP matrix is incorrect.")
        
    if np.array_equal(POSTprocess, POSTprocess_x):
        print("POSTprocess matrix is correct.")
    else:
        print("POSTprocess matrix is incorrect.")
    
    
    analyze_matrices(EVAL, INTERP, NORM, POSTprocess)