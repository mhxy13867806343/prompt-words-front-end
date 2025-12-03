#!/bin/bash

echo "📋 查看 Docker 日志..."
echo ""

# 选择服务
echo "请选择要查看的服务："
echo "1) 前端 (frontend)"
echo "2) 后端 (backend)"
echo "3) 数据库 (db)"
echo "4) Redis (redis)"
echo "5) 所有服务"
read -p "请输入选项 (1-5): " choice

case $choice in
    1)
        docker-compose logs -f frontend
        ;;
    2)
        docker-compose logs -f backend
        ;;
    3)
        docker-compose logs -f db
        ;;
    4)
        docker-compose logs -f redis
        ;;
    5)
        docker-compose logs -f
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac
