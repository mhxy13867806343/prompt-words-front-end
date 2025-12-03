#!/bin/bash

echo "🛑 停止 Docker 容器..."
echo ""

# 选择环境
echo "请选择停止的环境："
echo "1) 生产环境"
echo "2) 开发环境"
echo "3) 全部停止"
read -p "请输入选项 (1, 2 或 3): " choice

case $choice in
    1)
        echo ""
        echo "停止生产环境..."
        docker-compose stop
        ;;
    2)
        echo ""
        echo "停止开发环境..."
        docker-compose -f docker-compose.dev.yml stop
        ;;
    3)
        echo ""
        echo "停止所有环境..."
        docker-compose stop
        docker-compose -f docker-compose.dev.yml stop
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "✅ 容器已停止"
echo ""
echo "💡 提示："
echo "   重新启动: ./docker-start.sh"
echo "   删除容器: docker-compose down"
echo "   删除容器和数据: docker-compose down -v"
