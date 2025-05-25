#!/bin/bash

# 宏店应用 Google Play 发布准备脚本
# 此脚本帮助您准备发布到 Google Play 商店所需的所有文件

set -e  # 遇到错误时退出

echo "宏店应用 Google Play 发布准备工具"
echo "=================================="

# 检查Flutter环境
if ! command -v flutter &> /dev/null; then
    echo "错误: Flutter 未安装或不在PATH中"
    exit 1
fi

# 检查密钥配置
if [ ! -f "android/key.properties" ]; then
    echo "警告: 未找到签名配置文件"
    echo "是否要生成新的签名密钥? (y/N): "
    read -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "正在生成签名密钥..."
        cd android && ./generate-keystore.sh && cd ..
    else
        echo "提示: 发布到 Google Play 需要正式的签名密钥"
    fi
fi

echo "✓ 环境检查完成"
echo

# 清理并获取依赖
echo "清理项目并获取依赖..."
flutter clean
flutter pub get

echo "✓ 项目清理完成"
echo

# 构建选项
echo "选择构建类型:"
echo "1) AAB (推荐用于 Google Play)"
echo "2) APK (用于直接分发)"
echo "3) 两者都构建"
read -p "请输入选择 (1-3): " BUILD_CHOICE

case $BUILD_CHOICE in
    1)
        echo "构建 AAB 文件..."
        flutter build appbundle --release
        echo "✓ AAB 构建完成"
        echo "文件位置: build/app/outputs/bundle/release/app-release.aab"
        AAB_FILE="build/app/outputs/bundle/release/app-release.aab"
        ;;
    2)
        echo "构建 APK 文件..."
        flutter build apk --release
        echo "✓ APK 构建完成"
        echo "文件位置: build/app/outputs/flutter-apk/app-release.apk"
        APK_FILE="build/app/outputs/flutter-apk/app-release.apk"
        ;;
    3)
        echo "构建 AAB 文件..."
        flutter build appbundle --release
        echo "✓ AAB 构建完成"
        echo
        echo "构建 APK 文件..."
        flutter build apk --release
        echo "✓ APK 构建完成"
        echo
        echo "构建文件位置:"
        echo "AAB: build/app/outputs/bundle/release/app-release.aab"
        echo "APK: build/app/outputs/flutter-apk/app-release.apk"
        AAB_FILE="build/app/outputs/bundle/release/app-release.aab"
        APK_FILE="build/app/outputs/flutter-apk/app-release.apk"
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
if [ -f "$AAB_FILE" ]; then
    AAB_SIZE=$(du -h "$AAB_FILE" | cut -f1)
    echo "AAB 文件大小: $AAB_SIZE"
fi

if [ -f "$APK_FILE" ]; then
    APK_SIZE=$(du -h "$APK_FILE" | cut -f1)
    echo "APK 文件大小: $APK_SIZE"
fi

echo
echo "验证签名..."

# 验证签名
if [ -f "$AAB_FILE" ]; then
    echo "验证 AAB 签名:"
    if jarsigner -verify -verbose "$AAB_FILE" > /dev/null 2>&1; then
        echo "✓ AAB 签名验证成功"
    else
        echo "⚠ AAB 签名验证失败或使用调试签名"
    fi
fi

if [ -f "$APK_FILE" ]; then
    echo "验证 APK 签名:"
    if jarsigner -verify -verbose "$APK_FILE" > /dev/null 2>&1; then
        echo "✓ APK 签名验证成功"
    else
        echo "⚠ APK 签名验证失败或使用调试签名"
    fi
fi

echo
echo "Google Play 发布准备清单:"
echo "=========================="

# 技术准备检查
echo "📱 技术准备:"
if [ -f "$AAB_FILE" ] || [ -f "$APK_FILE" ]; then
    echo "✓ 应用文件已构建"
else
    echo "✗ 应用文件构建失败"
fi

if [ -f "android/key.properties" ]; then
    echo "✓ 签名配置已准备"
else
    echo "⚠ 签名配置未完成"
fi

echo "✓ 应用名称: 宏店"
echo "✓ 应用ID: com.hdpsi.mobile"
echo "✓ 版本: 1.0.0+1"

echo
echo "📋 商店资料准备:"
echo "□ 应用图标 (512x512 PNG)"
echo "□ 应用截图 (至少2张)"
echo "□ 应用描述"
echo "□ 隐私政策"
echo "□ 联系信息"

echo
echo "🔐 政策合规:"
echo "□ 内容分级问卷"
echo "□ 目标受众设置"
echo "□ 权限说明"
echo "□ Google Play 政策审查"

echo
echo "📤 上传步骤:"
echo "1. 访问 Google Play Console: https://play.google.com/console"
echo "2. 创建新应用或选择现有应用"
echo "3. 上传构建的文件:"
if [ -f "$AAB_FILE" ]; then
    echo "   - AAB 文件: $AAB_FILE"
fi
if [ -f "$APK_FILE" ]; then
    echo "   - APK 文件: $APK_FILE"
fi
echo "4. 填写应用信息和商店资料"
echo "5. 完成内容分级和政策合规"
echo "6. 提交审核"

echo
echo "📚 参考文档:"
echo "- 详细上传指南: GOOGLE_PLAY_UPLOAD_GUIDE.md"
echo "- 构建报告: BUILD_REPORT.md"

echo
echo "🎉 准备完成!"
echo "您的宏店应用已准备好发布到 Google Play 商店。"
echo "请按照上述步骤和参考文档进行上传。"

# 可选：打开文件管理器显示构建文件
if command -v xdg-open &> /dev/null; then
    read -p "是否要打开文件管理器查看构建文件? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if [ -f "$AAB_FILE" ]; then
            xdg-open "$(dirname "$AAB_FILE")"
        elif [ -f "$APK_FILE" ]; then
            xdg-open "$(dirname "$APK_FILE")"
        fi
    fi
fi
