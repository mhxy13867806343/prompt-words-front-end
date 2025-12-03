# 快速开始指南

## 项目概述

这是一个基于 Vue 3 + TypeScript + Vite + Element Plus 的提示词管理系统前端项目。

## 已完成的功能

✅ **用户认证系统**
- 注册/登录/退出
- 找回密码（邮箱验证码）
- 邮箱绑定功能
- Token 认证（30天有效期）

✅ **提示词管理**
- 创建、编辑、删除提示词
- 查看提示词详情
- 搜索提示词
- 分页展示

✅ **互动功能**
- 点赞/取消点赞
- 收藏/取消收藏
- 浏览计数
- 分享链接
- 复制内容

✅ **个人中心**
- 我的提示词
- 我的点赞
- 我的收藏

✅ **响应式设计**
- 支持桌面端和移动端

## 快速启动

### 1. 安装依赖

```bash
pnpm install
```

### 2. 启动开发服务器

```bash
pnpm dev
```

访问: http://localhost:3000

### 3. 构建生产版本

```bash
pnpm build
```

### 4. 预览生产版本

```bash
pnpm preview
```

## 项目结构

```
src/
├── api/                    # API 接口
│   ├── auth.ts            # 认证相关接口
│   └── prompt.ts          # 提示词相关接口
├── components/            # 公共组件
│   └── BindEmailDialog.vue # 绑定邮箱对话框
├── router/                # 路由配置
│   └── index.ts
├── stores/                # 状态管理
│   └── user.ts           # 用户状态
├── types/                 # TypeScript 类型
│   └── index.ts
├── utils/                 # 工具函数
│   ├── auth.ts           # Token 管理
│   └── request.ts        # Axios 封装
├── views/                 # 页面组件
│   ├── Login.vue         # 登录页
│   ├── Register.vue      # 注册页
│   ├── ResetPassword.vue # 找回密码页
│   ├── Home.vue          # 首页
│   ├── CreatePrompt.vue  # 创建提示词
│   ├── EditPrompt.vue    # 编辑提示词
│   ├── PromptDetail.vue  # 提示词详情
│   └── Profile.vue       # 个人中心
├── App.vue               # 根组件
└── main.ts               # 入口文件
```

## 页面路由

| 路径 | 页面 | 说明 |
|------|------|------|
| `/login` | 登录 | 用户登录 |
| `/register` | 注册 | 用户注册 |
| `/reset-password` | 找回密码 | 通过邮箱找回密码 |
| `/home` | 首页 | 提示词列表 |
| `/create` | 创建提示词 | 创建新提示词 |
| `/edit/:id` | 编辑提示词 | 编辑已有提示词 |
| `/prompt/:id` | 提示词详情 | 查看提示词详情 |
| `/profile` | 个人中心 | 查看个人信息和收藏 |

## 配置说明

### API 代理配置

在 `vite.config.ts` 中配置：

```typescript
server: {
  port: 3000,
  proxy: {
    '/api': {
      target: 'http://localhost:8080',  // 后端 API 地址
      changeOrigin: true
    }
  }
}
```

### 环境变量

复制 `.env.example` 为 `.env` 并修改：

```bash
cp .env.example .env
```

## 后端 API 要求

后端需要实现以下接口，详细文档请查看 `API.md`：

### 认证接口
- `POST /api/auth/register` - 注册
- `POST /api/auth/login` - 登录
- `POST /api/auth/logout` - 退出
- `POST /api/auth/send-code` - 发送验证码
- `POST /api/auth/reset-password` - 重置密码
- `POST /api/auth/bind-email` - 绑定邮箱
- `GET /api/auth/user` - 获取用户信息

### 提示词接口
- `GET /api/prompts` - 获取列表
- `POST /api/prompts` - 创建
- `GET /api/prompts/:id` - 获取详情
- `PUT /api/prompts/:id` - 更新
- `DELETE /api/prompts/:id` - 删除
- `POST /api/prompts/:id/like` - 点赞
- `DELETE /api/prompts/:id/like` - 取消点赞
- `POST /api/prompts/:id/collect` - 收藏
- `DELETE /api/prompts/:id/collect` - 取消收藏
- `GET /api/prompts/my` - 我的提示词
- `GET /api/prompts/my/likes` - 我的点赞
- `GET /api/prompts/my/collects` - 我的收藏
- `GET /api/prompts/statistics` - 统计数据

## 技术栈

- **Vue 3.4+** - 渐进式 JavaScript 框架
- **TypeScript 5.3+** - JavaScript 的超集
- **Vite 5.x** - 下一代前端构建工具
- **Element Plus 2.5+** - Vue 3 组件库
- **Vue Router 4.2+** - Vue 官方路由
- **Pinia 2.1+** - Vue 状态管理
- **Axios 1.6+** - HTTP 客户端
- **pnpm** - 快速的包管理器

## 主要特性

### 1. 自动导入

使用 `unplugin-auto-import` 和 `unplugin-vue-components`：

- Vue API 自动导入（ref, reactive, computed 等）
- Vue Router API 自动导入
- Pinia API 自动导入
- Element Plus 组件自动导入

### 2. 路由守卫

在 `src/router/index.ts` 中实现：

- 未登录用户访问需要认证的页面会跳转到登录页
- 自动获取用户信息

### 3. 请求拦截

在 `src/utils/request.ts` 中实现：

- 自动添加 Authorization 头
- 统一错误处理
- Token 过期自动跳转登录

### 4. 响应式布局

使用 CSS Media Query 实现：

- 桌面端：>768px
- 移动端：≤768px

## 开发建议

### 1. 代码规范

- 使用 TypeScript 类型定义
- 组件使用 `<script setup>` 语法
- 样式使用 scoped

### 2. 状态管理

- 全局状态使用 Pinia
- 组件状态使用 ref/reactive

### 3. API 调用

```typescript
import { getPrompts } from '@/api/prompt'

const fetchData = async () => {
  try {
    const res = await getPrompts({ page: 1, pageSize: 10 })
    console.log(res.data)
  } catch (error) {
    // 错误已在拦截器处理
  }
}
```

### 4. 路由跳转

```typescript
import { useRouter } from 'vue-router'

const router = useRouter()
router.push('/home')
```

## 常见问题

### Q: 如何修改 API 地址？

A: 在 `vite.config.ts` 中修改 proxy 配置。

### Q: 如何添加新页面？

A: 
1. 在 `src/views/` 创建页面组件
2. 在 `src/router/index.ts` 添加路由配置

### Q: 如何添加新的 API 接口？

A:
1. 在 `src/types/index.ts` 定义类型
2. 在 `src/api/` 对应文件中添加接口函数

### Q: Token 存储在哪里？

A: 使用 js-cookie 存储在 Cookie 中，有效期 30 天。

## 下一步

1. 启动后端 API 服务
2. 配置数据库和 Redis
3. 测试所有功能
4. 根据需求调整样式和功能

## 相关文档

- [API 接口文档](./API.md)
- [README](./README.md)
- [Element Plus 文档](https://element-plus.org/)
- [Vue 3 文档](https://cn.vuejs.org/)
- [Vite 文档](https://cn.vitejs.dev/)

## 联系方式

如有问题，请查看项目文档或提交 Issue。
