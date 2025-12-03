#!/bin/bash

echo "🔨 重新构建 Docker 镜像..."
echo ""

# 选择环境
echo "请选择重新构建的环境："
echo "1) 生产环境"
echo "2) 开发环境"
read -p "请输入选项 (1 或 2): " choice

case $choice in
    1)
        echo ""
        echo "重新构建生产环境..."
        docker-compose build --no-cache
        echo ""
        echo "重启服务..."
        docker-compose up -d
        ;;
    2)
        echo ""
        echo "重新构建开发环境..."
        docker-compose -f docker-compose.dev.yml build --no-cache
        echo ""
        echo "重启服务..."
        docker-compose -f docker-compose.dev.yml up -d
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "✅ 重新构建完成！"
