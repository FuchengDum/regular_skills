# 修改文章工作流

完整的修改文章八步流程，包含诊断、用户决策、执行修改和变更追踪。

## 流程概览

```
读取文章
  ↓
Claude 初步分析（结构/问题点）
  ↓
Gemini 诊断调用（联网，独立）
  ↓
输出诊断报告 + 编号建议列表
  ↓
用户选择：改哪些 / 怎么改
  ↓
Codex 执行修改
  ↓
Gemini 审核修改结果（独立）
  ↓
Claude 整合 + 追加 changelog + 输出
```

## 详细步骤

### 第1步：读取文章

获取文章路径，读取完整内容：

```bash
# 从 Hexo source/_posts/ 读取
cat source/_posts/{slug}.md
```

记录：
- 文章标题、发布日期
- 涉及的主要技术栈和版本号
- 文章结构（章节数、代码块数）

---

### 第2步：Claude 初步分析

执行快速结构分析，**不联网**，基于文章自身内容：

**分析维度：**
- 文章结构是否清晰（章节层级、逻辑顺序）
- 明显的格式问题（标题跳级、代码块缺语言标注）
- 文章中显式提及的版本号、API 名称（提供给 Gemini 诊断）
- 明显的表述错误或不一致

**输出：**
- 初步分析摘要（给用户看）
- Gemini 诊断重点提示列表（交给第3步）

---

### 第3步：Gemini 诊断调用（联网）

**独立调用 Gemini，不共享 Claude 的上下文。**

使用 [gemini-reviewer.md](model-roles/gemini-reviewer.md) 中的**诊断模式**模板：

```bash
# 调用方式
gemini -p "$(cat /tmp/gemini-diag-prompt.txt)" -o text
```

提示中包含：
- 完整文章内容
- Claude 初步分析中提取的重点检查项
- 诊断模式输出格式要求

**Gemini 联网能力用于：**
- 验证版本号是否是最新稳定版
- 检查 API/方法是否已废弃
- 验证文中链接是否有效

---

### 第4步：输出诊断报告 + 编号建议列表

将 Gemini 诊断结果格式化后呈现给用户：

```markdown
## 📋 文章诊断报告

### 过时问题
| # | 位置 | 当前内容 | 最新状态 | 严重程度 |
|---|------|----------|----------|----------|
| 1 | 安装步骤 | Node.js v16 | 当前LTS为v22 | 高 |
| 2 | 示例代码 | componentWillMount | 已废弃，React 18删除 | 高 |

### 错误问题
| # | 位置 | 问题描述 | 修复建议 | 严重程度 |
|---|------|----------|----------|----------|
| 3 | 步骤3代码 | async/await 语法错误 | 补充 await 关键字 | 高 |

### 建议修改列表
1. [过时] 更新 Node.js 版本示例至 v22（简单）
2. [过时] 替换废弃的 `componentWillMount` 为 `useEffect`（中等）
3. [错误] 修复步骤3代码中的 async/await 语法错误（简单）
4. [优化] 精简第2节的冗长说明（简单）
```

---

### 第5步：用户选择

提示用户选择要执行的建议：

```
请选择要执行的修改（输入编号，用逗号分隔，或输入"全部"）：
例如：1,2,3  或  全部  或  1,3（跳过2）

也可以补充说明：
例如：1,2 - 第2条请保留旧版本的兼容性说明
```

**用户可以：**
- 选择全部建议
- 选择部分编号
- 为某条建议附加补充说明（影响 Codex 执行方式）
- 拒绝所有（退出修改流程）

---

### 第6步：Codex 执行修改

将用户选择的修改项整理为 Codex 指令：

使用 [claude-architect.md](model-roles/claude-architect.md) 中的**修改整合**发送给 Codex 的指令模板：

```bash
# 调用方式
codex exec "$(cat /tmp/codex-edit-prompt.txt)"
```

**指令要求：**
- 明确列出每条要修改的内容
- 提供修改前/修改后的对比期望
- 强调只修改指定内容，保持其他部分不变

---

### 第7步：Gemini 审核修改结果（独立）

对 Codex 输出的修改后文章进行质量审核：

使用 [gemini-reviewer.md](model-roles/gemini-reviewer.md) 中的**审核模式**模板：

```bash
gemini -p "$(cat /tmp/gemini-review-prompt.txt)" -o text
```

**审核重点：**
- 修改内容是否符合用户选择的建议
- 修改后的代码是否正确
- 是否引入新的问题
- 整体文章连贯性

---

### 第8步：Claude 整合 + 追加 Changelog + 输出

**整合流程：**

1. 评估 Gemini 审核意见
   - 无阻断问题：直接进行下一步
   - 有阻断问题：返回 Codex 局部修正（不整体重做）
2. 整合修改到最终文章
3. **在文章末尾追加 changelog 章节**
4. 输出完整更新后的文章

#### Changelog 格式

在文章末尾追加（如已存在 `## 更新日志` 章节，则在其下新增小节）：

```markdown
## 更新日志

### 2026-03-02
- [过时] 更新 Node.js 版本示例至 v22
- [过时] 替换废弃的 `componentWillMount` 为 `useEffect`
- [修复] 修复步骤3代码中的 async/await 语法错误
```

**标签说明：**
| 标签 | 含义 |
|------|------|
| `[过时]` | 更新了过时的版本/API/链接 |
| `[修复]` | 修正了错误的内容 |
| `[优化]` | 改善了表述或结构 |

---

## CLI 快速参考

```bash
# Gemini 诊断调用
echo "{诊断prompt}" > /tmp/gemini-diag-prompt.txt
gemini -p "$(cat /tmp/gemini-diag-prompt.txt)" -o text

# Codex 执行修改
echo "{修改prompt}" > /tmp/codex-edit-prompt.txt
codex exec "$(cat /tmp/codex-edit-prompt.txt)"

# Gemini 审核调用
echo "{审核prompt}" > /tmp/gemini-review-prompt.txt
gemini -p "$(cat /tmp/gemini-review-prompt.txt)" -o text
```

## 相关文档

- [Gemini 诊断模式 prompt](model-roles/gemini-reviewer.md#诊断模式修改文章专用)
- [Claude 修改整合职责](model-roles/claude-architect.md#4-修改整合职责)
- [Codex 内容工程师](model-roles/codex-engineer.md)
- [Hexo 格式规范](hexo-guide.md)
