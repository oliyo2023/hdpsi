# HD PSI 系统管理工具

本目录包含用于管理HD PSI系统的命令行工具。

## 编译

```bash
cd backend/cmd
go build -o hdpsi main.go user.go product.go
```

## 使用方法

```bash
# 查看帮助
./hdpsi --help

# 查看子命令帮助
./hdpsi user --help
./hdpsi product --help
./hdpsi batch --help
```

## 用户管理

### 创建用户

```bash
./hdpsi user create --username admin --password admin123 --name 管理员 --role admin
```

#### 选项

- `--username string` - 用户登录名 (必填)
- `--password string` - 用户密码 (必填)
- `--name string` - 用户姓名 (必填)
- `--email string` - 电子邮箱
- `--phone string` - 手机号码
- `--role string` - 用户角色 (admin/manager/staff/cashier/operator)
- `--store uint` - 所属店铺ID (0表示总部)

## 商品管理

### 创建单个商品

```bash
./hdpsi product create --sku "MS001" --name "男士休闲衬衫" --color "蓝色" --size "XL" --category "衬衫" --cost 80 --retail 199
```

#### 选项

- `--sku string` - 商品SKU编码 (必填)
- `--name string` - 商品名称 (必填)
- `--color string` - 商品颜色
- `--size string` - 商品尺码
- `--season string` - 商品季节
- `--category string` - 商品类别
- `--image string` - 商品图片URL
- `--cost float` - 成本价
- `--retail float` - 零售价

### 批量导入商品

```bash
./hdpsi batch --file products.csv
```

#### 选项

- `--file string` - CSV文件路径 (必填)

#### CSV文件格式

CSV文件必须包含标题行，且必须包含'sku'和'name'列。支持的列包括：

- sku - 商品SKU编码 (必填)
- name - 商品名称 (必填)
- color - 商品颜色
- size - 商品尺码
- season - 商品季节
- category - 商品类别
- image - 商品图片URL
- cost - 成本价
- retail - 零售价

### 模板文件

目录中提供了一个CSV模板文件 `products_template.csv`，可以作为参考。

## 注意事项

1. SKU必须唯一，系统会自动检查是否存在重复的SKU
2. 价格字段应为数字，不要包含货币符号
3. 批量导入时，如果某行数据有问题，该行会被跳过，其他行仍会继续处理
4. 导入完成后会显示成功和失败的记录数量
