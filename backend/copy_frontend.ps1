# 复制前端构建文件到后端public目录的PowerShell脚本

# 定义路径
$frontendDistPath = "../hd-psi-frontend/dist"
$backendPublicPath = "./public"

# 检查前端构建目录是否存在
if (-not (Test-Path $frontendDistPath)) {
    Write-Error "前端构建目录不存在: $frontendDistPath"
    Write-Error "请先在前端项目中运行 npm run build"
    exit 1
}

# 确保后端public目录存在
if (-not (Test-Path $backendPublicPath)) {
    New-Item -ItemType Directory -Path $backendPublicPath | Out-Null
    Write-Host "创建目录: $backendPublicPath"
}

# 清空public目录（保留目录本身）
Get-ChildItem -Path $backendPublicPath -Recurse | Remove-Item -Recurse -Force
Write-Host "清空目录: $backendPublicPath"

# 复制前端构建文件到后端public目录
Copy-Item -Path "$frontendDistPath\*" -Destination $backendPublicPath -Recurse
Write-Host "复制前端构建文件到: $backendPublicPath"

# 检查index.html是否存在
if (Test-Path "$backendPublicPath\index.html") {
    Write-Host "成功: index.html 已复制"
} else {
    Write-Error "错误: index.html 未找到"
    exit 1
}

Write-Host "前端文件集成完成!"
Write-Host "现在可以通过后端服务访问前端页面了"
