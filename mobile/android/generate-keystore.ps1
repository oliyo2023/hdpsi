# 宏店移动应用密钥库生成脚本 (Windows PowerShell)
# 使用此脚本生成用于应用签名的密钥库文件

Write-Host "🔐 宏店移动应用密钥库生成工具" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# 检查 Java keytool 是否可用
try {
    $null = Get-Command keytool -ErrorAction Stop
    Write-Host "✅ Java keytool 已找到" -ForegroundColor Green
} catch {
    Write-Host "❌ 错误: 未找到 Java keytool" -ForegroundColor Red
    Write-Host "请确保已安装 Java JDK 并添加到 PATH 环境变量" -ForegroundColor Yellow
    Write-Host "下载地址: https://adoptium.net/" -ForegroundColor Yellow
    exit 1
}

# 检查是否已存在密钥库文件
if (Test-Path "release-key.keystore") {
    Write-Host "⚠️ 警告: release-key.keystore 文件已存在!" -ForegroundColor Yellow
    $overwrite = Read-Host "是否要覆盖现有文件? (y/N)"
    if ($overwrite -ne "y" -and $overwrite -ne "Y") {
        Write-Host "操作已取消" -ForegroundColor Yellow
        exit 1
    }
}

Write-Host "📝 请输入以下信息来生成密钥库:" -ForegroundColor Cyan
Write-Host ""

# 获取用户输入
$keystorePassword = Read-Host "密钥库密码" -AsSecureString
$keystorePasswordConfirm = Read-Host "确认密钥库密码" -AsSecureString

# 转换为明文进行比较
$keystorePasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePassword))
$keystorePasswordConfirmText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keystorePasswordConfirm))

if ($keystorePasswordText -ne $keystorePasswordConfirmText) {
    Write-Host "❌ 错误: 密码不匹配!" -ForegroundColor Red
    exit 1
}

$keyAlias = Read-Host "密钥别名 (默认: hdpsi-release)"
if ([string]::IsNullOrEmpty($keyAlias)) {
    $keyAlias = "hdpsi-release"
}

$keyPassword = Read-Host "密钥密码 (可以与密钥库密码相同)" -AsSecureString
$keyPasswordText = [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($keyPassword))

Write-Host ""
Write-Host "📋 证书信息:" -ForegroundColor Cyan
$dnameCN = Read-Host "您的姓名"
$dnameOU = Read-Host "组织单位 (如: IT部门)"
$dnameO = Read-Host "组织名称 (如: 宏达服装)"
$dnameL = Read-Host "城市"
$dnameST = Read-Host "省份"
$dnameC = Read-Host "国家代码 (如: CN)"

# 构建DN字符串
$dname = "CN=$dnameCN, OU=$dnameOU, O=$dnameO, L=$dnameL, ST=$dnameST, C=$dnameC"

Write-Host ""
Write-Host "🔨 正在生成密钥库..." -ForegroundColor Yellow

# 生成密钥库
$keytoolArgs = @(
    "-genkey",
    "-v",
    "-keystore", "release-key.keystore",
    "-alias", $keyAlias,
    "-keyalg", "RSA",
    "-keysize", "2048",
    "-validity", "10000",
    "-storepass", $keystorePasswordText,
    "-keypass", $keyPasswordText,
    "-dname", $dname
)

try {
    & keytool @keytoolArgs
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host ""
        Write-Host "✅ 密钥库生成成功!" -ForegroundColor Green
        Write-Host "📁 文件位置: $(Get-Location)\release-key.keystore" -ForegroundColor Cyan
        
        # 创建 key.properties 文件
        $keyPropertiesContent = @"
# 应用签名配置
# 重要: 请勿将此文件提交到版本控制系统
MYAPP_RELEASE_STORE_FILE=release-key.keystore
MYAPP_RELEASE_STORE_PASSWORD=$keystorePasswordText
MYAPP_RELEASE_KEY_ALIAS=$keyAlias
MYAPP_RELEASE_KEY_PASSWORD=$keyPasswordText
"@
        
        $keyPropertiesContent | Out-File -FilePath "key.properties" -Encoding UTF8
        Write-Host "✅ key.properties 文件已创建" -ForegroundColor Green
        
        Write-Host ""
        Write-Host "📋 key.properties 内容:" -ForegroundColor Cyan
        Write-Host "MYAPP_RELEASE_STORE_FILE=release-key.keystore"
        Write-Host "MYAPP_RELEASE_STORE_PASSWORD=$keystorePasswordText"
        Write-Host "MYAPP_RELEASE_KEY_ALIAS=$keyAlias"
        Write-Host "MYAPP_RELEASE_KEY_PASSWORD=$keyPasswordText"
        
        Write-Host ""
        Write-Host "⚠️ 重要提醒:" -ForegroundColor Yellow
        Write-Host "1. 请妥善保管密钥库文件和密码"
        Write-Host "2. 请将 key.properties 添加到 .gitignore"
        Write-Host "3. 建议备份密钥库文件到安全位置"
        Write-Host "4. 密钥库密码丢失将无法更新应用"
        Write-Host "5. 现在可以重新构建发布版本"
        
    } else {
        Write-Host "❌ 密钥库生成失败!" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "❌ 密钥库生成失败: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
