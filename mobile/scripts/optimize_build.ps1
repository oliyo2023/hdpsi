# APK 体积优化构建脚本
# 用于减少 Flutter 应用的 APK 体积

Write-Host "🚀 开始 APK 体积优化构建..." -ForegroundColor Green

# 1. 清理构建缓存
Write-Host "📦 清理构建缓存..." -ForegroundColor Yellow
flutter clean
flutter pub get

# 2. 检查图标文件大小
Write-Host "🖼️ 检查图标文件..." -ForegroundColor Yellow
$iconPath = "assets/icons/icon.png"
if (Test-Path $iconPath) {
    $iconSize = (Get-Item $iconPath).Length
    $iconSizeMB = [math]::Round($iconSize / 1MB, 2)
    Write-Host "当前图标大小: $iconSizeMB MB" -ForegroundColor Cyan
    
    if ($iconSizeMB -gt 0.5) {
        Write-Host "⚠️ 警告: 图标文件过大 ($iconSizeMB MB)，建议压缩到 500KB 以下" -ForegroundColor Red
        Write-Host "建议使用在线工具压缩图标: https://tinypng.com/" -ForegroundColor Yellow
    }
}

# 3. 分析依赖包大小
Write-Host "📊 分析依赖包..." -ForegroundColor Yellow
flutter pub deps --style=compact

# 4. 构建优化的 APK
Write-Host "🔨 构建优化的 APK..." -ForegroundColor Yellow

# 构建 App Bundle (推荐用于 Google Play)
Write-Host "构建 App Bundle..." -ForegroundColor Cyan
flutter build appbundle --release --shrink --obfuscate --split-debug-info=build/app/outputs/symbols

# 构建优化的 APK
Write-Host "构建优化的 APK..." -ForegroundColor Cyan
flutter build apk --release --shrink --obfuscate --split-debug-info=build/app/outputs/symbols --split-per-abi --target-platform android-arm64

# 5. 显示构建结果
Write-Host "📈 构建结果:" -ForegroundColor Green

$apkPath = "build/app/outputs/flutter-apk/app-release.apk"
$bundlePath = "build/app/outputs/bundle/release/app-release.aab"

if (Test-Path $apkPath) {
    $apkSize = (Get-Item $apkPath).Length
    $apkSizeMB = [math]::Round($apkSize / 1MB, 2)
    Write-Host "APK 大小: $apkSizeMB MB" -ForegroundColor Cyan
}

if (Test-Path $bundlePath) {
    $bundleSize = (Get-Item $bundlePath).Length
    $bundleSizeMB = [math]::Round($bundleSize / 1MB, 2)
    Write-Host "App Bundle 大小: $bundleSizeMB MB" -ForegroundColor Cyan
}

Write-Host "✅ 构建完成!" -ForegroundColor Green
Write-Host ""
Write-Host "📝 优化建议:" -ForegroundColor Yellow
Write-Host "1. 使用 App Bundle 而不是 APK 发布到 Google Play"
Write-Host "2. 压缩图标文件到 500KB 以下"
Write-Host "3. 移除未使用的依赖包"
Write-Host "4. 考虑使用延迟加载功能"
