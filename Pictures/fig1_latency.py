import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

# 设置风格
plt.style.use('ggplot')
sns.set_palette("colorblind")

# 延迟数据 (微秒)
designs = ['Wang [1]', 'Su [2]', 'Su [3]', 'Roy [4]', 'Benaissa [5]', 'Ours']

# 将0值替换为NaN避免占位
n_256 = [5.18, np.nan, 1.32, 0.54, 1.91, 0.36]  # N=256
n_4096 = [87.05, 66.75, np.nan, np.nan, np.nan, 3.94]  # N=4096
n_65536 = [np.nan, np.nan, np.nan, np.nan, np.nan, 102.92]  # N=65536

# 创建DataFrame
df_latency = pd.DataFrame({
    'Design': designs * 3,
    'N Size': ['N=256']*6 + ['N=4096']*6 + ['N=65536']*6,
    'Latency (μs)': n_256 + n_4096 + n_65536
})

# 过滤无效数据（删除所有0/NaN）
df_latency = df_latency.dropna(subset=['Latency (μs)'])

plt.figure(figsize=(12, 6))
bar = sns.barplot(
    x='N Size',
    y='Latency (μs)',
    hue='Design',
    data=df_latency,
    # 添加以下两个关键参数
    hue_order=designs,  # 保持图例顺序
    dodge=True  # 保持同组柱子并排
)

# 添加数值标签
for p in bar.patches:
    bar.annotate(format(p.get_height(), '.2f'), 
                (p.get_x() + p.get_width() / 2., p.get_height()), 
                ha='center', va='bottom', rotation=0, xytext=(0, 5),
                textcoords='offset points')

plt.title('Latency Comparison across Different Designs and N Sizes', fontsize=16)
plt.xlabel('N Size', fontsize=14)
plt.ylabel('Latency (μs)', fontsize=14)
plt.yscale('log')
plt.grid(True, which='both', alpha=0.3)
plt.legend(title='Design', bbox_to_anchor=(1.05, 1), loc='upper left')  # 图例外置
plt.tight_layout()
plt.savefig('fig1_latency.png', dpi=300, bbox_inches='tight')  # 保存完整图片