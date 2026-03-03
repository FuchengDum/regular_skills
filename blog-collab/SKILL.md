---
name: blog-collab
description: |
  多模型协作博客写作工具，支持技术博客的创建和修改。使用 Claude 编写文章架构、Codex 调整内容、Gemini 审核技术准确性。
  适用场景：(1) 创建新的 Hexo 技术博客文章 (2) 修改优化现有博客内容 (3) 需要多模型协作审核的博客写作任务。
  触发词：博客写作、写博客、blog、技术文章、hexo 文章、多模型协作写作
---

# 多模型协作博客写作

三模型协作：**Claude（架构师）** → **Codex（内容工程师）** → **Gemini（技术审核员）**

## 快速开始

### 第1步：选择文章类型

| 类型 | 适用场景 | 参考模板 |
|------|----------|----------|
| 📚 教程类 | 入门教程、功能指南 | [tutorial.md](references/article-types/tutorial.md) |
| 🔧 问题解决类 | 错误排查、踩坑记录 | [troubleshoot.md](references/article-types/troubleshoot.md) |
| ⚖️ 技术对比类 | 框架选型、工具比较 | [comparison.md](references/article-types/comparison.md) |
| 🔬 深度解析类 | 原理剖析、源码分析 | [deep-dive.md](references/article-types/deep-dive.md) |

### 第2步：执行工作流

```
用户提供主题 + 类型
       ↓
Claude 设计架构（CoT 思维链）
       ↓
Codex 填充内容（CLI 调用）
       ↓
Gemini 审核（版本+安全+排版）
       ↓
Claude 整合修改
       ↓
输出 Hexo 格式文章
```

## 模型角色

| 模型 | 角色 | 详细文档 |
|------|------|----------|
| Claude | 架构师 | [claude-architect.md](references/model-roles/claude-architect.md) |
| Codex | 内容工程师 | [codex-engineer.md](references/model-roles/codex-engineer.md) |
| Gemini | 技术审核员 | [gemini-reviewer.md](references/model-roles/gemini-reviewer.md) |

## CLI 调用

### Codex（内容填充）

```bash
# 直接调用
codex exec "根据以下架构填充技术博客内容：[架构内容]"

# 通过脚本（长文本）
echo "prompt内容" > /tmp/codex-prompt.txt
bash scripts/call-codex.sh /tmp/codex-prompt.txt /tmp/codex-output.md
```

### Gemini（技术审核）

```bash
# 直接调用
gemini -p "请审核以下技术博客文章：[文章内容]" -o text

# 通过脚本（长文本）
echo "prompt内容" > /tmp/gemini-prompt.txt
bash scripts/call-gemini.sh /tmp/gemini-prompt.txt /tmp/gemini-output.md
```

## 详细工作流

### 新建文章

1. **确定类型**：根据主题选择文章类型
2. **Claude 架构设计**
   - 执行 CoT 思维链分析
   - 输出架构文档（参考 [claude-architect.md](references/model-roles/claude-architect.md)）
3. **Codex 内容填充**
   - 按架构生成内容
   - 遵循代码规范（参考 [codex-engineer.md](references/model-roles/codex-engineer.md)）
4. **Gemini 技术审核**
   - 版本/API 过时检查
   - 代码安全审核
   - 排版格式审核
   - 输出审核报告（参考 [gemini-reviewer.md](references/model-roles/gemini-reviewer.md)）
5. **Claude 整合**
   - 评估审核意见
   - 整合修改或返回 Codex 重写
6. **输出文章**
   - 生成 Hexo 格式文章
   - 可选：生成配图

### 修改文章

详细流程见 [edit-workflow.md](references/edit-workflow.md)，包含：
- Gemini 联网诊断 + 生成编号建议列表
- 用户选择修改项
- Codex 执行修改
- Gemini 审核修改结果
- 文章末尾追加 changelog

## Hexo 文章模板

```markdown
---
title: {{ title }}
date: {{ date }}
tags:
  - {{ tag1 }}
categories:
  - {{ category }}
---

## 前言
[文章背景和目标]

## 正文
[按文章类型结构组织]

## 总结
[要点回顾]
```

## 图片生成

```bash
gen-image "prompt" --output /path/to/image.jpg --quiet
```

## 输出位置

- 文章：`source/_posts/[slug].md`
- 图片：`source/_posts/[slug]/`

## 参考文档导航

### 文章类型模板
- [教程类](references/article-types/tutorial.md)
- [问题解决类](references/article-types/troubleshoot.md)
- [技术对比类](references/article-types/comparison.md)
- [深度解析类](references/article-types/deep-dive.md)

### 模型角色指南
- [Claude 架构师](references/model-roles/claude-architect.md)
- [Codex 内容工程师](references/model-roles/codex-engineer.md)
- [Gemini 技术审核员](references/model-roles/gemini-reviewer.md)

### 格式规范
- [Hexo 写作规范](references/hexo-guide.md)

### 工作流参考
- [修改文章完整流程](references/edit-workflow.md)
