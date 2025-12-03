# 部署指南

## 生产环境部署

### 方式一：使用 Nginx

#### 1. 构建项目

```bash
pnpm build
```

构建完成后，会在 `dist` 目录生成静态文件。

#### 2. 配置 Nginx

创建 Nginx 配置文件 `/etc/nginx/sites-available/prompt-manager`:

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 替换为你的域名
    
    root /var/www/prompt-manager/dist;
    index index.html;
    
    # Gzip 压缩
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;
    
    # 静态资源缓存
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    # API 代理
    location /api {
        proxy_pass http://localhost:8080;  # 后端 API 地址
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # SPA 路由支持
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

#### 3. 启用配置

```bash
# 创建软链接
sudo ln -s /etc/nginx/sites-available/prompt-manager /etc/nginx/sites-enabled/

# 测试配置
sudo nginx -t

# 重启 Nginx
sudo systemctl restart nginx
```

#### 4. 上传文件

```bash
# 上传 dist 目录到服务器
scp -r dist/* user@your-server:/var/www/prompt-manager/dist/
```

---

### 方式二：使用 Docker

#### 1. 创建 Dockerfile

在项目根目录创建 `Dockerfile`:

```dockerfile
# 构建阶段
FROM node:18-alpine as builder

WORKDIR /app

# 安装 pnpm
RUN npm install -g pnpm

# 复制依赖文件
COPY package.json pnpm-lock.yaml ./

# 安装依赖
RUN pnpm install --frozen-lockfile

# 复制源代码
COPY . .

# 构建
RUN pnpm build

# 生产阶段
FROM nginx:alpine

# 复制构建产物
COPY --from=builder /app/dist /usr/share/nginx/html

# 复制 Nginx 配置
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### 2. 创建 nginx.conf

```nginx
server {
    listen 80;
    server_name localhost;
    
    root /usr/share/nginx/html;
    index index.html;
    
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml+rss application/javascript application/json;
    
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg|woff|woff2|ttf|eot)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
    
    location /api {
        proxy_pass http://backend:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
    
    location / {
        try_files $uri $uri/ /index.html;
    }
}
```

#### 3. 创建 docker-compose.yml

```yaml
version: '3.8'

services:
  frontend:
    build: .
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - app-network

  backend:
    image: your-backend-image:latest
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://user:password@db:5432/prompt_manager
      - REDIS_URL=redis://redis:6379
    depends_on:
      - db
      - redis
    networks:
      - app-network

  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=prompt_manager
      - POSTGRES_USER=user
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres-data:/var/lib/postgresql/data
    networks:
      - app-network

  redis:
    image: redis:7-alpine
    volumes:
      - redis-data:/data
    networks:
      - app-network

volumes:
  postgres-data:
  redis-data:

networks:
  app-network:
    driver: bridge
```

#### 4. 构建和运行

```bash
# 构建镜像
docker-compose build

# 启动服务
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

---

### 方式三：使用 Vercel

#### 1. 安装 Vercel CLI

```bash
npm install -g vercel
```

#### 2. 登录 Vercel

```bash
vercel login
```

#### 3. 部署

```bash
vercel
```

#### 4. 配置环境变量

在 Vercel 控制台配置：
- `VITE_API_BASE_URL`: 后端 API 地址

#### 5. 配置 vercel.json

```json
{
  "rewrites": [
    {
      "source": "/api/:path*",
      "destination": "https://your-backend-api.com/api/:path*"
    },
    {
      "source": "/(.*)",
      "destination": "/index.html"
    }
  ]
}
```

---

### 方式四：使用 Netlify

#### 1. 创建 netlify.toml

```toml
[build]
  command = "pnpm build"
  publish = "dist"

[[redirects]]
  from = "/api/*"
  to = "https://your-backend-api.com/api/:splat"
  status = 200

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

#### 2. 部署

方式 1：通过 Git 连接
- 在 Netlify 控制台连接 Git 仓库
- 自动部署

方式 2：使用 CLI
```bash
# 安装 CLI
npm install -g netlify-cli

# 登录
netlify login

# 部署
netlify deploy --prod
```

---

## 环境变量配置

### 开发环境 (.env.development)

```bash
VITE_API_BASE_URL=http://localhost:8080
```

### 生产环境 (.env.production)

```bash
VITE_API_BASE_URL=https://api.your-domain.com
```

### 使用环境变量

在 `vite.config.ts` 中：

```typescript
import { defineConfig, loadEnv } from 'vite'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd())
  
  return {
    // ...其他配置
    server: {
      proxy: {
        '/api': {
          target: env.VITE_API_BASE_URL,
          changeOrigin: true
        }
      }
    }
  }
})
```

---

## 性能优化

### 1. 代码分割

已通过路由懒加载实现：

```typescript
{
  path: '/home',
  component: () => import('@/views/Home.vue')
}
```

### 2. 资源压缩

在 `vite.config.ts` 中配置：

```typescript
export default defineConfig({
  build: {
    minify: 'terser',
    terserOptions: {
      compress: {
        drop_console: true,
        drop_debugger: true
      }
    },
    rollupOptions: {
      output: {
        manualChunks: {
          'element-plus': ['element-plus'],
          'vue-vendor': ['vue', 'vue-router', 'pinia']
        }
      }
    }
  }
})
```

### 3. CDN 加速

使用 CDN 加载第三方库：

```html
<!-- index.html -->
<script src="https://cdn.jsdelivr.net/npm/vue@3/dist/vue.global.prod.js"></script>
```

配置 external：

```typescript
export default defineConfig({
  build: {
    rollupOptions: {
      external: ['vue'],
      output: {
        globals: {
          vue: 'Vue'
        }
      }
    }
  }
})
```

---

## SSL 证书配置

### 使用 Let's Encrypt

```bash
# 安装 Certbot
sudo apt-get install certbot python3-certbot-nginx

# 获取证书
sudo certbot --nginx -d your-domain.com

# 自动续期
sudo certbot renew --dry-run
```

### Nginx SSL 配置

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    
    # ...其他配置
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 监控和日志

### 1. Nginx 访问日志

```nginx
access_log /var/log/nginx/prompt-manager-access.log;
error_log /var/log/nginx/prompt-manager-error.log;
```

### 2. 前端错误监控

集成 Sentry：

```bash
pnpm add @sentry/vue
```

```typescript
// main.ts
import * as Sentry from '@sentry/vue'

Sentry.init({
  app,
  dsn: 'your-sentry-dsn',
  environment: import.meta.env.MODE
})
```

### 3. 性能监控

使用 Google Analytics 或其他分析工具。

---

## 备份策略

### 1. 数据库备份

```bash
# PostgreSQL 备份
pg_dump -U user prompt_manager > backup.sql

# 恢复
psql -U user prompt_manager < backup.sql
```

### 2. Redis 备份

```bash
# 备份
redis-cli SAVE

# 复制 RDB 文件
cp /var/lib/redis/dump.rdb /backup/
```

### 3. 代码备份

使用 Git 版本控制，定期推送到远程仓库。

---

## 故障排查

### 1. 页面空白

- 检查 Nginx 配置
- 检查文件路径
- 查看浏览器控制台错误

### 2. API 请求失败

- 检查代理配置
- 检查后端服务状态
- 查看网络请求

### 3. 路由 404

- 确保配置了 `try_files`
- 检查 SPA 路由配置

### 4. 静态资源加载失败

- 检查文件路径
- 检查 Nginx 配置
- 查看浏览器网络面板

---

## 安全建议

### 1. 隐藏 Nginx 版本

```nginx
http {
    server_tokens off;
}
```

### 2. 限制请求大小

```nginx
client_max_body_size 10M;
```

### 3. 防止 DDoS

```nginx
limit_req_zone $binary_remote_addr zone=one:10m rate=10r/s;
limit_req zone=one burst=20;
```

### 4. 添加安全头

```nginx
add_header X-Frame-Options "SAMEORIGIN";
add_header X-Content-Type-Options "nosniff";
add_header X-XSS-Protection "1; mode=block";
add_header Referrer-Policy "no-referrer-when-downgrade";
```

---

## 持续集成/持续部署 (CI/CD)

### GitHub Actions 示例

创建 `.github/workflows/deploy.yml`:

```yaml
name: Deploy

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Install pnpm
      run: npm install -g pnpm
    
    - name: Install dependencies
      run: pnpm install
    
    - name: Build
      run: pnpm build
    
    - name: Deploy to Server
      uses: easingthemes/ssh-deploy@main
      env:
        SSH_PRIVATE_KEY: ${{ secrets.SSH_PRIVATE_KEY }}
        REMOTE_HOST: ${{ secrets.REMOTE_HOST }}
        REMOTE_USER: ${{ secrets.REMOTE_USER }}
        TARGET: /var/www/prompt-manager/dist
        SOURCE: dist/
```

---

## 总结

选择合适的部署方式：

- **小型项目**：Vercel 或 Netlify（简单快速）
- **中型项目**：Nginx + 服务器（灵活可控）
- **大型项目**：Docker + Kubernetes（可扩展）

确保：
- ✅ 配置正确的 API 代理
- ✅ 启用 HTTPS
- ✅ 配置 Gzip 压缩
- ✅ 设置静态资源缓存
- ✅ 配置 SPA 路由支持
- ✅ 添加监控和日志
- ✅ 定期备份数据
