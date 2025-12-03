.PHONY: help dev prod build stop restart logs backup restore clean

# 默认目标
help:
	@echo "🐳 Docker 管理命令"
	@echo ""
	@echo "开发环境:"
	@echo "  make dev          - 启动开发环境"
	@echo "  make dev-logs     - 查看开发环境日志"
	@echo "  make dev-stop     - 停止开发环境"
	@echo ""
	@echo "生产环境:"
	@echo "  make prod         - 启动生产环境"
	@echo "  make prod-logs    - 查看生产环境日志"
	@echo "  make prod-stop    - 停止生产环境"
	@echo ""
	@echo "构建和维护:"
	@echo "  make build        - 构建镜像"
	@echo "  make rebuild      - 重新构建镜像（无缓存）"
	@echo "  make restart      - 重启服务"
	@echo ""
	@echo "数据管理:"
	@echo "  make backup       - 备份数据"
	@echo "  make restore      - 恢复数据"
	@echo ""
	@echo "清理:"
	@echo "  make clean        - 停止并删除容器"
	@echo "  make clean-all    - 停止并删除容器和数据卷"

# 开发环境
dev:
	@echo "🔧 启动开发环境..."
	docker-compose -f docker-compose.dev.yml up -d
	@echo "✅ 开发环境已启动"
	@echo "📍 访问: http://localhost:3000"

dev-logs:
	docker-compose -f docker-compose.dev.yml logs -f

dev-stop:
	docker-compose -f docker-compose.dev.yml stop

# 生产环境
prod:
	@echo "🚀 启动生产环境..."
	docker-compose up -d
	@echo "✅ 生产环境已启动"
	@echo "📍 访问: http://localhost"

prod-logs:
	docker-compose logs -f

prod-stop:
	docker-compose stop

# 构建
build:
	@echo "🔨 构建镜像..."
	docker-compose build

rebuild:
	@echo "🔨 重新构建镜像（无缓存）..."
	docker-compose build --no-cache

# 重启
restart:
	@echo "🔄 重启服务..."
	docker-compose restart

# 数据管理
backup:
	@echo "💾 备份数据..."
	./docker-backup.sh

restore:
	@echo "🔄 恢复数据..."
	@read -p "请输入备份文件路径: " file; \
	./docker-restore.sh $$file

# 清理
clean:
	@echo "🧹 清理容器..."
	docker-compose down
	docker-compose -f docker-compose.dev.yml down

clean-all:
	@echo "🧹 清理容器和数据卷..."
	docker-compose down -v
	docker-compose -f docker-compose.dev.yml down -v

# 查看状态
status:
	@echo "📊 容器状态:"
	@docker-compose ps
	@echo ""
	@echo "📊 资源使用:"
	@docker stats --no-stream

# 进入容器
shell-frontend:
	docker-compose exec frontend sh

shell-backend:
	docker-compose exec backend sh

shell-db:
	docker-compose exec db psql -U postgres -d prompt_manager

shell-redis:
	docker-compose exec redis redis-cli
