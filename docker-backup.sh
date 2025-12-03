#!/bin/bash

echo "💾 备份数据..."
echo ""

# 创建备份目录
BACKUP_DIR="./backups/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

echo "📦 备份目录: $BACKUP_DIR"
echo ""

# 备份数据库
echo "1️⃣ 备份 PostgreSQL 数据库..."
docker-compose exec -T db pg_dump -U postgres prompt_manager > "$BACKUP_DIR/database.sql"
if [ $? -eq 0 ]; then
    echo "   ✅ 数据库备份成功"
else
    echo "   ❌ 数据库备份失败"
fi

# 备份 Redis
echo "2️⃣ 备份 Redis 数据..."
docker-compose exec redis redis-cli SAVE > /dev/null 2>&1
docker cp prompt-manager-redis:/data/dump.rdb "$BACKUP_DIR/redis-dump.rdb" > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✅ Redis 备份成功"
else
    echo "   ❌ Redis 备份失败"
fi

# 压缩备份
echo "3️⃣ 压缩备份文件..."
cd backups
tar -czf "$(basename $BACKUP_DIR).tar.gz" "$(basename $BACKUP_DIR)"
rm -rf "$(basename $BACKUP_DIR)"
cd ..

echo ""
echo "✅ 备份完成！"
echo "📁 备份文件: backups/$(basename $BACKUP_DIR).tar.gz"
echo ""
echo "💡 恢复数据："
echo "   ./docker-restore.sh backups/$(basename $BACKUP_DIR).tar.gz"
