#!/bin/bash

# 宏店移动应用名称验证脚本
# 此脚本用于验证应用名称是否已正确更改为"宏店"

echo "宏店移动应用名称验证工具"
echo "=========================="

# 检查 Android 配置
echo "1. 检查 Android 配置..."
if grep -q "宏店" android/app/src/main/AndroidManifest.xml; then
    echo "   ✓ AndroidManifest.xml 中的应用标签已更改为'宏店'"
else
    echo "   ✗ AndroidManifest.xml 中的应用标签未更改"
fi

# 检查 iOS 配置
echo "2. 检查 iOS 配置..."
if grep -q "宏店" ios/Runner/Info.plist; then
    echo "   ✓ iOS Info.plist 中的应用名称已更改为'宏店'"
else
    echo "   ✗ iOS Info.plist 中的应用名称未更改"
fi

# 检查 Web 配置
echo "3. 检查 Web 配置..."
if grep -q "宏店" web/manifest.json; then
    echo "   ✓ Web manifest.json 中的应用名称已更改为'宏店'"
else
    echo "   ✗ Web manifest.json 中的应用名称未更改"
fi

# 检查应用配置文件
echo "4. 检查应用配置文件..."
if grep -q "宏店" lib/utils/config.dart; then
    echo "   ✓ config.dart 中的应用名称已更改为'宏店'"
else
    echo "   ✗ config.dart 中的应用名称未更改"
fi

# 检查 pubspec.yaml
echo "5. 检查 pubspec.yaml..."
if grep -q "宏店" pubspec.yaml; then
    echo "   ✓ pubspec.yaml 中的描述已更新"
else
    echo "   ✗ pubspec.yaml 中的描述未更新"
fi

# 检查构建后的 APK（如果存在）
echo "6. 检查构建后的应用..."
if [ -f "build/app/outputs/flutter-apk/app-debug.apk" ]; then
    if [ -f "build/app/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml" ]; then
        if grep -q "宏店" "build/app/intermediates/merged_manifests/debug/processDebugManifest/AndroidManifest.xml"; then
            echo "   ✓ 构建后的 APK 中应用名称为'宏店'"
        else
            echo "   ✗ 构建后的 APK 中应用名称未更改"
        fi
    else
        echo "   - 未找到构建后的 AndroidManifest.xml"
    fi
else
    echo "   - 未找到构建后的 APK 文件"
    echo "   提示: 运行 'flutter build apk --debug' 来构建应用"
fi

echo
echo "验证完成！"
echo
echo "如果所有检查都通过，您的应用名称已成功更改为'宏店'。"
echo "建议下一步操作："
echo "1. 运行 'flutter clean && flutter pub get' 清理并重新获取依赖"
echo "2. 运行 'flutter build apk --debug' 构建测试版本"
echo "3. 安装 APK 到设备上验证应用名称显示"
