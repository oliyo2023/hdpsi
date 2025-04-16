# 构建包含前端资源的后端可执行文件的PowerShell脚本

# 定义路径
$frontendDistPath = "../hd-psi-frontend/dist"
$backendEmbedPath = "./embed/public"

# 检查前端构建目录是否存在
if (-not (Test-Path $frontendDistPath)) {
    Write-Error "前端构建目录不存在: $frontendDistPath"
    Write-Error "请先在前端项目中运行 npm run build"
    exit 1
}

# 确保embed/public目录存在
if (-not (Test-Path $backendEmbedPath)) {
    New-Item -ItemType Directory -Path $backendEmbedPath | Out-Null
    Write-Host "创建目录: $backendEmbedPath"
}

# 清空embed/public目录（保留目录本身）
Get-ChildItem -Path $backendEmbedPath -Recurse | Remove-Item -Recurse -Force
Write-Host "清空目录: $backendEmbedPath"

# 复制前端构建文件到embed/public目录
Copy-Item -Path "$frontendDistPath\*" -Destination $backendEmbedPath -Recurse
Write-Host "复制前端构建文件到: $backendEmbedPath"

# 检查index.html是否存在
if (Test-Path "$backendEmbedPath\index.html") {
    Write-Host "成功: index.html 已复制"
} else {
    Write-Error "错误: index.html 未找到"
    exit 1
}

# 构建后端可执行文件
Write-Host "开始构建后端可执行文件..."
go build -o hdpsi.exe
if ($LASTEXITCODE -ne 0) {
    Write-Error "构建失败"
    exit 1
}

Write-Host "构建成功: hdpsi.exe"
Write-Host "前端资源已嵌入到可执行文件中"
Write-Host "可以直接运行 hdpsi.exe 启动完整应用"
