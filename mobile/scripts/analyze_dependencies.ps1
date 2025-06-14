# 依赖包分析脚本
# 分析哪些依赖包可能导致 APK 体积过大

Write-Host "📊 分析项目依赖包..." -ForegroundColor Green

# 1. 显示所有依赖
Write-Host "📦 当前依赖包列表:" -ForegroundColor Yellow
flutter pub deps --style=compact

Write-Host ""
Write-Host "🔍 大型依赖包分析:" -ForegroundColor Yellow

# 2. 分析可能的大型依赖
$largeDependencies = @(
    @{Name="fluwx"; Description="微信SDK"; Size="~5-10MB"; Suggestion="如果不需要微信登录可以移除"},
    @{Name="mobile_scanner"; Description="扫码功能"; Size="~3-5MB"; Suggestion="必要功能，保留"},
    @{Name="image_picker"; Description="图片选择"; Size="~2-3MB"; Suggestion="必要功能，保留"},
    @{Name="cached_network_image"; Description="网络图片缓存"; Size="~1-2MB"; Suggestion="优化用户体验，建议保留"},
    @{Name="permission_handler"; Description="权限管理"; Size="~1-2MB"; Suggestion="必要功能，保留"},
    @{Name="flutter_secure_storage"; Description="安全存储"; Size="~1MB"; Suggestion="安全功能，建议保留"},
    @{Name="openapi_generator"; Description="API代码生成"; Size="~2-3MB"; Suggestion="开发工具，生产环境可优化"}
)

foreach ($dep in $largeDependencies) {
    Write-Host "• $($dep.Name)" -ForegroundColor Cyan
    Write-Host "  描述: $($dep.Description)" -ForegroundColor Gray
    Write-Host "  预估大小: $($dep.Size)" -ForegroundColor Gray
    Write-Host "  建议: $($dep.Suggestion)" -ForegroundColor Gray
    Write-Host ""
}

Write-Host "💡 优化建议:" -ForegroundColor Green
Write-Host "1. 检查是否真的需要微信登录功能 (fluwx)"
Write-Host "2. 考虑使用更轻量的替代方案"
Write-Host "3. 移除 dev_dependencies 中不必要的包"
Write-Host "4. 使用 tree-shaking 移除未使用的代码"

Write-Host ""
Write-Host "🔧 可以移除的开发依赖:" -ForegroundColor Yellow
Write-Host "• openapi_generator_cli (仅开发时需要)"
Write-Host "• build_runner (仅开发时需要)"
Write-Host "• json_serializable (仅开发时需要)"

Write-Host ""
Write-Host "📱 运行以下命令查看详细的包大小分析:"
Write-Host "flutter build apk --analyze-size" -ForegroundColor Cyan
