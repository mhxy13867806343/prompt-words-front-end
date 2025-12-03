#!/bin/bash

echo "🐳 启动 Docker 容器..."
echo ""

# 检查 Docker 是否安装
if ! command -v docker &> /dev/null
then
    echo "❌ Docker 未安装，请先安装 Docker"
    exit 1
fi

# 检查 Docker Compose 是否安装
if ! command -v docker-compose &> /dev/null
then
    echo "❌ Docker Compose 未安装，请先安装 Docker Compose"
    exit 1
fi

# 检查 .env 文件是否存在
if [ ! -f ".env" ]; then
    echo "⚠️  .env 文件不存在，从 .env.docker 复制..."
    cp .env.docker .env
    echo "✅ 已创建 .env 文件，请编辑配置后再次运行"
    exit 0
fi

# 选择环境
echo "请选择启动环境："
echo "1) 生产环境 (docker-compose.yml)"
echo "2) 开发环境 (docker-compose.dev.yml)"
read -p "请输入选项 (1 或 2): " choice

case $choice in
    1)
        echo ""
        echo "🚀 启动生产环境..."
        docker-compose up -d
        ;;
    2)
        echo ""
        echo "🔧 启动开发环境..."
        docker-compose -f docker-compose.dev.yml up -d
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "✅ 容器启动成功！"
echo ""
echo "📍 访问地址："
if [ "$choice" = "1" ]; then
    echo "   前端: http://localhost"
    echo "   后端: http://localhost:8080"
else
    echo "   前端: http://localhost:3000"
fi
echo ""
echo "📊 查看日志: docker-compose logs -f"
echo "🛑 停止服务: docker-compose stop"
