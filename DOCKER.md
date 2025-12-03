# Docker 部署指南

## 📦 Docker 部署方式

### 方式一：使用 Docker Compose（推荐）

这是最简单的部署方式，会自动启动前端、后端、数据库和 Redis。

#### 1. 准备工作

确保已安装：
- Docker (20.10+)
- Docker Compose (2.0+)

```bash
# 检查版本
docker --version
docker-compose --version
```

#### 2. 配置环境变量

复制并编辑环境变量文件：

```bash
cp .env.docker .env
```

编辑 `.env` 文件，修改以下配置：
- 数据库密码
- JWT 密钥
- 邮件配置

#### 3. 启动所有服务

```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 查看运行状态
docker-compose ps
```

#### 4. 访问应用

- 前端：http://localhost
- 后端 API：http://localhost:8080
- 数据库：localhost:5432
- Redis：localhost:6379

#### 5. 停止服务

```bash
# 停止服务
docker-compose stop

# 停止并删除容器
docker-compose down

# 停止并删除容器和数据卷
docker-compose down -v
```

---

### 方式二：仅部署前端

如果后端已经部署在其他地方，只需要部署前端。

#### 1. 修改 Nginx 配置

编辑 `nginx.conf`，修改后端地址：

```nginx
location /api {
    proxy_pass http://your-backend-url:8080;  # 修改为实际后端地址
    # ...
}
```

#### 2. 构建镜像

```bash
docker build -t prompt-manager-frontend .
```

#### 3. 运行容器

```bash
docker run -d \
  --name prompt-manager-frontend \
  -p 80:80 \
  prompt-manager-frontend
```

#### 4. 查看日志

```bash
docker logs -f prompt-manager-frontend
```

---

### 方式三：开发环境

使用 Docker 运行开发环境。

#### 1. 启动开发环境

```bash
docker-compose -f docker-compose.dev.yml up -d
```

#### 2. 访问

- 前端开发服务器：http://localhost:3000
- 支持热更新

#### 3. 停止

```bash
docker-compose -f docker-compose.dev.yml down
```

---

## 🔧 配置说明

### docker-compose.yml 配置

```yaml
services:
  frontend:    # 前端服务
  backend:     # 后端服务
  db:          # PostgreSQL 数据库
  redis:       # Redis 缓存
```

### 端口映射

| 服务 | 容器端口 | 主机端口 |
|------|---------|---------|
| 前端 | 80 | 80 |
| 后端 | 8080 | 8080 |
| 数据库 | 5432 | 5432 |
| Redis | 6379 | 6379 |

### 数据持久化

数据卷：
- `postgres-data`: PostgreSQL 数据
- `redis-data`: Redis 数据

查看数据卷：
```bash
docker volume ls
```

备份数据卷：
```bash
docker run --rm -v postgres-data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-backup.tar.gz /data
```

---

## 🚀 生产环境部署

### 1. 使用自定义域名

修改 `nginx.conf`：

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 修改为你的域名
    # ...
}
```

### 2. 配置 HTTPS

创建 `docker-compose.prod.yml`：

```yaml
version: '3.8'

services:
  frontend:
    build: .
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./ssl:/etc/nginx/ssl
    environment:
      - DOMAIN=your-domain.com
```

添加 SSL 证书到 `ssl` 目录。

### 3. 使用 Traefik 反向代理

```yaml
version: '3.8'

services:
  traefik:
    image: traefik:v2.10
    command:
      - "--api.insecure=true"
      - "--providers.docker=true"
      - "--entrypoints.web.address=:80"
      - "--entrypoints.websecure.address=:443"
      - "--certificatesresolvers.myresolver.acme.tlschallenge=true"
      - "--certificatesresolvers.myresolver.acme.email=your@email.com"
      - "--certificatesresolvers.myresolver.acme.storage=/letsencrypt/acme.json"
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./letsencrypt:/letsencrypt

  frontend:
    build: .
    labels:
      - "traefik.enable=true"
      - "traefik.http.routers.frontend.rule=Host(`your-domain.com`)"
      - "traefik.http.routers.frontend.entrypoints=websecure"
      - "traefik.http.routers.frontend.tls.certresolver=myresolver"
```

---

## 📊 监控和日志

### 查看日志

```bash
# 所有服务日志
docker-compose logs -f

# 特定服务日志
docker-compose logs -f frontend
docker-compose logs -f backend

# 最近 100 行日志
docker-compose logs --tail=100 frontend
```

### 进入容器

```bash
# 进入前端容器
docker-compose exec frontend sh

# 进入数据库容器
docker-compose exec db psql -U postgres -d prompt_manager
```

### 资源使用

```bash
# 查看资源使用情况
docker stats

# 查看特定容器
docker stats prompt-manager-frontend
```

---

## 🔍 故障排查

### 1. 容器无法启动

```bash
# 查看容器状态
docker-compose ps

# 查看详细日志
docker-compose logs frontend

# 检查配置
docker-compose config
```

### 2. 网络问题

```bash
# 查看网络
docker network ls

# 检查网络连接
docker-compose exec frontend ping backend
```

### 3. 数据库连接失败

```bash
# 检查数据库是否运行
docker-compose exec db pg_isready

# 测试连接
docker-compose exec backend psql -h db -U postgres -d prompt_manager
```

### 4. 前端无法访问后端

检查 `nginx.conf` 中的代理配置：
```nginx
location /api {
    proxy_pass http://backend:8080;  # 确保使用服务名
}
```

---

## 🔄 更新和维护

### 更新镜像

```bash
# 拉取最新镜像
docker-compose pull

# 重新构建
docker-compose build --no-cache

# 重启服务
docker-compose up -d
```

### 备份数据

```bash
# 备份数据库
docker-compose exec db pg_dump -U postgres prompt_manager > backup.sql

# 备份 Redis
docker-compose exec redis redis-cli SAVE
docker cp prompt-manager-redis:/data/dump.rdb ./redis-backup.rdb
```

### 恢复数据

```bash
# 恢复数据库
docker-compose exec -T db psql -U postgres prompt_manager < backup.sql

# 恢复 Redis
docker cp ./redis-backup.rdb prompt-manager-redis:/data/dump.rdb
docker-compose restart redis
```

---

## 🎯 最佳实践

### 1. 使用 .env 文件

不要在 `docker-compose.yml` 中硬编码敏感信息。

### 2. 限制资源

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

### 3. 健康检查

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

### 4. 日志管理

```yaml
services:
  frontend:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

---

## 📝 常用命令

```bash
# 启动服务
docker-compose up -d

# 停止服务
docker-compose stop

# 重启服务
docker-compose restart

# 查看日志
docker-compose logs -f

# 查看状态
docker-compose ps

# 进入容器
docker-compose exec frontend sh

# 删除所有容器和数据
docker-compose down -v

# 重新构建
docker-compose build --no-cache

# 拉取最新镜像
docker-compose pull

# 查看配置
docker-compose config
```

---

## 🎉 总结

使用 Docker 部署的优势：

- ✅ **环境一致性** - 开发、测试、生产环境完全一致
- ✅ **快速部署** - 一键启动所有服务
- ✅ **易于扩展** - 轻松添加新服务
- ✅ **隔离性好** - 服务之间相互隔离
- ✅ **易于维护** - 统一管理和更新

推荐使用 Docker Compose 进行部署，简单高效！
