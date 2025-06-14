# 商品图片管理 API 文档

## 概述

本文档描述了服装商品图片管理的 API 接口，支持图片的上传、查看、排序和删除功能。

## 基础信息

- **基础URL**: `http://localhost:8081/api/v1`
- **认证方式**: Bearer Token (JWT)
- **支持的图片格式**: JPG, PNG, GIF, WebP
- **最大文件大小**: 10MB
- **图片存储路径**: `/uploads/products/YYYY/MM/DD/`

## API 接口

### 1. 获取商品图片列表

**请求**
```
GET /products/{product_id}/images
Authorization: Bearer {token}
```

**响应**
```json
[
  {
    "ID": 1,
    "ProductID": 123,
    "URL": "/uploads/products/2025/06/07/uuid.jpg",
    "Sort": 0,
    "CreatedAt": "2025-06-07T10:00:00Z",
    "UpdatedAt": "2025-06-07T10:00:00Z"
  }
]
```

### 2. 上传单张商品图片

**请求**
```
POST /products/{product_id}/images
Authorization: Bearer {token}
Content-Type: multipart/form-data

file: [图片文件]
sort: 0 (可选，排序顺序)
```

**响应**
```json
{
  "ID": 1,
  "ProductID": 123,
  "URL": "/uploads/products/2025/06/07/uuid.jpg",
  "Sort": 0,
  "CreatedAt": "2025-06-07T10:00:00Z",
  "UpdatedAt": "2025-06-07T10:00:00Z"
}
```

### 3. 批量上传商品图片

**请求**
```
POST /products/{product_id}/images/batch
Authorization: Bearer {token}
Content-Type: multipart/form-data

files: [多个图片文件]
```

**响应**
```json
{
  "uploaded_images": [
    {
      "ID": 1,
      "ProductID": 123,
      "URL": "/uploads/products/2025/06/07/uuid1.jpg",
      "Sort": 0,
      "CreatedAt": "2025-06-07T10:00:00Z",
      "UpdatedAt": "2025-06-07T10:00:00Z"
    }
  ],
  "success_count": 3,
  "error_count": 0,
  "errors": []
}
```

### 4. 更新图片排序

**请求**
```
PUT /products/{product_id}/images/{image_id}/sort
Authorization: Bearer {token}
Content-Type: application/json

{
  "sort": 1
}
```

**响应**
```json
{
  "ID": 1,
  "ProductID": 123,
  "URL": "/uploads/products/2025/06/07/uuid.jpg",
  "Sort": 1,
  "CreatedAt": "2025-06-07T10:00:00Z",
  "UpdatedAt": "2025-06-07T10:00:00Z"
}
```

### 5. 删除商品图片

**请求**
```
DELETE /products/{product_id}/images/{image_id}
Authorization: Bearer {token}
```

**响应**
```json
{
  "message": "图片删除成功"
}
```

## 错误响应

所有错误响应都遵循以下格式：

```json
{
  "error": "错误描述信息"
}
```

常见错误码：
- `400`: 请求参数错误
- `401`: 未授权访问
- `404`: 资源不存在
- `500`: 服务器内部错误

## 使用示例

### 使用 curl 上传图片

```bash
# 上传单张图片
curl -X POST \
  http://localhost:8081/api/v1/products/123/images \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -F 'file=@/path/to/image.jpg' \
  -F 'sort=0'

# 批量上传图片
curl -X POST \
  http://localhost:8081/api/v1/products/123/images/batch \
  -H 'Authorization: Bearer YOUR_TOKEN' \
  -F 'files=@/path/to/image1.jpg' \
  -F 'files=@/path/to/image2.jpg' \
  -F 'files=@/path/to/image3.jpg'
```

### 使用 JavaScript 上传图片

```javascript
// 上传单张图片
const formData = new FormData();
formData.append('file', fileInput.files[0]);
formData.append('sort', 0);

fetch('/api/v1/products/123/images', {
  method: 'POST',
  headers: {
    'Authorization': 'Bearer ' + token
  },
  body: formData
})
.then(response => response.json())
.then(data => console.log(data));

// 获取图片列表
fetch('/api/v1/products/123/images', {
  headers: {
    'Authorization': 'Bearer ' + token
  }
})
.then(response => response.json())
.then(images => {
  images.forEach(image => {
    console.log('图片URL:', image.URL);
  });
});
```

## 注意事项

1. **文件大小限制**: 单个图片文件不能超过 10MB
2. **批量上传限制**: 一次最多上传 10 张图片
3. **文件格式**: 仅支持 JPG、PNG、GIF、WebP 格式
4. **排序**: 图片按 `sort` 字段升序排列，相同 `sort` 值按创建时间排序
5. **文件存储**: 图片按年/月/日目录结构存储，文件名使用 UUID 避免冲突
6. **删除操作**: 删除图片时会同时删除数据库记录和文件系统中的文件