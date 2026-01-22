#!/bin/bash

# 宏店移动应用发布构建脚本
# 此脚本用于构建生产环境的APK和AAB文件

set -e  # 遇到错误时退出

echo "宏店移动应用发布构建工具"
echo "==============================="

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo "错误: Flutter 未安装或不在PATH中"
    exit 1
fi

# 检查密钥配置
if [ ! -f "android/key.properties" ]; then
    echo "错误: 未找到 android/key.properties 文件"
    echo "请先配置签名密钥，或运行 android/generate-keystore.sh 生成密钥库"
    exit 1
fi

# 检查密钥库文件
KEYSTORE_FILE=$(grep "MYAPP_RELEASE_STORE_FILE" android/key.properties | cut -d'=' -f2)
if [ ! -f "android/$KEYSTORE_FILE" ]; then
    echo "错误: 未找到密钥库文件 android/$KEYSTORE_FILE"
    echo "请确保密钥库文件存在，或运行 android/generate-keystore.sh 生成"
    exit 1
fi

echo "✓ Flutter 环境检查通过"
echo "✓ 签名配置检查通过"
echo

# 清理之前的构建
echo "清理之前的构建..."
flutter clean
flutter pub get

echo "✓ 依赖安装完成"
echo

# 构建选项
echo "请选择构建类型:"
echo "1) APK (用于直接安装)"
echo "2) AAB (用于Google Play Store)"
echo "3) 两者都构建"
read -p "请输入选择 (1-3): " BUILD_CHOICE

case $BUILD_CHOICE in
    1)
        echo "构建APK..."
        flutter build apk --release
        echo "✓ APK构建完成"
        echo "文件位置: build/app/outputs/flutter-apk/app-release.apk"
        ;;
    2)
        echo "构建AAB..."
        flutter build appbundle --release
        echo "✓ AAB构建完成"
        echo "文件位置: build/app/outputs/bundle/release/app-release.aab"
        ;;
    3)
        echo "构建APK..."
        flutter build apk --release
        echo "✓ APK构建完成"
        echo
        echo "构建AAB..."
        flutter build appbundle --release
        echo "✓ AAB构建完成"
        echo
        echo "构建文件位置:"
        echo "APK: build/app/outputs/flutter-apk/app-release.apk"
        echo "AAB: build/app/outputs/bundle/release/app-release.aab"
        ;;
    *)
        echo "无效选择"
        exit 1
        ;;
esac

echo
echo "构建完成!"
echo

# 显示文件信息
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_SIZE=$(du -h build/app/outputs/flutter-apk/app-release.apk | cut -f1)
    echo "APK文件大小: $APK_SIZE"
fi

if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    AAB_SIZE=$(du -h build/app/outputs/bundle/release/app-release.aab | cut -f1)
    echo "AAB文件大小: $AAB_SIZE"
fi

echo
echo "发布检查清单:"
echo "□ 测试应用功能是否正常"
echo "□ 检查应用权限设置"
echo "□ 验证签名是否正确"
echo "□ 准备应用商店描述和截图"
echo "□ 检查版本号是否正确"

echo
echo "验证签名命令:"
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "APK: jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk"
fi
if [ -f "build/app/outputs/bundle/release/app-release.aab" ]; then
    echo "AAB: jarsigner -verify -verbose -certs build/app/outputs/bundle/release/app-release.aab"
fi
