#!/bin/bash

if [ -z "$1" ]; then
    echo "❌ 请指定备份文件"
    echo "用法: ./docker-restore.sh <backup-file.tar.gz>"
    exit 1
fi

BACKUP_FILE="$1"

if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ 备份文件不存在: $BACKUP_FILE"
    exit 1
fi

echo "🔄 恢复数据..."
echo "📁 备份文件: $BACKUP_FILE"
echo ""

# 解压备份
TEMP_DIR="./temp_restore"
mkdir -p "$TEMP_DIR"
tar -xzf "$BACKUP_FILE" -C "$TEMP_DIR"

BACKUP_DIR=$(ls "$TEMP_DIR")

# 恢复数据库
if [ -f "$TEMP_DIR/$BACKUP_DIR/database.sql" ]; then
    echo "1️⃣ 恢复 PostgreSQL 数据库..."
    docker-compose exec -T db psql -U postgres prompt_manager < "$TEMP_DIR/$BACKUP_DIR/database.sql"
    if [ $? -eq 0 ]; then
        echo "   ✅ 数据库恢复成功"
    else
        echo "   ❌ 数据库恢复失败"
    fi
fi

# 恢复 Redis
if [ -f "$TEMP_DIR/$BACKUP_DIR/redis-dump.rdb" ]; then
    echo "2️⃣ 恢复 Redis 数据..."
    docker cp "$TEMP_DIR/$BACKUP_DIR/redis-dump.rdb" prompt-manager-redis:/data/dump.rdb
    docker-compose restart redis
    if [ $? -eq 0 ]; then
        echo "   ✅ Redis 恢复成功"
    else
        echo "   ❌ Redis 恢复失败"
    fi
fi

# 清理临时文件
rm -rf "$TEMP_DIR"

echo ""
echo "✅ 数据恢复完成！"
