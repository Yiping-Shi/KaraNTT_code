import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns

# 设置风格
plt.style.use('ggplot')
sns.set_palette("colorblind")

# 延迟数据 (微秒)
designs = ['Wang [1]', 'Su [2]', 'Su [3]', 'Roy [4]', 'Benaissa [5]', 'Ours']
n_256 = [5.18, None, 1.32, 0.54, 1.91, 0.36]  # N=256
n_4096 = [87.05, 66.75, None, None, None, 3.94]  # N=4096
n_65536 = [None, 306.98, None, None, None, 102.92]  # N=65536

# 创建DataFrame
df_latency = pd.DataFrame({
    'Design': designs * 3,
    'N Size': ['N=256']*6 + ['N=4096']*6 + ['N=65536']*6,
    'Latency (μs)': n_256 + n_4096 + n_65536
})

# 过滤None值
df_latency = df_latency.dropna()

plt.figure(figsize=(12, 6))
bar = sns.barplot(x='Design', y='Latency (μs)', hue='N Size', data=df_latency)

# 添加数值标签
for p in bar.patches:
    bar.annotate(format(p.get_height(), '.2f'), 
                 (p.get_x() + p.get_width() / 2., p.get_height()), 
                 ha = 'center', va = 'bottom', rotation=0, xytext = (0, 5),
                 textcoords = 'offset points')

plt.title('Latency Comparison across Different Designs and N Sizes', fontsize=16)
plt.xlabel('Design', fontsize=14)
plt.ylabel('Latency (μs)', fontsize=14)
plt.yscale('log')  # 对数尺度，更好地展示差异
plt.grid(True, alpha=0.3)
plt.tight_layout()
plt.savefig('latency_comparison.png', dpi=300)
plt.show()



# ATP 数据
atp_data = {
    'Design': ['Wang [1]', 'Su [2]', 'Su [3]', 'Roy [4]', 'Benaissa [5]', 'Ours'],
    'N=256': [41.42, None, 638.88, 27, 0, 496.8],
    'N=4096': [2089, 0, None, None, None, 432906], 
    'N=65536': [None, 0, None, None, None, 142029.6]
}

df_atp = pd.DataFrame(atp_data)
df_atp = df_atp.set_index('Design')
df_atp = df_atp.apply(pd.to_numeric, errors='coerce')

# 转置以便设计作为X轴
df_atp_plot = df_atp.T

plt.figure(figsize=(10, 6))
ax = df_atp_plot.plot(kind='bar', width=0.7)

plt.title('Area-Time Product (ATP) Comparison', fontsize=16)
plt.xlabel('Polynomial Size', fontsize=14)
plt.ylabel('ATP', fontsize=14)
plt.yscale('log')  # 对数尺度
plt.grid(True, alpha=0.3, axis='y')
plt.legend(title='Design')
plt.tight_layout()
plt.savefig('atp_comparison.png', dpi=300)
plt.show()


# 资源数据 - 标准化到0-1范围内便于比较
# 使用您的设计作为基准(=1)，其他设计相对值
resources = ['LUT', 'FF', 'DSP', 'BRAM']
designs = ['Ours', 'Wang [1]', 'Su [2]', 'Su [3]', 'Roy [4]']

# N=4096的相对资源使用 (归一化)
resource_data = np.array([
    [1.0, 1.0, 1.0, 1.0],     # Ours (基准)
    [0.08, 0.07, 0.02, 0.08], # Wang [1]
    [0.17, 0.21, 0.0, 0.11],  # Su [2]
    [0.34, 0.0, 0.35, 0.08],  # Su [3]
    [0.15, 0.10, 0.04, 0.09]  # Roy [4]
])

# 角度计算
angles = np.linspace(0, 2*np.pi, len(resources), endpoint=False).tolist()
angles += angles[:1]  # 闭合图形

# 扩展数据以闭合图形
resource_data_plot = np.zeros((len(designs), len(resources)+1))
for i in range(len(designs)):
    resource_data_plot[i] = np.append(resource_data[i], resource_data[i][0])

# 绘制雷达图
fig, ax = plt.subplots(figsize=(10, 8), subplot_kw=dict(polar=True))

for i, design in enumerate(designs):
    ax.plot(angles, resource_data_plot[i], linewidth=2, label=design)
    ax.fill(angles, resource_data_plot[i], alpha=0.1)

# 添加标签
ax.set_xticks(angles[:-1])
ax.set_xticklabels(resources)
ax.set_yticks([0.25, 0.5, 0.75, 1.0])
ax.set_yticklabels(['25%', '50%', '75%', '100%'])
ax.set_title('Resource Utilization Comparison (N=4096)', fontsize=16, pad=20)

# 添加图例
plt.legend(loc='upper right', bbox_to_anchor=(0.1, 0.1))
plt.tight_layout()
plt.savefig('resource_radar.png', dpi=300)
plt.show()



# 创建可扩展性趋势图
n_values = [256, 4096, 65536]
latency_ours = [0.36, 3.94, 102.92]  # 我们设计的延迟
latency_others = [
    [5.18, 87.05, None],    # Wang [1]
    [None, 66.75, 306.98],  # Su [2]
]

plt.figure(figsize=(10, 6))
plt.plot(n_values, latency_ours, 'o-', linewidth=2, label='Ours', color='red')

# 添加其他设计的数据点
for i, other_latency in enumerate(latency_others):
    valid_points = [(n, lat) for n, lat in zip(n_values, other_latency) if lat is not None]
    if valid_points:
        x_vals, y_vals = zip(*valid_points)
        plt.plot(x_vals, y_vals, 'o--', label=f'Design {i+1}')

plt.title('Latency Scaling with Polynomial Size', fontsize=16)
plt.xlabel('Polynomial Size (N)', fontsize=14)
plt.ylabel('Latency (μs)', fontsize=14)
plt.xscale('log', base=2)  # 使用log2刻度
plt.yscale('log')
plt.grid(True, alpha=0.3)
plt.legend()
plt.tight_layout()
plt.savefig('scalability_trend.png', dpi=300)
plt.show()



# 硬件组件资源占比饼图
components = ['BU_Array', 'Poly_Unit', 'Data Memory', 'Twiddle Factor Memory', 'Control Unit']
lut_values = [27.59, 46.16, 2.88, 0.56, 2.43]  # 单位:K

plt.figure(figsize=(10, 7))
plt.pie(lut_values, labels=components, autopct='%1.1f%%', startangle=90, 
        shadow=True, explode=[0, 0.1, 0, 0, 0], 
        colors=sns.color_palette('pastel'))
plt.axis('equal')  # 保持饼图为圆形
plt.title('LUT Resource Distribution by Component', fontsize=16)
plt.tight_layout()
plt.savefig('component_breakdown.png', dpi=300)
plt.show()