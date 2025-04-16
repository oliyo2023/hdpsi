#!/bin/bash

# 运行创建用户命令行工具
go run cmd/main.go cmd/user.go cmd/product.go user create "$@"
