# PaperShare

> 论文分享平台 - LLM 评测与诊断

## 概述

PaperShare 是一个静态论文分享网站，包含两个部分：

- **📚 论文分享** - 分类整理的论文阅读笔记
- **📰 每日论文** - 每日 arXiv 论文调研日报

## 目录结构

```
papershare-github/
├── index.html          # 主入口（导航页）
├── papershare/         # 论文分享
│   ├── index.html      # 分类列表
│   └── papers/         # 论文详情 (23篇)
├── daily-paper/        # 每日论文
│   └── index.html      # 日报列表
└── data/
    └── clicks.json     # 点击数据
```

## 部署

### GitHub Pages

1. Fork 或克隆此仓库
2. 进入 Settings → Pages
3. Source 选择 `main` branch
4. 访问 `https://yourusername.github.io/papershare-github/`

### 自定义域名

如需使用 `papers.example.com`：
1. 在域名服务商添加 CNAME 记录指向 `LaugHan.github.io`
2. Settings → Pages → Custom domain 输入你的域名

## 技术栈

- 纯静态 HTML/CSS/JS
- 无需后端
- GitHub Pages 免费托管

## 相关项目

- [Claude-Code-Learning](https://github.com/LaugHan/Claude-Code-Learning) - Claude Code 源码学习
- [papershare](https://github.com/LaugHan/papershare) - 论文阅读框架

## License

MIT
