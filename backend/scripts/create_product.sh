#!/bin/bash

# 运行创建商品命令行工具
go run cmd/main.go cmd/user.go cmd/product.go product create "$@"
