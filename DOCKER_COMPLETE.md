# 🐳 Docker 部署完整方案

## ✅ 已创建的 Docker 文件

### 核心文件
- ✅ `Dockerfile` - 生产环境镜像
- ✅ `Dockerfile.dev` - 开发环境镜像
- ✅ `docker-compose.yml` - 生产环境编排
- ✅ `docker-compose.dev.yml` - 开发环境编排
- ✅ `nginx.conf` - Nginx 配置
- ✅ `.dockerignore` - Docker 忽略文件
- ✅ `.env.docker` - 环境变量模板

### 管理脚本
- ✅ `docker-start.sh` - 启动服务
- ✅ `docker-stop.sh` - 停止服务
- ✅ `docker-logs.sh` - 查看日志
- ✅ `docker-backup.sh` - 备份数据
- ✅ `docker-restore.sh` - 恢复数据
- ✅ `docker-rebuild.sh` - 重建镜像

### 工具文件
- ✅ `Makefile` - Make 命令配置

### 文档
- ✅ `DOCKER.md` - 详细的 Docker 部署指南
- ✅ `DOCKER_QUICK_START.md` - 快速开始指南

---

## 🚀 快速开始

### 1. 准备环境

```bash
# 检查 Docker 是否安装
docker --version
docker-compose --version

# 如果未安装，请参考 DOCKER_QUICK_START.md
```

### 2. 配置环境变量

```bash
# 复制环境变量模板
cp .env.docker .env

# 编辑 .env 文件
vim .env
```

需要修改的配置：
- `DATABASE_PASSWORD` - 数据库密码
- `JWT_SECRET` - JWT 密钥
- `SMTP_*` - 邮件服务配置

### 3. 启动服务

#### 方式 A：使用脚本（最简单）

```bash
./docker-start.sh
```

然后选择：
- 1) 生产环境
- 2) 开发环境

#### 方式 B：使用 Make 命令

```bash
# 开发环境
make dev

# 生产环境
make prod

# 查看所有命令
make help
```

#### 方式 C：使用 Docker Compose

```bash
# 生产环境
docker-compose up -d

# 开发环境
docker-compose -f docker-compose.dev.yml up -d
```

### 4. 访问应用

- **生产环境**: http://localhost
- **开发环境**: http://localhost:3000
- **后端 API**: http://localhost:8080

---

## 📦 服务架构

```
┌─────────────────────────────────────────────────────────┐
│                      Docker Network                      │
│                                                          │
│  ┌──────────┐    ┌──────────┐    ┌──────────┐         │
│  │ Frontend │───▶│ Backend  │───▶│   DB     │         │
│  │  Nginx   │    │  API     │    │PostgreSQL│         │
│  │  :80     │    │  :8080   │    │  :5432   │         │
│  └──────────┘    └──────────┘    └──────────┘         │
│                        │                                 │
│                        ▼                                 │
│                  ┌──────────┐                           │
│                  │  Redis   │                           │
│                  │  :6379   │                           │
│                  └──────────┘                           │
└─────────────────────────────────────────────────────────┘
```

### 服务说明

| 服务 | 容器名 | 端口 | 说明 |
|------|--------|------|------|
| frontend | prompt-manager-frontend | 80 | Nginx + 前端静态文件 |
| backend | prompt-manager-backend | 8080 | 后端 API 服务 |
| db | prompt-manager-db | 5432 | PostgreSQL 数据库 |
| redis | prompt-manager-redis | 6379 | Redis 缓存 |

---

## 🛠️ 常用操作

### 查看状态

```bash
# 查看运行状态
docker-compose ps

# 查看资源使用
docker stats

# 使用 Make
make status
```

### 查看日志

```bash
# 使用脚本
./docker-logs.sh

# 使用 Make
make prod-logs    # 生产环境
make dev-logs     # 开发环境

# 使用 Docker Compose
docker-compose logs -f
docker-compose logs -f frontend  # 特定服务
```

### 停止服务

```bash
# 使用脚本
./docker-stop.sh

# 使用 Make
make prod-stop
make dev-stop

# 使用 Docker Compose
docker-compose stop
```

### 重启服务

```bash
# 使用 Make
make restart

# 使用 Docker Compose
docker-compose restart
docker-compose restart frontend  # 特定服务
```

### 进入容器

```bash
# 使用 Make
make shell-frontend
make shell-backend
make shell-db
make shell-redis

# 使用 Docker Compose
docker-compose exec frontend sh
docker-compose exec backend sh
docker-compose exec db psql -U postgres -d prompt_manager
docker-compose exec redis redis-cli
```

---

## 💾 数据管理

### 备份数据

```bash
# 使用脚本（推荐）
./docker-backup.sh

# 使用 Make
make backup
```

备份文件保存在 `backups/` 目录，格式：`YYYYMMDD_HHMMSS.tar.gz`

### 恢复数据

```bash
# 使用脚本
./docker-restore.sh backups/20240101_120000.tar.gz

# 使用 Make
make restore
# 然后输入备份文件路径
```

### 手动备份

```bash
# 备份数据库
docker-compose exec -T db pg_dump -U postgres prompt_manager > backup.sql

# 备份 Redis
docker-compose exec redis redis-cli SAVE
docker cp prompt-manager-redis:/data/dump.rdb ./redis-backup.rdb
```

---

## 🔄 更新和维护

### 更新代码

```bash
# 1. 拉取最新代码
git pull

# 2. 重新构建（使用脚本）
./docker-rebuild.sh

# 或使用 Make
make rebuild

# 或使用 Docker Compose
docker-compose build --no-cache
docker-compose up -d
```

### 清理资源

```bash
# 停止并删除容器
docker-compose down

# 停止并删除容器和数据卷（⚠️ 会删除所有数据）
docker-compose down -v

# 使用 Make
make clean        # 删除容器
make clean-all    # 删除容器和数据卷

# 清理未使用的镜像
docker image prune -a

# 清理所有未使用的资源
docker system prune -a
```

---

## 🔍 故障排查

### 1. 容器无法启动

```bash
# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs frontend

# 检查配置
docker-compose config

# 重新构建
docker-compose build --no-cache
docker-compose up -d
```

### 2. 端口被占用

```bash
# 查看端口占用
lsof -i :80
lsof -i :3000
lsof -i :8080

# 修改端口
# 编辑 docker-compose.yml，修改 ports 配置
```

### 3. 数据库连接失败

```bash
# 检查数据库状态
docker-compose exec db pg_isready

# 查看数据库日志
docker-compose logs db

# 测试连接
docker-compose exec backend psql -h db -U postgres -d prompt_manager

# 重启数据库
docker-compose restart db
```

### 4. 前端无法访问后端

```bash
# 检查网络连接
docker-compose exec frontend ping backend

# 检查 Nginx 配置
docker-compose exec frontend cat /etc/nginx/conf.d/default.conf

# 重启前端
docker-compose restart frontend
```

### 5. Redis 连接失败

```bash
# 检查 Redis 状态
docker-compose exec redis redis-cli ping

# 查看 Redis 日志
docker-compose logs redis

# 重启 Redis
docker-compose restart redis
```

---

## 🎯 生产环境部署

### 1. 修改配置

#### 修改域名

编辑 `nginx.conf`：

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 修改为你的域名
    # ...
}
```

#### 修改后端地址

如果后端不在同一个 Docker 网络中，修改 `nginx.conf`：

```nginx
location /api {
    proxy_pass http://your-backend-url:8080;  # 修改为实际地址
    # ...
}
```

### 2. 配置 HTTPS

#### 使用 Let's Encrypt

```bash
# 安装 Certbot
sudo apt-get install certbot

# 获取证书
sudo certbot certonly --standalone -d your-domain.com

# 证书位置
# /etc/letsencrypt/live/your-domain.com/fullchain.pem
# /etc/letsencrypt/live/your-domain.com/privkey.pem
```

#### 修改 Nginx 配置

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # ...其他配置
}

server {
    listen 80;
    server_name your-domain.com;
    return 301 https://$server_name$request_uri;
}
```

#### 挂载证书到容器

修改 `docker-compose.yml`：

```yaml
services:
  frontend:
    volumes:
      - /etc/letsencrypt:/etc/letsencrypt:ro
    ports:
      - "80:80"
      - "443:443"
```

### 3. 安全配置

#### 修改默认密码

编辑 `.env` 文件：

```bash
# 使用强密码
DATABASE_PASSWORD=your_strong_password_here
JWT_SECRET=your_random_jwt_secret_key_here
```

#### 限制资源

编辑 `docker-compose.yml`：

```yaml
services:
  frontend:
    deploy:
      resources:
        limits:
          cpus: '0.5'
          memory: 512M
        reservations:
          cpus: '0.25'
          memory: 256M
```

#### 配置日志

```yaml
services:
  frontend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### 4. 监控配置

#### 健康检查

```yaml
services:
  frontend:
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

---

## 📊 性能优化

### 1. Nginx 优化

编辑 `nginx.conf`：

```nginx
# 启用 Gzip 压缩
gzip on;
gzip_comp_level 6;
gzip_types text/plain text/css application/json application/javascript;

# 静态资源缓存
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    expires 1y;
    add_header Cache-Control "public, immutable";
}

# 连接优化
keepalive_timeout 65;
keepalive_requests 100;
```

### 2. 数据库优化

```yaml
services:
  db:
    command:
      - "postgres"
      - "-c"
      - "max_connections=200"
      - "-c"
      - "shared_buffers=256MB"
```

### 3. Redis 优化

```yaml
services:
  redis:
    command: redis-server --maxmemory 256mb --maxmemory-policy allkeys-lru
```

---

## 📝 最佳实践

### 1. 使用 .env 文件

不要在配置文件中硬编码敏感信息。

### 2. 定期备份

```bash
# 设置定时任务
crontab -e

# 每天凌晨 2 点备份
0 2 * * * cd /path/to/project && ./docker-backup.sh
```

### 3. 监控日志

```bash
# 定期检查日志
docker-compose logs --tail=100 frontend
docker-compose logs --tail=100 backend
```

### 4. 更新镜像

```bash
# 定期更新基础镜像
docker-compose pull
docker-compose up -d
```

### 5. 安全更新

```bash
# 定期更新依赖
pnpm update
docker-compose build --no-cache
```

---

## 🎉 总结

### 优势

- ✅ **一键部署** - 使用脚本或 Make 命令快速部署
- ✅ **环境一致** - 开发、测试、生产环境完全一致
- ✅ **易于管理** - 统一的管理脚本和命令
- ✅ **数据安全** - 自动备份和恢复功能
- ✅ **易于扩展** - 轻松添加新服务
- ✅ **隔离性好** - 服务之间相互隔离

### 文件清单

- [x] Dockerfile（生产环境）
- [x] Dockerfile.dev（开发环境）
- [x] docker-compose.yml（生产环境）
- [x] docker-compose.dev.yml（开发环境）
- [x] nginx.conf（Nginx 配置）
- [x] .dockerignore（忽略文件）
- [x] .env.docker（环境变量模板）
- [x] Makefile（Make 命令）
- [x] 6 个管理脚本
- [x] 2 个文档文件

### 下一步

1. 安装 Docker 和 Docker Compose
2. 配置 .env 文件
3. 运行 `./docker-start.sh` 启动服务
4. 访问 http://localhost 查看效果

---

## 📞 获取帮助

### 查看文档

- **快速开始**: DOCKER_QUICK_START.md
- **详细指南**: DOCKER.md
- **项目说明**: README.md

### 常用命令

```bash
# 查看所有 Make 命令
make help

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f

# 进入容器
docker-compose exec frontend sh
```

---

**Docker 部署方案已完成！** 🎊

所有文件都已创建，可以直接使用！
