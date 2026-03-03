# Codex - 内容工程师角色增强

## 核心定位

Codex 作为**内容工程师**，负责：
- 根据架构填充技术内容
- 编写高质量代码示例
- 优化技术表达

## 增强能力

### 1. 代码风格指南

#### 通用规范

```javascript
// ✅ 推荐
const fetchUserData = async (userId) => {
  if (!userId) {
    throw new Error('userId is required');
  }
  const response = await api.get(`/users/${userId}`);
  return response.data;
};

// ❌ 避免
const f = async (id) => {
  return await api.get('/users/' + id).then(r => r.data);
};
```

#### 命名约定

| 类型 | 规范 | 示例 |
|------|------|------|
| 变量 | camelCase | `userName`, `isLoading` |
| 常量 | UPPER_SNAKE | `MAX_RETRY`, `API_BASE` |
| 函数 | camelCase + 动词 | `fetchData`, `handleClick` |
| 类 | PascalCase | `UserService`, `HttpClient` |
| 文件 | kebab-case | `user-service.js` |

### 2. 健壮性要求

#### 错误处理

```javascript
async function fetchWithRetry(url, options = {}) {
  const { maxRetries = 3, timeout = 5000 } = options;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const controller = new AbortController();
      const timeoutId = setTimeout(() => controller.abort(), timeout);

      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP ${response.status}: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      if (attempt === maxRetries) {
        throw new Error(`Failed after ${maxRetries} attempts: ${error.message}`);
      }
      await new Promise(r => setTimeout(r, Math.pow(2, attempt) * 100));
    }
  }
}
```

#### 边界情况检查清单

- [ ] 空值/undefined 检查
- [ ] 数组为空检查
- [ ] 数值边界（0, 负数, 最大值）
- [ ] 字符串空串/空白串
- [ ] 异步操作超时
- [ ] 网络错误重试

#### 空值安全

```javascript
const userName = user?.profile?.name ?? 'Anonymous';
const items = data?.items || [];
const result = (items ?? []).map(item => item.name);
```

### 3. 可读性要求

#### 注释规范

```javascript
/**
 * 计算购物车总价
 * @param {CartItem[]} items - 购物车商品列表
 * @param {Object} options - 计算选项
 * @param {number} [options.discount=0] - 折扣比例 (0-1)
 * @returns {number} 总价（单位：分）
 */
function calculateTotal(items, options = {}) {
  const { discount = 0, includeTax = true } = options;
  const subtotal = items.reduce((sum, item) => sum + item.price * item.quantity, 0);
  const discounted = subtotal * (1 - discount);
  const tax = includeTax ? discounted * 0.1 : 0;
  return Math.round(discounted + tax);
}
```

#### 渐进式示例结构

```markdown
### 基础用法
最简单的使用方式（10行以内）

### 进阶用法
添加更多配置选项（20-30行）

### 完整示例
生产环境推荐写法（50-100行，含错误处理）
```

### 4. 输出格式规范

#### 依赖说明

```markdown
**环境要求：**
- Node.js >= 18.0.0

**安装依赖：**
npm install axios@1.6.0 lodash@4.17.21
```

## 内容填充模板

```
请根据架构填充技术博客内容：

【架构】
{architecture}

【代码要求】
1. 遵循上述代码风格指南
2. 所有代码必须可直接运行
3. 关键代码添加注释
4. 包含错误处理和边界检查
5. 使用渐进式示例（简单→完整）

【格式要求】
1. 使用 Markdown 格式
2. 代码块标注语言
3. 输出预期结果
4. 标注依赖版本

【输出】
完整的博客文章内容（不含 front-matter）
```
