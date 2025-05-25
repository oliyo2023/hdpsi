#!/bin/bash

# 宏店移动应用密钥库生成脚本
# 使用此脚本生成用于应用签名的密钥库文件

echo "宏店移动应用密钥库生成工具"
echo "================================="

# 检查是否已存在密钥库文件
if [ -f "release-key.keystore" ]; then
    echo "警告: release-key.keystore 文件已存在!"
    read -p "是否要覆盖现有文件? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "操作已取消"
        exit 1
    fi
fi

# 获取用户输入
echo "请输入以下信息来生成密钥库:"
echo

read -p "密钥库密码: " -s KEYSTORE_PASSWORD
echo
read -p "确认密钥库密码: " -s KEYSTORE_PASSWORD_CONFIRM
echo

if [ "$KEYSTORE_PASSWORD" != "$KEYSTORE_PASSWORD_CONFIRM" ]; then
    echo "错误: 密码不匹配!"
    exit 1
fi

read -p "密钥别名 (建议: hdpsi-release): " KEY_ALIAS
if [ -z "$KEY_ALIAS" ]; then
    KEY_ALIAS="hdpsi-release"
fi

read -p "密钥密码 (可以与密钥库密码相同): " -s KEY_PASSWORD
echo

read -p "您的姓名: " DNAME_CN
read -p "组织单位 (如: IT部门): " DNAME_OU
read -p "组织名称 (如: 宏达服装): " DNAME_O
read -p "城市: " DNAME_L
read -p "省份: " DNAME_ST
read -p "国家代码 (如: CN): " DNAME_C

# 构建DN字符串
DNAME="CN=$DNAME_CN, OU=$DNAME_OU, O=$DNAME_O, L=$DNAME_L, ST=$DNAME_ST, C=$DNAME_C"

echo
echo "正在生成密钥库..."

# 生成密钥库
keytool -genkey \
    -v \
    -keystore release-key.keystore \
    -alias "$KEY_ALIAS" \
    -keyalg RSA \
    -keysize 2048 \
    -validity 10000 \
    -storepass "$KEYSTORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "$DNAME"

if [ $? -eq 0 ]; then
    echo
    echo "密钥库生成成功!"
    echo "文件位置: $(pwd)/release-key.keystore"
    echo
    echo "请更新 key.properties 文件中的以下信息:"
    echo "MYAPP_RELEASE_STORE_FILE=release-key.keystore"
    echo "MYAPP_RELEASE_STORE_PASSWORD=$KEYSTORE_PASSWORD"
    echo "MYAPP_RELEASE_KEY_ALIAS=$KEY_ALIAS"
    echo "MYAPP_RELEASE_KEY_PASSWORD=$KEY_PASSWORD"
    echo
    echo "重要提醒:"
    echo "1. 请妥善保管密钥库文件和密码"
    echo "2. 请将 key.properties 添加到 .gitignore"
    echo "3. 建议备份密钥库文件到安全位置"
    echo "4. 密钥库密码丢失将无法更新应用"
else
    echo "密钥库生成失败!"
    exit 1
fi
