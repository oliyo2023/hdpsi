# 检查未使用的依赖包脚本
# 分析项目中实际使用的依赖包

Write-Host "🔍 检查项目中未使用的依赖包..." -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Green
Write-Host ""

# 定义要检查的依赖包
$dependencies = @(
    @{Name="fluwx"; ImportPattern="package:fluwx"; Description="微信SDK"},
    @{Name="dio"; ImportPattern="package:dio"; Description="网络请求库"},
    @{Name="http"; ImportPattern="package:http"; Description="HTTP客户端"},
    @{Name="http_parser"; ImportPattern="package:http_parser"; Description="HTTP解析器"},
    @{Name="flutter_form_builder"; ImportPattern="package:flutter_form_builder"; Description="表单构建器"},
    @{Name="form_builder_validators"; ImportPattern="package:form_builder_validators"; Description="表单验证器"},
    @{Name="flutter_easyloading"; ImportPattern="package:flutter_easyloading"; Description="加载提示"},
    @{Name="mobile_scanner"; ImportPattern="package:mobile_scanner"; Description="扫码功能"},
    @{Name="image_picker"; ImportPattern="package:image_picker"; Description="图片选择"},
    @{Name="cached_network_image"; ImportPattern="package:cached_network_image"; Description="网络图片缓存"},
    @{Name="permission_handler"; ImportPattern="package:permission_handler"; Description="权限管理"},
    @{Name="flutter_secure_storage"; ImportPattern="package:flutter_secure_storage"; Description="安全存储"},
    @{Name="shared_preferences"; ImportPattern="package:shared_preferences"; Description="本地存储"},
    @{Name="get"; ImportPattern="package:get"; Description="状态管理"},
    @{Name="intl"; ImportPattern="package:intl"; Description="国际化"},
    @{Name="json_annotation"; ImportPattern="package:json_annotation"; Description="JSON注解"},
    @{Name="cupertino_icons"; ImportPattern="CupertinoIcons"; Description="iOS风格图标"}
)

$unusedDependencies = @()
$usedDependencies = @()

Write-Host "📊 分析依赖使用情况:" -ForegroundColor Cyan
Write-Host ""

foreach ($dep in $dependencies) {
    Write-Host "检查 $($dep.Name)..." -ForegroundColor Yellow
    
    # 搜索导入语句
    $importFound = $false
    $files = Get-ChildItem -Path "lib" -Recurse -Filter "*.dart" -ErrorAction SilentlyContinue
    
    foreach ($file in $files) {
        $content = Get-Content $file.FullName -Raw -ErrorAction SilentlyContinue
        if ($content -and $content -match $dep.ImportPattern) {
            $importFound = $true
            break
        }
    }
    
    if ($importFound) {
        $usedDependencies += $dep
        Write-Host "  ✅ 使用中" -ForegroundColor Green
    } else {
        $unusedDependencies += $dep
        Write-Host "  ❌ 未使用" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "📋 分析结果:" -ForegroundColor Green
Write-Host ""

if ($usedDependencies.Count -gt 0) {
    Write-Host "✅ 正在使用的依赖 ($($usedDependencies.Count)个):" -ForegroundColor Green
    foreach ($dep in $usedDependencies) {
        Write-Host "  • $($dep.Name) - $($dep.Description)" -ForegroundColor Cyan
    }
    Write-Host ""
}

if ($unusedDependencies.Count -gt 0) {
    Write-Host "❌ 未使用的依赖 ($($unusedDependencies.Count)个):" -ForegroundColor Red
    foreach ($dep in $unusedDependencies) {
        Write-Host "  • $($dep.Name) - $($dep.Description)" -ForegroundColor Yellow
    }
    Write-Host ""
    
    Write-Host "💡 建议移除的依赖:" -ForegroundColor Yellow
    foreach ($dep in $unusedDependencies) {
        Write-Host "  $($dep.Name): ^版本号" -ForegroundColor Gray
    }
    Write-Host ""
    
    Write-Host "⚠️ 注意事项:" -ForegroundColor Yellow
    Write-Host "1. 移除前请确认这些包确实不需要"
    Write-Host "2. 某些包可能在特定条件下使用（如平台特定代码）"
    Write-Host "3. 建议逐个移除并测试应用功能"
    Write-Host "4. 移除后运行 'flutter pub get' 更新依赖"
    
} else {
    Write-Host "🎉 所有依赖都在使用中，无需移除!" -ForegroundColor Green
}

Write-Host ""
Write-Host "📱 预估体积减少:" -ForegroundColor Cyan

$totalSavings = 0
foreach ($dep in $unusedDependencies) {
    $savings = switch ($dep.Name) {
        "fluwx" { 8 }
        "flutter_form_builder" { 2 }
        "form_builder_validators" { 1 }
        "flutter_easyloading" { 1 }
        "dio" { 1 }
        "http_parser" { 0.5 }
        default { 0.5 }
    }
    $totalSavings += $savings
    Write-Host "  $($dep.Name): ~$($savings)MB" -ForegroundColor Gray
}

if ($totalSavings -gt 0) {
    Write-Host ""
    Write-Host "💾 总计可减少: ~$($totalSavings)MB" -ForegroundColor Green
}

Write-Host ""
Write-Host "🔧 下一步操作:" -ForegroundColor Yellow
Write-Host "1. 检查分析结果"
Write-Host "2. 确认要移除的依赖"
Write-Host "3. 编辑 pubspec.yaml 文件"
Write-Host "4. 运行 'flutter pub get'"
Write-Host "5. 测试应用功能"
Write-Host "6. 重新构建应用"
