# Android 应用签名一键配置脚本
# 自动检查和配置应用签名

Write-Host "🔐 Android 应用签名配置工具" -ForegroundColor Green
Write-Host "==============================" -ForegroundColor Green
Write-Host ""

# 检查当前目录
if (-not (Test-Path "android")) {
    Write-Host "❌ 错误: 请在 Flutter 项目根目录运行此脚本" -ForegroundColor Red
    exit 1
}

# 检查是否已有签名配置
$keystoreExists = Test-Path "android/release-key.keystore"
$keyPropertiesExists = Test-Path "android/key.properties"

Write-Host "📋 当前签名状态检查:" -ForegroundColor Cyan
Write-Host "密钥库文件: $(if ($keystoreExists) { '✅ 存在' } else { '❌ 不存在' })"
Write-Host "配置文件: $(if ($keyPropertiesExists) { '✅ 存在' } else { '❌ 不存在' })"
Write-Host ""

if ($keystoreExists -and $keyPropertiesExists) {
    Write-Host "✅ 签名配置已存在!" -ForegroundColor Green
    
    # 验证配置文件内容
    $keyProperties = Get-Content "android/key.properties" -Raw
    $hasStoreFile = $keyProperties -match "MYAPP_RELEASE_STORE_FILE="
    $hasStorePassword = $keyProperties -match "MYAPP_RELEASE_STORE_PASSWORD="
    $hasKeyAlias = $keyProperties -match "MYAPP_RELEASE_KEY_ALIAS="
    $hasKeyPassword = $keyProperties -match "MYAPP_RELEASE_KEY_PASSWORD="
    
    if ($hasStoreFile -and $hasStorePassword -and $hasKeyAlias -and $hasKeyPassword) {
        Write-Host "✅ 配置文件完整" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "🚀 现在可以构建发布版本:" -ForegroundColor Yellow
        Write-Host "flutter build apk --release --shrink --obfuscate --split-debug-info=build/app/outputs/symbols --target-platform android-arm64" -ForegroundColor Cyan
        
        $buildNow = Read-Host "是否立即构建发布版本? (y/N)"
        if ($buildNow -eq "y" -or $buildNow -eq "Y") {
            Write-Host ""
            Write-Host "🔨 开始构建..." -ForegroundColor Yellow
            
            # 清理并构建
            flutter clean
            flutter pub get
            flutter build apk --release --shrink --obfuscate --split-debug-info=build/app/outputs/symbols --target-platform android-arm64
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host ""
                Write-Host "✅ 构建成功!" -ForegroundColor Green
                
                # 检查 APK 大小
                $apkPath = "build/app/outputs/flutter-apk/app-release.apk"
                if (Test-Path $apkPath) {
                    $apkSize = (Get-Item $apkPath).Length
                    $apkSizeMB = [math]::Round($apkSize / 1MB, 2)
                    Write-Host "📱 APK 大小: $apkSizeMB MB" -ForegroundColor Cyan
                    Write-Host "📁 APK 位置: $apkPath" -ForegroundColor Cyan
                }
            } else {
                Write-Host "❌ 构建失败" -ForegroundColor Red
            }
        }
        
    } else {
        Write-Host "⚠️ 配置文件不完整，需要重新配置" -ForegroundColor Yellow
        $reconfigure = Read-Host "是否重新配置签名? (y/N)"
        if ($reconfigure -eq "y" -or $reconfigure -eq "Y") {
            & "android/generate-keystore.ps1"
        }
    }
    
} else {
    Write-Host "❌ 签名配置不完整" -ForegroundColor Red
    Write-Host ""
    Write-Host "📝 需要执行以下步骤:" -ForegroundColor Yellow
    Write-Host "1. 生成密钥库文件"
    Write-Host "2. 创建配置文件"
    Write-Host "3. 验证签名配置"
    Write-Host ""
    
    $setupSigning = Read-Host "是否现在配置签名? (y/N)"
    if ($setupSigning -eq "y" -or $setupSigning -eq "Y") {
        Write-Host ""
        Write-Host "🔨 开始配置签名..." -ForegroundColor Yellow
        
        # 检查生成脚本是否存在
        if (Test-Path "android/generate-keystore.ps1") {
            & "android/generate-keystore.ps1"
        } else {
            Write-Host "❌ 错误: 未找到密钥库生成脚本" -ForegroundColor Red
            Write-Host "请确保 android/generate-keystore.ps1 文件存在" -ForegroundColor Yellow
        }
    } else {
        Write-Host ""
        Write-Host "📖 手动配置步骤:" -ForegroundColor Cyan
        Write-Host "1. 运行: cd android && .\generate-keystore.ps1"
        Write-Host "2. 按提示输入密钥信息"
        Write-Host "3. 重新运行此脚本验证配置"
        Write-Host ""
        Write-Host "📚 详细文档: docs/android_signing_guide.md" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "🔒 安全提醒:" -ForegroundColor Yellow
Write-Host "1. 请备份密钥库文件到安全位置"
Write-Host "2. 不要将密钥文件提交到版本控制"
Write-Host "3. 妥善保管密钥库密码"
Write-Host "4. 定期验证签名配置"
