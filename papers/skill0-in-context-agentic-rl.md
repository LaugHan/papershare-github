# SKILL0: In-Context Agentic Reinforcement Learning for Skill Internalization

> **论文ID**: 2604.02268
> **类别**: cs.LG (Machine Learning)
> **作者**: Zhengxi Lu, Zhiyuan Yao, Jinyang Wu 等 (浙江大学 REAL Lab)
> **日期**: 2026-04-02
> **链接**: [arXiv](https://arxiv.org/abs/2604.02268) | [GitHub](https://github.com/ZJU-REAL/SkillZero)

---

## 0. 翻译摘要原文

> **Agent skills**, structured packages of procedural knowledge and executable resources that agents dynamically load at inference time, have become a reliable mechanism for augmenting LLM agents. Yet **inference-time skill augmentation is fundamentally limited**: retrieval noise introduces irrelevant guidance, injected skill content imposes substantial token overhead, and the model never truly acquires the knowledge it merely follows.

**Agent技能**——作为结构化程序性知识和可执行资源的组合，Agent在推理时动态加载——已成为增强LLM Agent的可靠机制。然而，**推理时技能增强存在根本性限制**：检索噪声引入无关指导、注入的技能内容带来大量token开销，而且模型从未真正获得它只是遵循的知识。

> We ask whether skills can instead be **internalized into model parameters**, enabling **zero-shot autonomous behavior** without any runtime skill retrieval. We introduce **SKILL0**, an in-context reinforcement learning framework designed for skill internalization.

我们提出问题：技能能否**内化到模型参数中**，实现零样本自主行为而无需运行时技能检索？我们提出**SKILL0**，一个为技能内化设计的上下文强化学习框架。

> SKILL0 introduces a **training-time curriculum** that begins with full skill context and progressively withdraws it. Skills are grouped offline by category and rendered with interaction history into a **compact visual context**, teaching the model tool invocation and multi-turn task completion. A **Dynamic Curriculum** then evaluates each skill file's on-policy helpfulness, retaining only those from which the current policy still benefits within a **linearly decaying budget**, until the agent operates in a fully zero-shot setting.

SKILL0引入**训练时课程**，从完整技能上下文开始，逐步撤回。技能按类别离线分组，并与交互历史一起渲染成**紧凑视觉上下文**，教导模型工具调用和多轮任务完成。**动态课程**评估每个技能文件的策略相关有用性，只保留当前策略仍有收益的技能，在**线性衰减预算**内，直到Agent在完全零样本设置下运行。

> Extensive agentic experiments demonstrate that SKILL0 achieves substantial improvements over the standard RL baseline (**+9.7% for ALFWorld and +6.6% for Search-QA**), while maintaining a highly efficient context of fewer than **0.5k tokens per step**.

大量Agent实验表明，SKILL0相比标准RL基线取得显著提升（**ALFWorld +9.7%, Search-QA +6.6%**），同时保持高效的上下文，每步少于**0.5k tokens**。

---

## 1. 方法动机

### a) 驱动力

LLM Agent正在被广泛部署用于复杂任务自动化，如ALFWorld、Search-QA等benchmark。然而，Agent需要依赖外部技能库（Tools、Procedures），这带来了以下问题：
- **知识与执行分离**：模型只是"遵循"技能，而非"学会"技能
- **推理时开销**：每次调用都需要加载完整的技能上下文
- **泛化能力受限**：无法处理训练时未见过的任务类型

### b) 现存痛点

1. **检索噪声**：推理时从技能库检索可能引入不相关指导
2. **Token开销**：技能内容注入带来大量额外token消耗
3. **知识获取缺失**：模型从未真正内化技能，只是临时遵循

### c) 研究假设

**核心假设**：技能可以通过训练时课程内化到模型参数中，使得Agent能够零样本执行任务，而无需任何运行时技能检索。

**直觉**：就像人类学习骑自行车，最终不需要"看着说明书"也能完成——技能应该成为模型的"肌肉记忆"。

---

## 2. 方法设计

### a) Pipeline 流程总结

```
┌─────────────────────────────────────────────────────────────────┐
│                    SKILL0 Pipeline                               │
├─────────────────────────────────────────────────────────────────┤
│                                                                  │
│  [Step 1] Skill Grouping & Rendering                            │
│  ─────────────────────────────────────                          │
│  Skills → Offline Grouping by Category                            │
│         → Render with Interaction History                        │
│         → Compact Visual Context (<0.5k tokens/step)             │
│                                                                  │
│  [Step 2] Training-Time Curriculum                              │
│  ─────────────────────────────────────                          │
│  Full Skill Context → Gradually Withdraw                         │
│         ↘ Linear Decay Budget [6,3,0]                           │
│                                                                  │
│  [Step 3] Dynamic Curriculum                                    │
│  ─────────────────────────────────────                          │
│  Evaluate on-policy helpfulness of each skill                    │
│         → Keep only beneficial skills                            │
│         → Prune redundant skills within budget                  │
│                                                                  │
│  [Step 4] Zero-Shot Inference                                   │
│  ─────────────────────────────────────                          │
│  No skill retrieval → Pure model parameters                      │
│         → Autonomous tool invocation                            │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

**详细步骤解析**：

#### Step 1: Skill Grouping & Rendering
- **输入**：原始技能文件（工具描述、调用格式、示例等）
- **处理**：
  1. 按类别离线分组技能
  2. 将交互历史与技能渲染成紧凑的视觉上下文
  3. 压缩到每步 <0.5k tokens
- **输出**：结构化的技能上下文

#### Step 2: Training-Time Curriculum
- **初始阶段**：提供完整技能上下文，模型学习工具调用模式
- **退火阶段**：逐步减少技能上下文长度
- **最终阶段**：完全移除技能上下文，模型只能依靠已内化的知识

#### Step 3: Dynamic Curriculum (核心创新)
- **评估机制**：在线评估每个技能文件的"策略相关有用性"
- **保留策略**：只保留当前策略仍有收益的技能
- **剪枝机制**：在预算约束内动态剪枝冗余技能
- **预算设计**：`[6,3,0]` 表示三个阶段的技能数量上限

#### Step 4: Zero-Shot Inference
- **无检索**：推理时完全不加载技能库
- **纯参数知识**：完全依靠模型参数中内化的技能知识
- **目标**：达到与有技能辅助时相当的性能

### b) 模型结构

**SKILL0 不依赖特殊模型架构**，可以在任何支持RL训练的LLM上实现：

| 组件 | 功能 | 技术细节 |
|------|------|----------|
| Skill Renderer | 技能格式化 | 将技能+交互历史转为视觉token序列 |
| RL Trainer | 策略优化 | 使用PPO或类似方法优化 |
| Budget Scheduler | 预算调度 | 线性衰减控制技能数量 |
| Helpfulness Evaluator | 有用性评估 | on-policy价值估计 |

### c) 关键公式

**动态课程预算**：
```
B_t = B_max * (1 - t/T)
```
其中 B_t 是时间t的预算，B_max 是初始预算，T 是总训练步数。

**技能有用性评估**：
```
H(s) = V_π(s) - V_π_without(s)
```
保留 H(s) > 0 的技能，即移除后价值下降的技能。

---

## 3. 与其他方法对比

### a) 本质差异

| 对比维度 | SKILL0 (本文) | 传统推理时技能增强 |
|----------|---------------|-------------------|
| 知识位置 | 模型参数内 | 外部技能库 |
| 推理时开销 | ~0 tokens | 技能检索+上下文 |
| 泛化能力 | 可泛化到新任务 | 受限于技能库覆盖 |
| 知识获取 | 真正的内化学习 | 表面的行为模仿 |

### b) 创新点

1. **技能内化范式转变**：从"推理时增强"到"训练时内化"
2. **动态课程设计**：结合技能数量衰减和有用性评估
3. **紧凑视觉上下文**：每步 <0.5k tokens，显著降低开销

### c) 适用范围

✅ **适用场景**：
- Agent需要反复执行同类任务
- 技能库相对稳定但执行细节可学习
- 对推理延迟和成本敏感

❌ **不适用场景**：
- 一次性任务（不值得训练）
- 技能需要频繁更新的场景
- 完全新颖的任务类型

### d) 方法对比表

| 方法 | 推理时Token开销 | 技能内化 | 泛化能力 | 训练复杂度 |
|------|----------------|----------|----------|-----------|
| **SKILL0** | ~0 | ✅ 完全 | ✅ 强 | 中等 |
| Toolformer | 高 | ❌ | ❌ | 高 |
| ReAct | 最高 | ❌ | ❌ | 低 |
| ToolBench | 高 | ❌ | 中等 | 高 |

---

## 4. 实验表现与优势

### a) 验证方法

**数据集**：
- **ALFWorld**：多步骤家务任务Agent benchmark
- **Search-QA**：搜索问答任务

**基线对比**：
- Standard RL baseline（无技能课程）
- Fixed Full（全程使用完整技能上下文）
- Fixed Budget（固定技能数量，不动态调整）

### b) 关键结果

| 方法 | ALFWorld | Search-QA | Token/step |
|------|----------|-----------|-----------|
| Standard RL | 基线 | 基线 | - |
| Fixed Full [6,6,6] | -13.3% | - | 完整技能 |
| Fixed Budget [3,3,3] | 低于峰值 | - | 中等 |
| **SKILL0 [6,3,0]** | **+9.7%** | **+6.6%** | **<0.5k** |

**关键发现**：
- Fixed Full移除技能后性能崩溃（-13.3%），说明模型只是"遵循"而非"学会"
- SKILL0移除技能后反而提升（+1.6%），证明技能真正被内化

### c) 优势场景

**在技能移除场景下优势最明显**：
- 推理时无法访问技能库
- 需要最小化token开销
- 任务需要快速响应

### d) 局限性

1. **训练成本**：需要额外的RL训练过程
2. **技能更新**：技能更新需要重新训练
3. **任务泛化**：对完全新颖的任务类型可能无效
4. **评估复杂性**：需要设计合适的"有用性"评估指标

---

## 5. 学习与应用

### a) 开源情况

✅ **完全开源**：
- 代码：https://github.com/ZJU-REAL/SkillZero
- 复现难度：中等（有明确的数据准备和训练流程）

### b) 实现细节

**关键超参数**：
- 初始预算 B_max = 6
- 衰减节奏 [6,3,0]（三个阶段）
- 每步最大token数 < 500

**数据准备**：
1. 收集任务-技能-交互轨迹
2. 按类别分组技能
3. 生成紧凑的视觉上下文

**训练建议**：
- 使用PPO或GRPO等on-policy RL方法
- 配合课程学习策略
- 在线评估技能有用性

### c) 迁移能力

**可迁移到**：
- 其他Agent任务（Web Agent, Code Agent等）
- 多模态Agent
- 工具学习场景

**迁移步骤**：
1. 定义技能接口和渲染格式
2. 收集任务轨迹数据
3. 应用SKILL0课程训练
4. 在零样本设置下评估

---

## 6. 总结

### a) 一句话概括（≤20字）

> **通过训练时课程将Agent技能内化到模型参数，实现零样本自主执行。**

### b) 速记版Pipeline（3-5步）

1. **渲染技能**：把技能和交互历史打包成紧凑视觉上下文
2. **课程训练**：从完整技能上下文开始，逐步撤回
3. **动态剪枝**：只保留模型还有收益的技能
4. **零样本推理**：完全依靠内化知识，无需技能检索

### c) 核心洞察

> **技能不应该只是被"遵循"，更应该被"学会"。SKILL0证明了通过设计合适的训练课程，可以将外部技能转化为模型参数中的内部知识。**

---

## 🔗 相关论文

- [Toolformer (2023)](https://arxiv.org/abs/2302.04761) - 工具学习先驱
- [ReAct (2023)](https://arxiv.org/abs/2210.03629) - 推理+行动范式
- [ALFWorld](https://alfworld.github.io/) - Agent benchmark

---

*📅 分析日期: 2026-04-06*
