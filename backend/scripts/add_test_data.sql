-- 添加测试数据

-- 添加测试商品
INSERT INTO products (sku, name, description, image, cost_price, retail_price, created_at, updated_at)
VALUES 
('SKU001', '男士衬衫', '高品质棉质男士衬衫', '/images/products/shirt1.jpg', 80.00, 199.00, NOW(), NOW()),
('SKU002', '女士连衣裙', '时尚女士连衣裙', '/images/products/dress1.jpg', 120.00, 299.00, NOW(), NOW()),
('SKU003', '男士休闲裤', '舒适男士休闲裤', '/images/products/pants1.jpg', 90.00, 229.00, NOW(), NOW()),
('SKU004', '女士T恤', '时尚女士T恤', '/images/products/tshirt1.jpg', 50.00, 129.00, NOW(), NOW()),
('SKU005', '男士夹克', '保暖男士夹克', '/images/products/jacket1.jpg', 150.00, 399.00, NOW(), NOW());

-- 添加测试会员
INSERT INTO members (name, phone, email, gender, birthday, points, level, created_at, updated_at)
VALUES 
('张三', '13800138001', 'zhangsan@example.com', '男', '1990-01-01', 100, 1, NOW(), NOW()),
('李四', '13800138002', 'lisi@example.com', '女', '1992-02-02', 200, 1, NOW(), NOW()),
('王五', '13800138003', 'wangwu@example.com', '男', '1985-03-03', 500, 2, NOW(), NOW()),
('赵六', '13800138004', 'zhaoliu@example.com', '女', '1988-04-04', 1000, 3, NOW(), NOW()),
('钱七', '13800138005', 'qianqi@example.com', '男', '1995-05-05', 50, 1, NOW(), NOW());

-- 添加测试店铺
INSERT INTO stores (name, address, phone, manager, created_at, updated_at)
VALUES 
('总店', '北京市朝阳区建国路88号', '010-12345678', '张经理', NOW(), NOW()),
('分店1', '上海市静安区南京西路66号', '021-87654321', '李经理', NOW(), NOW()),
('分店2', '广州市天河区天河路55号', '020-98765432', '王经理', NOW(), NOW());

-- 添加测试库存
INSERT INTO inventories (product_id, store_id, quantity, created_at, updated_at)
VALUES 
(1, 1, 100, NOW(), NOW()),
(1, 2, 50, NOW(), NOW()),
(1, 3, 30, NOW(), NOW()),
(2, 1, 80, NOW(), NOW()),
(2, 2, 40, NOW(), NOW()),
(2, 3, 20, NOW(), NOW()),
(3, 1, 60, NOW(), NOW()),
(3, 2, 30, NOW(), NOW()),
(3, 3, 15, NOW(), NOW()),
(4, 1, 120, NOW(), NOW()),
(4, 2, 60, NOW(), NOW()),
(4, 3, 30, NOW(), NOW()),
(5, 1, 40, NOW(), NOW()),
(5, 2, 20, NOW(), NOW()),
(5, 3, 10, NOW(), NOW());

-- 添加测试销售订单
INSERT INTO sales_orders (order_number, store_id, member_id, total_amount, status, created_at, updated_at)
VALUES 
('SO20250401001', 1, 1, 199.00, 'completed', NOW(), NOW()),
('SO20250401002', 2, 2, 299.00, 'completed', NOW(), NOW()),
('SO20250401003', 3, 3, 229.00, 'processing', NOW(), NOW()),
('SO20250401004', 1, 4, 129.00, 'completed', NOW(), NOW()),
('SO20250401005', 2, 5, 399.00, 'pending', NOW(), NOW());
