# Docker 快速开始

## 🚀 5 分钟快速部署

### 前提条件

确保已安装：
- Docker Desktop (macOS/Windows) 或 Docker Engine (Linux)
- Docker Compose

### 安装 Docker

#### macOS
```bash
# 下载 Docker Desktop
# https://www.docker.com/products/docker-desktop

# 或使用 Homebrew
brew install --cask docker
```

#### Linux (Ubuntu/Debian)
```bash
# 安装 Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# 安装 Docker Compose
sudo apt-get install docker-compose-plugin
```

#### Windows
下载并安装 Docker Desktop:
https://www.docker.com/products/docker-desktop

---

## 📦 部署步骤

### 1. 配置环境变量

```bash
# 复制环境变量模板
cp .env.docker .env

# 编辑 .env 文件，修改以下内容：
# - 数据库密码
# - JWT 密钥
# - 邮件配置
```

### 2. 启动服务

#### 方式 A：使用脚本（推荐）

```bash
# 给脚本添加执行权限
chmod +x docker-start.sh

# 启动服务
./docker-start.sh

# 选择环境：
# 1) 生产环境
# 2) 开发环境
```

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

### 3. 访问应用

- **生产环境**: http://localhost
- **开发环境**: http://localhost:3000
- **后端 API**: http://localhost:8080
- **数据库**: localhost:5432
- **Redis**: localhost:6379

### 4. 查看日志

```bash
# 使用脚本
./docker-logs.sh

# 使用 Make
make prod-logs    # 生产环境
make dev-logs     # 开发环境

# 使用 Docker Compose
docker-compose logs -f
```

---

## 🛠️ 常用操作

### 查看运行状态

```bash
docker-compose ps
```

### 停止服务

```bash
# 使用脚本
./docker-stop.sh

# 使用 Make
make prod-stop

# 使用 Docker Compose
docker-compose stop
```

### 重启服务

```bash
# 使用 Make
make restart

# 使用 Docker Compose
docker-compose restart
```

### 查看资源使用

```bash
docker stats
```

### 进入容器

```bash
# 前端容器
docker-compose exec frontend sh

# 数据库容器
docker-compose exec db psql -U postgres -d prompt_manager

# Redis 容器
docker-compose exec redis redis-cli
```

---

## 💾 数据管理

### 备份数据

```bash
# 使用脚本
./docker-backup.sh

# 使用 Make
make backup
```

备份文件保存在 `backups/` 目录。

### 恢复数据

```bash
# 使用脚本
./docker-restore.sh backups/20240101_120000.tar.gz

# 使用 Make
make restore
# 然后输入备份文件路径
```

---

## 🔄 更新和维护

### 更新代码

```bash
# 1. 拉取最新代码
git pull

# 2. 重新构建镜像
docker-compose build --no-cache

# 3. 重启服务
docker-compose up -d
```

### 清理旧数据

```bash
# 停止并删除容器
docker-compose down

# 停止并删除容器和数据卷（⚠️ 会删除所有数据）
docker-compose down -v

# 清理未使用的镜像
docker image prune -a
```

---

## 🔍 故障排查

### 容器无法启动

```bash
# 查看日志
docker-compose logs frontend

# 检查配置
docker-compose config

# 重新构建
docker-compose build --no-cache
docker-compose up -d
```

### 端口被占用

```bash
# 查看端口占用
lsof -i :80
lsof -i :3000

# 修改端口
# 编辑 docker-compose.yml，修改 ports 配置
```

### 数据库连接失败

```bash
# 检查数据库状态
docker-compose exec db pg_isready

# 查看数据库日志
docker-compose logs db

# 重启数据库
docker-compose restart db
```

### 前端无法访问后端

```bash
# 检查网络连接
docker-compose exec frontend ping backend

# 检查 Nginx 配置
docker-compose exec frontend cat /etc/nginx/conf.d/default.conf
```

---

## 📊 服务说明

### 服务列表

| 服务 | 说明 | 端口 |
|------|------|------|
| frontend | 前端服务 (Nginx) | 80 |
| backend | 后端服务 | 8080 |
| db | PostgreSQL 数据库 | 5432 |
| redis | Redis 缓存 | 6379 |

### 数据卷

| 数据卷 | 说明 |
|--------|------|
| postgres-data | PostgreSQL 数据 |
| redis-data | Redis 数据 |

### 网络

所有服务在 `app-network` 网络中通信。

---

## 🎯 生产环境部署

### 1. 配置域名

编辑 `nginx.conf`：

```nginx
server {
    listen 80;
    server_name your-domain.com;  # 修改为你的域名
    # ...
}
```

### 2. 配置 HTTPS

```bash
# 使用 Let's Encrypt
docker run -it --rm \
  -v /etc/letsencrypt:/etc/letsencrypt \
  -v /var/lib/letsencrypt:/var/lib/letsencrypt \
  certbot/certbot certonly \
  --standalone \
  -d your-domain.com
```

### 3. 修改 Nginx 配置

```nginx
server {
    listen 443 ssl http2;
    server_name your-domain.com;
    
    ssl_certificate /etc/letsencrypt/live/your-domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your-domain.com/privkey.pem;
    
    # ...
}
```

### 4. 重启服务

```bash
docker-compose restart frontend
```

---

## 💡 最佳实践

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
# 限制日志大小
# 在 docker-compose.yml 中添加：
logging:
  driver: "json-file"
  options:
    max-size: "10m"
    max-file: "3"
```

### 4. 资源限制

```bash
# 在 docker-compose.yml 中添加：
deploy:
  resources:
    limits:
      cpus: '0.5'
      memory: 512M
```

---

## 📞 获取帮助

### 查看文档

- [DOCKER.md](./DOCKER.md) - 完整的 Docker 部署指南
- [README.md](./README.md) - 项目说明
- [API.md](./API.md) - API 接口文档

### 常用命令

```bash
# 查看所有 Make 命令
make help

# 查看 Docker Compose 配置
docker-compose config

# 查看容器状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

---

## ✅ 检查清单

部署前检查：

- [ ] Docker 和 Docker Compose 已安装
- [ ] 已配置 .env 文件
- [ ] 已修改数据库密码
- [ ] 已修改 JWT 密钥
- [ ] 已配置邮件服务
- [ ] 端口未被占用（80, 8080, 5432, 6379）

部署后检查：

- [ ] 所有容器正常运行
- [ ] 前端可以访问
- [ ] 后端 API 可以访问
- [ ] 数据库连接正常
- [ ] Redis 连接正常

---

## 🎉 完成！

现在你的应用已经通过 Docker 成功部署了！

访问 http://localhost 开始使用吧！
