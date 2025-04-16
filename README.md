# 服装进销存系统 (HD-PSI)

基于 Go + Vue 3 开发的服装行业进销存管理系统，采用前后端分离架构，专为男女装店铺设计的全流程管理解决方案。

## 项目概述

HD-PSI 是一套专为服装零售行业设计的进销存管理系统，支持多店铺管理、商品全生命周期追踪、智能库存预警、会员管理等功能，满足服装零售企业的日常运营需求。

### 核心特点

- **多店铺管理**：支持男女装店铺独立核算，统一管理
- **商品全生命周期**：从采购、入库、销售到退换货的全流程追踪
- **智能库存管理**：基于品类和店铺的双重库存预警机制
- **会员数据分析**：记录会员体型数据、消费习惯，提供智能推荐
- **二维码管理**：基于 SKU + 批次的唯一加密二维码，支持防伪验证

## 技术栈

### 后端
- **语言框架**：Go 1.21 + Gin 1.9.1
- **数据库**：MySQL 8.0 + GORM 1.25.5
- **认证**：JWT 认证
- **API**：RESTful API

### 前端
- **框架**：Vue 3 + Vite
- **UI 库**：Naive UI
- **HTTP 客户端**：Axios
- **路由**：Vue Router
- **状态管理**：Pinia

## 功能模块

### 1. 库存管理
- ✅ 分店库存独立核算
- ✅ 品类库存分类预警
- ✅ 入库管理（采购/退货/调拨）
- ✅ 二维码生成与验证
- ✅ 出库管理（销售/换货/报损）
- ✅ 库存预警机制
- 🚧 库存盘点

### 2. 商品档案管理
- ✅ 基础属性管理
- ✅ SKU 编码规则
- ✅ 商品图片管理
- ✅ 价格体系管理

### 3. 采购管理
- ✅ 供应商管理
- 🚧 采购订单流程
- 🚧 到货验收
- 🚧 货源追踪

### 4. 销售管理
- 🚧 零售终端集成
- 🚧 订单统一管理
- 🚧 移动扫码功能
- 🚧 价格同步机制
- 🚧 议价日志
- 🚧 试衣记录
- 🚧 退换货流程

### 5. 会员管理
- ✅ 顾客档案
- 🚧 积分体系
- 🚧 消费历史
- 🚧 智能推荐

## 项目结构

```
hd_psi/
├── backend/                # Go 后端项目
│   ├── cmd/                # 命令行工具
│   ├── config/             # 配置文件
│   ├── controllers/        # 控制器
│   ├── middleware/         # 中间件
│   ├── models/             # 数据模型
│   ├── routes/             # 路由配置
│   ├── utils/              # 工具类
│   ├── go.mod              # Go 模块文件
│   └── main.go             # 程序入口
│
└── hd-psi-frontend/        # Vue 前端项目
    ├── public/             # 静态资源
    ├── src/                # 源代码
    │   ├── assets/         # 资源文件
    │   ├── components/     # 公共组件
    │   ├── router/         # 路由配置
    │   ├── services/       # API 服务
    │   ├── store/          # 状态管理
    │   ├── views/          # 页面组件
    │   ├── App.vue         # 根组件
    │   └── main.js         # 入口文件
    ├── index.html          # HTML 模板
    ├── package.json        # 项目配置
    └── vite.config.js      # Vite 配置
```

## 开发环境搭建

### 后端

1. 进入后端目录
```bash
cd backend
```

2. 安装依赖
```bash
go mod tidy
```

3. 运行后端服务
```bash
go run main.go
```

### 前端

1. 进入前端目录
```bash
cd hd-psi-frontend
```

2. 安装依赖
```bash
npm install
```

3. 运行开发服务器
```bash
npm run dev
```

4. 构建生产版本
```bash
npm run build
```

## API 文档

后端 API 遵循 RESTful 设计原则，主要包括以下资源：

- `/api/auth` - 认证相关
- `/api/products` - 商品管理
- `/api/suppliers` - 供应商管理
- `/api/inventory` - 库存管理
- `/api/purchases` - 采购管理
- `/api/sales` - 销售管理
- `/api/members` - 会员管理
- `/api/stores` - 店铺管理

详细 API 文档请参考后端代码或 Swagger 文档。

## 部署指南

### 集成部署（推荐）

将前端静态文件集成到后端服务中，只需要一个服务器即可运行完整系统。

1. 构建前端
```bash
cd hd-psi-frontend
npm run build
```

2. 将前端构建文件复制到后端

Windows环境：
```powershell
cd backend
.\copy_frontend.ps1
```

Linux/Mac环境：
```bash
cd backend
chmod +x copy_frontend.sh
./copy_frontend.sh
```

3. 构建并运行后端服务
```bash
cd backend
go build -o hd-psi-server
./hd-psi-server
```

4. 访问系统
浏览器访问：`http://localhost:8080`

### Docker 部署

1. 构建后端镜像
```bash
cd backend
docker build -t hd-psi-backend .
```

2. 构建前端镜像
```bash
cd hd-psi-frontend
docker build -t hd-psi-frontend .
```

3. 使用 Docker Compose 启动服务
```bash
docker-compose up -d
```

### 分离部署

1. 后端部署
```bash
cd backend
go build -o hd-psi-backend
./hd-psi-backend
```

2. 前端部署
```bash
cd hd-psi-frontend
npm run build
# 将 dist 目录部署到 Nginx 或其他 Web 服务器
```

## 开发计划

- **第一阶段**：基础功能开发（已完成）
  - 用户认证
  - 商品管理
  - 供应商管理
  - 基础库存管理

- **第二阶段**：核心业务功能（进行中）
  - 采购管理
  - 销售管理
  - 库存盘点
  - 会员管理

- **第三阶段**：高级功能（计划中）
  - 数据分析看板
  - 微信小程序集成
  - 智能试衣镜接口
  - 电子价签管理

## 贡献指南

1. Fork 本仓库
2. 创建功能分支 (`git checkout -b feature/amazing-feature`)
3. 提交更改 (`git commit -m 'Add some amazing feature'`)
4. 推送到分支 (`git push origin feature/amazing-feature`)
5. 创建 Pull Request

## 许可证

本项目采用 MIT 许可证 - 详情请参阅 LICENSE 文件
