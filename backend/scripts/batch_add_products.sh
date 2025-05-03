#!/bin/bash

# 运行批量导入商品命令行工具
go run cmd/main.go cmd/user.go cmd/product.go batch "$@"
