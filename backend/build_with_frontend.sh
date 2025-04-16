#!/bin/bash

# 构建包含前端资源的后端可执行文件的Bash脚本

# 定义路径
FRONTEND_DIST_PATH="../hd-psi-frontend/dist"
BACKEND_EMBED_PATH="./embed/static"

# 检查前端构建目录是否存在
if [ ! -d "$FRONTEND_DIST_PATH" ]; then
    echo "错误: 前端构建目录不存在: $FRONTEND_DIST_PATH"
    echo "请先在前端项目中运行 npm run build"
    exit 1
fi

# 确保embed/static目录存在
if [ ! -d "$BACKEND_EMBED_PATH" ]; then
    mkdir -p "$BACKEND_EMBED_PATH"
    echo "创建目录: $BACKEND_EMBED_PATH"
fi

# 清空embed/static目录（保留目录本身）
rm -rf "$BACKEND_EMBED_PATH"/*
echo "清空目录: $BACKEND_EMBED_PATH"

# 复制前端构建文件到embed/static目录
cp -r "$FRONTEND_DIST_PATH"/* "$BACKEND_EMBED_PATH"/
echo "复制前端构建文件到: $BACKEND_EMBED_PATH"

# 检查index.html是否存在
if [ -f "$BACKEND_EMBED_PATH/index.html" ]; then
    echo "成功: index.html 已复制"
else
    echo "错误: index.html 未找到"
    exit 1
fi

# 构建后端可执行文件
echo "开始构建后端可执行文件..."
go build -o hdpsi
if [ $? -ne 0 ]; then
    echo "构建失败"
    exit 1
fi

echo "构建成功: hdpsi"
echo "前端资源已嵌入到可执行文件中"
echo "可以直接运行 ./hdpsi 启动完整应用"
