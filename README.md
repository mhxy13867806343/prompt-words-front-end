# 提示词管理系统

基于 Vue 3 + TypeScript + Vite + Element Plus 的提示词管理系统。

## 仓库地址

`https://github.com/mhxy13867806343/prompt-words-front-end.git`

## 多语言

- [中文](.md)
- [English](em.md)
- [日本語](日本.md)

## 功能特性

### 用户认证
- ✅ 用户注册/登录
- ✅ 找回密码（需绑定邮箱）
- ✅ 邮箱绑定（验证码 5 分钟有效，使用 Redis）
- ✅ Token 认证（30 天有效期）
- ✅ 退出登录

### 提示词管理
- ✅ 创建提示词（标题最多 200 字，内容最多 30000 字）
- ✅ 编辑提示词（仅自己的）
- ✅ 删除提示词（软删除，state=0）
- ✅ 查看提示词详情
- ✅ 搜索提示词

### 互动功能
- ✅ 点赞/取消点赞（不能对自己的提示词操作）
- ✅ 收藏/取消收藏（不能对自己的提示词操作）
- ✅ 浏览计数（限 IP）
- ✅ 分享链接
- ✅ 复制内容

### 个人中心
- ✅ 查看我的提示词
- ✅ 查看我的点赞
- ✅ 查看我的收藏
- ✅ 邮箱绑定状态提示

### 全局统计
- ✅ 总提示词数量
- ✅ 总浏览量

### 其他特性
- ✅ 响应式设计（支持移动端）
- ✅ 分页功能
- ✅ 统一的 API 响应格式

## 技术栈

- **框架**: Vue 3.4+
- **语言**: TypeScript 5.3+
- **构建工具**: Vite 5.x
- **UI 框架**: Element Plus 2.5+
- **路由**: Vue Router 4.2+
- **状态管理**: Pinia 2.1+
- **HTTP 客户端**: Axios 1.6+
- **包管理器**: pnpm

## 项目结构

```
├── src/
│   ├── api/              # API 接口
│   │   ├── auth.ts       # 认证相关
│   │   └── prompt.ts     # 提示词相关
│   ├── components/       # 公共组件
│   │   └── BindEmailDialog.vue
│   ├── router/           # 路由配置
│   │   └── index.ts
│   ├── stores/           # 状态管理
│   │   └── user.ts
│   ├── types/            # TypeScript 类型定义
│   │   └── index.ts
│   ├── utils/            # 工具函数
│   │   ├── auth.ts       # Token 管理
│   │   └── request.ts    # Axios 封装
│   ├── views/            # 页面组件
│   │   ├── Login.vue
│   │   ├── Register.vue
│   │   ├── ResetPassword.vue
│   │   ├── Home.vue
│   │   ├── CreatePrompt.vue
│   │   ├── EditPrompt.vue
│   │   ├── PromptDetail.vue
│   │   └── Profile.vue
│   ├── App.vue
│   └── main.ts
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
└── README.md
```

## 开始使用

### 方式一：本地开发

#### 安装依赖

```bash
pnpm install
```

#### 开发模式

```bash
pnpm dev
```

访问 http://localhost:3000

#### 构建生产版本

```bash
pnpm build
```

#### 预览生产版本

```bash
pnpm preview
```

### 方式二：Docker 部署（推荐）

#### 快速启动

```bash
# 使用脚本启动
./docker-start.sh

# 或使用 Make 命令
make dev      # 开发环境
make prod     # 生产环境
```

#### Docker Compose

```bash
# 启动所有服务（前端 + 后端 + 数据库 + Redis）
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose stop
```

详细的 Docker 部署说明请查看 [DOCKER.md](./DOCKER.md)

## API 接口说明

### 响应格式

所有 API 响应遵循统一格式：

```typescript
{
  code: 200,
  data: {
    list: [],
    // ...其他参数
  },
  msg: '成功'
}
```

### 后端 API 端点

需要配置后端 API 服务，默认代理到 `http://localhost:8080`

#### 认证相关
- `POST /api/auth/register` - 注册
- `POST /api/auth/login` - 登录
- `POST /api/auth/logout` - 退出
- `POST /api/auth/send-code` - 发送邮箱验证码
- `POST /api/auth/reset-password` - 重置密码
- `POST /api/auth/bind-email` - 绑定邮箱
- `GET /api/auth/user` - 获取用户信息

#### 提示词相关
- `GET /api/prompts` - 获取提示词列表（分页、搜索）
- `POST /api/prompts` - 创建提示词
- `GET /api/prompts/:id` - 获取提示词详情
- `PUT /api/prompts/:id` - 更新提示词
- `DELETE /api/prompts/:id` - 删除提示词（软删除）
- `POST /api/prompts/:id/like` - 点赞
- `DELETE /api/prompts/:id/like` - 取消点赞
- `POST /api/prompts/:id/collect` - 收藏
- `DELETE /api/prompts/:id/collect` - 取消收藏
- `GET /api/prompts/my` - 我的提示词
- `GET /api/prompts/my/likes` - 我的点赞
- `GET /api/prompts/my/collects` - 我的收藏
- `GET /api/prompts/statistics` - 统计数据

## 配置说明

### Vite 配置

在 `vite.config.ts` 中配置：

- 端口：默认 3000
- API 代理：`/api` 代理到 `http://localhost:8080`
- 路径别名：`@` 指向 `src` 目录

### 自动导入

使用 `unplugin-auto-import` 和 `unplugin-vue-components` 实现：

- Vue API 自动导入
- Vue Router API 自动导入
- Pinia API 自动导入
- Element Plus 组件自动导入

## 注意事项

1. **邮箱验证码**：验证码在 Redis 中存储，5 分钟有效期
2. **Token 有效期**：登录 Token 有效期为 30 天
3. **软删除**：删除提示词时 `state` 设为 0，不是真正删除
4. **邮箱绑定**：未绑定邮箱的用户无法找回密码
5. **互动限制**：用户不能对自己的提示词进行点赞、收藏操作
6. **浏览计数**：基于 IP 限制，避免重复计数

## 响应式设计

项目支持响应式布局，适配：
- 桌面端（>768px）
- 移动端（≤768px）

## License

MIT
