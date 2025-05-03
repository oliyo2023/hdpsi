#!/bin/bash

# 复制前端构建文件到后端public目录的Bash脚本

# 定义路径
FRONTEND_DIST_PATH="../hd-psi-frontend/dist"
BACKEND_PUBLIC_PATH="./public"

# 检查前端构建目录是否存在
if [ ! -d "$FRONTEND_DIST_PATH" ]; then
    echo "错误: 前端构建目录不存在: $FRONTEND_DIST_PATH"
    echo "请先在前端项目中运行 npm run build"
    exit 1
fi

# 确保后端public目录存在
if [ ! -d "$BACKEND_PUBLIC_PATH" ]; then
    mkdir -p "$BACKEND_PUBLIC_PATH"
    echo "创建目录: $BACKEND_PUBLIC_PATH"
fi

# 清空public目录（保留目录本身）
rm -rf "$BACKEND_PUBLIC_PATH"/*
echo "清空目录: $BACKEND_PUBLIC_PATH"

# 复制前端构建文件到后端public目录
cp -r "$FRONTEND_DIST_PATH"/* "$BACKEND_PUBLIC_PATH"/
echo "复制前端构建文件到: $BACKEND_PUBLIC_PATH"

# 检查index.html是否存在
if [ -f "$BACKEND_PUBLIC_PATH/index.html" ]; then
    echo "成功: index.html 已复制"
else
    echo "错误: index.html 未找到"
    exit 1
fi

echo "前端文件集成完成!"
echo "现在可以通过后端服务访问前端页面了"
