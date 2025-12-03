#!/bin/bash

echo "🚀 启动提示词管理系统..."
echo ""

# 检查 pnpm 是否安装
if ! command -v pnpm &> /dev/null
then
    echo "❌ pnpm 未安装，请先安装 pnpm"
    echo "   npm install -g pnpm"
    exit 1
fi

# 检查 node_modules 是否存在
if [ ! -d "node_modules" ]; then
    echo "📦 安装依赖..."
    pnpm install
    echo ""
fi

echo "✅ 启动开发服务器..."
echo "📍 访问地址: http://localhost:3000"
echo ""

pnpm dev
