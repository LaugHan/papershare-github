#!/bin/bash
# ============================================================
# arXiv Daily Paper 生成脚本
# ============================================================
# 使用方法: bash scripts/generate-daily-paper.sh
#
# 注意事项:
# 1. 生成后必须验证HTML结构
# 2. 上传前运行验证命令
# ============================================================

set -e

REPO_DIR="/home/laughan/papershare-github"
INDEX_FILE="$REPO_DIR/daily-paper/index.html"

echo "开始生成日报..."

# TODO: 实现自动调研逻辑
# 1. 获取arXiv cs.AI/cs.CL/cs.LG最新论文
# 2. 按关键词过滤(Agent, Reasoning, Metacognition, Hallucination等)
# 3. 生成HTML

echo "日报生成完成"

# ============================================================
# HTML 格式规范 (必须严格遵守)
# ============================================================
# 
# 每个 paper-card 的正确格式:
# ```html
# <div class="paper-card">
#     <h2>论文标题</h2>
#     <div class="meta">arXiv:xxxx.xxxxx | cs.CL | YYYY-MM-DD</div>
#     <div class="abstract">
#         <strong>摘要内容</strong>
#     </div>
#     <div class="insight">
#         💡 <strong>核心洞见</strong>：洞见内容
#     </div>
#     <div class="link">
#         <a href="https://arxiv.org/abs/xxxx.xxxxx" target="_blank">论文链接 →</a>
#         <span class="tag">标签1</span>
#         <span class="tag">标签2</span>
#     </div>
# </div>
# ```
#
# ⚠️ 常见错误:
# 1. link div 内部不能有 `|` 分隔符
# 2. link div 后不能跟额外的 `</div>` 或详解链接
# 3. 错误示例:
#    <div class="link">...</div> | <a>详解</a> <span>...</span></div>
# 4. 正确示例:
#    <div class="link"><a>...</a> <span>...</span></div>
#
# ============================================================

echo ""
echo "=============================================="
echo "⚠️  重要：生成后必须验证HTML结构！"
echo "=============================================="
echo ""
echo "验证命令:"
echo "  python3 -c \"from html.parser import HTMLParser; f=open('$INDEX_FILE'); p=HTMLParser(); p.feed(f.read()); print('OK' if not p.errors else p.errors)\""
echo ""
