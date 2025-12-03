# API 接口文档

## 通用说明

### 请求头

```
Authorization: Bearer {token}
Content-Type: application/json
```

### 响应格式

所有接口统一返回格式：

```json
{
  "code": 200,
  "data": {},
  "msg": "成功"
}
```

### 状态码

- `200`: 成功
- `401`: 未授权（token 无效或过期）
- `403`: 禁止访问
- `404`: 资源不存在
- `500`: 服务器错误

---

## 认证相关接口

### 1. 用户注册

**接口**: `POST /api/auth/register`

**请求参数**:
```json
{
  "username": "string (3-20字符)",
  "password": "string (6-20字符)",
  "confirmPassword": "string"
}
```

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "token": "string (JWT token, 30天有效期)",
    "user": {
      "id": "number",
      "username": "string",
      "email": "string | null",
      "state": "number (0: 未绑定邮箱, >0: 已绑定)",
      "createdAt": "string (ISO 8601)"
    }
  },
  "msg": "注册成功"
}
```

---

### 2. 用户登录

**接口**: `POST /api/auth/login`

**请求参数**:
```json
{
  "username": "string",
  "password": "string"
}
```

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "token": "string (JWT token, 30天有效期)",
    "user": {
      "id": "number",
      "username": "string",
      "email": "string | null",
      "state": "number (0: 未绑定邮箱, >0: 已绑定)",
      "createdAt": "string"
    }
  },
  "msg": "登录成功"
}
```

---

### 3. 发送邮箱验证码

**接口**: `POST /api/auth/send-code`

**请求参数**:
```json
{
  "email": "string (邮箱地址)"
}
```

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "验证码已发送"
}
```

**说明**:
- 验证码存储在 Redis 中，有效期 5 分钟
- 同一邮箱 60 秒内只能发送一次

---

### 4. 重置密码

**接口**: `POST /api/auth/reset-password`

**请求参数**:
```json
{
  "email": "string",
  "code": "string (验证码)",
  "newPassword": "string (6-20字符)",
  "confirmPassword": "string"
}
```

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "密码重置成功"
}
```

**说明**:
- 需要验证邮箱验证码
- 只有绑定了邮箱的用户才能找回密码

---

### 5. 绑定邮箱

**接口**: `POST /api/auth/bind-email`

**请求头**: 需要 Authorization

**请求参数**:
```json
{
  "email": "string",
  "code": "string (验证码)"
}
```

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "邮箱绑定成功"
}
```

**说明**:
- 绑定成功后，用户的 state 字段会更新为 >0

---

### 6. 获取用户信息

**接口**: `GET /api/auth/user`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "id": "number",
    "username": "string",
    "email": "string | null",
    "state": "number",
    "createdAt": "string"
  },
  "msg": "成功"
}
```

---

### 7. 退出登录

**接口**: `POST /api/auth/logout`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "退出成功"
}
```

**说明**:
- 可以在服务端将 token 加入黑名单

---

## 提示词相关接口

### 8. 获取提示词列表

**接口**: `GET /api/prompts`

**请求头**: 需要 Authorization

**查询参数**:
- `page`: number (页码，从 1 开始)
- `pageSize`: number (每页数量)
- `keyword`: string (可选，搜索关键词)

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "list": [
      {
        "id": "number",
        "title": "string",
        "content": "string",
        "userId": "number",
        "username": "string",
        "state": "number (0: 已删除, 1: 正常)",
        "viewCount": "number",
        "likeCount": "number",
        "collectCount": "number",
        "isLiked": "boolean (当前用户是否点赞)",
        "isCollected": "boolean (当前用户是否收藏)",
        "createdAt": "string",
        "updatedAt": "string"
      }
    ],
    "total": "number",
    "page": "number",
    "pageSize": "number"
  },
  "msg": "成功"
}
```

**说明**:
- 只返回 state=1 的提示词
- 如果是自己的提示词，isLiked 和 isCollected 为 false

---

### 9. 创建提示词

**接口**: `POST /api/prompts`

**请求头**: 需要 Authorization

**请求参数**:
```json
{
  "title": "string (最多200字)",
  "content": "string (最多30000字)"
}
```

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "id": "number",
    "title": "string",
    "content": "string",
    "userId": "number",
    "username": "string",
    "state": 1,
    "viewCount": 0,
    "likeCount": 0,
    "collectCount": 0,
    "createdAt": "string",
    "updatedAt": "string"
  },
  "msg": "创建成功"
}
```

---

### 10. 获取提示词详情

**接口**: `GET /api/prompts/:id`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "id": "number",
    "title": "string",
    "content": "string",
    "userId": "number",
    "username": "string",
    "state": "number",
    "viewCount": "number",
    "likeCount": "number",
    "collectCount": "number",
    "isLiked": "boolean",
    "isCollected": "boolean",
    "createdAt": "string",
    "updatedAt": "string"
  },
  "msg": "成功"
}
```

**说明**:
- 访问时需要增加浏览量（基于 IP 限制，同一 IP 24小时内只计数一次）
- 如果是自己的提示词，isLiked 和 isCollected 为 false

---

### 11. 更新提示词

**接口**: `PUT /api/prompts/:id`

**请求头**: 需要 Authorization

**请求参数**:
```json
{
  "title": "string (最多200字)",
  "content": "string (最多30000字)"
}
```

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "id": "number",
    "title": "string",
    "content": "string",
    "userId": "number",
    "username": "string",
    "state": "number",
    "viewCount": "number",
    "likeCount": "number",
    "collectCount": "number",
    "createdAt": "string",
    "updatedAt": "string"
  },
  "msg": "更新成功"
}
```

**说明**:
- 只能更新自己的提示词

---

### 12. 删除提示词

**接口**: `DELETE /api/prompts/:id`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "删除成功"
}
```

**说明**:
- 软删除，将 state 设为 0
- 只能删除自己的提示词

---

### 13. 点赞提示词

**接口**: `POST /api/prompts/:id/like`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "点赞成功"
}
```

**说明**:
- 不能对自己的提示词点赞
- 重复点赞返回错误

---

### 14. 取消点赞

**接口**: `DELETE /api/prompts/:id/like`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "取消点赞成功"
}
```

---

### 15. 收藏提示词

**接口**: `POST /api/prompts/:id/collect`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "收藏成功"
}
```

**说明**:
- 不能收藏自己的提示词
- 重复收藏返回错误

---

### 16. 取消收藏

**接口**: `DELETE /api/prompts/:id/collect`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": null,
  "msg": "取消收藏成功"
}
```

---

### 17. 获取我的提示词

**接口**: `GET /api/prompts/my`

**请求头**: 需要 Authorization

**查询参数**:
- `page`: number
- `pageSize`: number

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "list": [...],
    "total": "number",
    "page": "number",
    "pageSize": "number"
  },
  "msg": "成功"
}
```

**说明**:
- 返回当前用户创建的所有提示词（包括 state=0 的）

---

### 18. 获取我的点赞

**接口**: `GET /api/prompts/my/likes`

**请求头**: 需要 Authorization

**查询参数**:
- `page`: number
- `pageSize`: number

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "list": [...],
    "total": "number",
    "page": "number",
    "pageSize": "number"
  },
  "msg": "成功"
}
```

**说明**:
- 返回当前用户点赞的所有提示词（只包括 state=1 的）

---

### 19. 获取我的收藏

**接口**: `GET /api/prompts/my/collects`

**请求头**: 需要 Authorization

**查询参数**:
- `page`: number
- `pageSize`: number

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "list": [...],
    "total": "number",
    "page": "number",
    "pageSize": "number"
  },
  "msg": "成功"
}
```

**说明**:
- 返回当前用户收藏的所有提示词（只包括 state=1 的）

---

### 20. 获取统计数据

**接口**: `GET /api/prompts/statistics`

**请求头**: 需要 Authorization

**响应数据**:
```json
{
  "code": 200,
  "data": {
    "totalPrompts": "number (总提示词数，state=1)",
    "totalViews": "number (总浏览量)"
  },
  "msg": "成功"
}
```

---

## 数据库设计建议

### users 表
```sql
CREATE TABLE users (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(20) UNIQUE NOT NULL,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) UNIQUE,
  state TINYINT DEFAULT 0 COMMENT '0: 未绑定邮箱, 1: 已绑定',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
```

### prompts 表
```sql
CREATE TABLE prompts (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  title VARCHAR(200) NOT NULL,
  content TEXT NOT NULL,
  user_id BIGINT NOT NULL,
  state TINYINT DEFAULT 1 COMMENT '0: 已删除, 1: 正常',
  view_count INT DEFAULT 0,
  like_count INT DEFAULT 0,
  collect_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (user_id) REFERENCES users(id)
);
```

### likes 表
```sql
CREATE TABLE likes (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  prompt_id BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_prompt (user_id, prompt_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (prompt_id) REFERENCES prompts(id)
);
```

### collects 表
```sql
CREATE TABLE collects (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  user_id BIGINT NOT NULL,
  prompt_id BIGINT NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_user_prompt (user_id, prompt_id),
  FOREIGN KEY (user_id) REFERENCES users(id),
  FOREIGN KEY (prompt_id) REFERENCES prompts(id)
);
```

### prompt_views 表（用于限制 IP 浏览计数）
```sql
CREATE TABLE prompt_views (
  id BIGINT PRIMARY KEY AUTO_INCREMENT,
  prompt_id BIGINT NOT NULL,
  ip_address VARCHAR(45) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_prompt_ip (prompt_id, ip_address),
  FOREIGN KEY (prompt_id) REFERENCES prompts(id)
);
```

### Redis 数据结构

#### 邮箱验证码
```
key: email_code:{email}
value: {code}
expire: 300 (5分钟)
```

#### Token 黑名单（可选）
```
key: token_blacklist:{token}
value: 1
expire: 2592000 (30天)
```

---

## 注意事项

1. **密码加密**: 使用 bcrypt 或类似算法加密存储
2. **JWT Token**: 包含 userId, username 等信息，设置 30 天过期
3. **邮箱验证码**: 6 位数字，存储在 Redis，5 分钟有效
4. **浏览计数**: 基于 IP 地址，24 小时内同一 IP 只计数一次
5. **软删除**: 删除提示词时只修改 state 字段，不真正删除数据
6. **权限控制**: 
   - 只能编辑/删除自己的提示词
   - 不能对自己的提示词点赞/收藏
7. **数据验证**: 
   - 标题最多 200 字
   - 内容最多 30000 字
   - 用户名 3-20 字符
   - 密码 6-20 字符
