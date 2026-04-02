# Beyond pass@1: A Reliability Science Framework for Long-Horizon LLM Agents

## 论文信息
- **arXiv**: [2603.29231](https://arxiv.org/abs/2603.29231)
- **作者**: Aaditya Khanal, Yangyang Tao, Junxiu Zhou
- **领域**: cs.AI
- **日期**: 2026-04-01

---

## 0. 翻译摘要

**原文摘要核心**:
Machine learning benchmarks evaluate capability — whether a model succeeds on a single attempt. Production deployments require reliability — whether a model consistently succeeds across repeated invocations on tasks of varying duration. We show these two properties diverge systematically as task duration increases, and that existing benchmarks are structurally blind to this divergence because they report only pass@1 on short, atomic tasks.

机器学习基准评估的是**能力**（模型在单次尝试中是否成功），但生产部署需要的是**可靠性**（模型在多次调用不同持续时间任务时是否持续成功）。本文表明这两个属性随着任务持续时间增加而系统性地分化，而现有基准由于仅报告短原子任务的pass@1，在结构上无法检测到这种分化。

---

## 1. 方法动机

### a) 驱动力
随着LLM Agent在生产系统中的部署加速，评估方法却仍然停留在"单次成功率"模式，无法反映真实使用场景。

### b) 现存痛点
- **τ-bench案例**: GPT-4o在零售Agent任务上达到61% pass@1，但pass@8仅25%——意味着运行8次时失败概率接近75%
- 现有基准只评估短、原子任务，忽略真实场景（重构代码库、研究报告合成、文档处理）需要数十分钟到数小时

### c) 研究假设
**可靠性随着任务复杂度（由持续时间和领域结构共同决定）超线性退化**，且这种退化对只报告pass@1的基准不可见。

---

## 2. 方法设计

### 四维可靠性指标框架

| 指标 | 全称 | 作用 |
|------|------|------|
| **RDC** | Reliability Decay Curve | 描述pass@k如何随任务持续时间退化 |
| **VAF** | Variance Amplification Factor | 量化持续时间如何放大随机失败模式 |
| **GDS** | Graceful Degradation Score | Agent部分完成长任务的Partial-credit指标 |
| **MOP** | Meltdown Onset Point | 通过工具调用序列的滑动窗口熵检测行为崩溃 |

### Benchmark构建
- **396任务** × **4个持续时间桶** × **3个领域**（33任务/单元）
- **23,392个episode**（k=3重复，2个脚手架）
- **10个开源模型**通过OpenRouter统一API评估

---

## 3. 与其他方法对比

### 创新点
1. **首次联合研究**: 多模型 × 多持续时间桶 × 方差感知可靠性指标
2. **超越pass@1**: 引入多维可靠性度量
3. **长程任务评估**: 填补短原子任务的评估空白

| 方法 | 持续时间维度 | 方差测量 | Partial Credit |
|------|-------------|---------|----------------|
| τ-bench | ✗ | ✗ | ✗ |
| METR长程研究 | ✓ | ✗ | ✗ |
| ReliabilityBench | ✓ | ✓ | ✗ |
| **本文框架** | **✓** | **✓** | **✓** |

---

## 4. 实验表现与优势

### 核心发现

1. **可靠性衰减是领域分层的**
   - SE: GDS从0.90降至0.44
   - DP: 基本持平（0.74→0.71）

2. **VAF按能力层级二分**
   - 前沿模型: VAF ≥ 2.37
   - 中间层级: VAF ≤ 1.26
   - **反直觉发现**: 高方差放大是能力标志，而非不稳定标志

3. **能力与可靠性排名大幅分化**
   - 中程到超长视野出现多级排名反转

4. **MOP悖论**
   - 前沿模型展示最高崩溃率（高达19%）
   - 原因: 追求雄心勃勃的多步策略

5. **Memory脚手架普遍有害**
   - 对所有10个模型的长程GDS均负面影响
   - 为**朴素 Episodic Memory** 作为可靠性干预提供强有力反证

---

## 5. 学习与应用

### 开源情况
- Benchmark公开发布
- 代码可通过论文链接获取

### 对评估实践的启示
1. **可靠性应成为与能力并列的一级评估维度**
2. **Memory Augmentation需重新审视**——长程场景可能有害
3. **前沿模型的高崩溃率**提示需要更好的Meltdown检测机制

---

## 6. 总结

### 一句话概括
**可靠性是能力的正交维度，现有pass@1基准无法捕捉长程任务中的可靠性衰减。**

### 核心价值
- 提出RDC/VAF/GDS/MOP四维可靠性框架
- 揭示Memory脚手架在长程任务中的反效果
- 为LLM Agent生产部署提供系统性评估工具

---

*相关标签: Agent评估, 可靠性科学, 长程推理, 评估框架*
