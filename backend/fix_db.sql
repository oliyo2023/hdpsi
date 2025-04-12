-- 禁用外键约束检查
SET FOREIGN_KEY_CHECKS = 0;

-- 删除现有的表
DROP TABLE IF EXISTS product_variants;
DROP TABLE IF EXISTS products;

-- 重新创建商品表
CREATE TABLE products (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    sku VARCHAR(255) UNIQUE,
    name VARCHAR(255) NOT NULL,
    category_id BIGINT UNSIGNED,
    brand_id BIGINT UNSIGNED,
    image VARCHAR(255),
    images TEXT,
    description TEXT,
    cost_price DOUBLE,
    retail_price DOUBLE,
    status BOOLEAN DEFAULT TRUE,
    created_at DATETIME(3),
    updated_at DATETIME(3)
);

-- 创建商品变体表
CREATE TABLE product_variants (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    product_id BIGINT UNSIGNED NOT NULL,
    sku VARCHAR(255) UNIQUE,
    color_id BIGINT UNSIGNED,
    size_id BIGINT UNSIGNED,
    season_id BIGINT UNSIGNED,
    fabric_id BIGINT UNSIGNED,
    barcode VARCHAR(100),
    qr_code VARCHAR(255),
    cost_price DOUBLE,
    retail_price DOUBLE,
    status BOOLEAN DEFAULT TRUE,
    created_at DATETIME(3),
    updated_at DATETIME(3),
    INDEX idx_product_variants_product_id (product_id)
);

-- 添加测试数据
INSERT INTO products (sku, name, cost_price, retail_price, status) VALUES 
    ('MS001', '男士休闲衬衫', 80, 199, TRUE),
    ('WD001', '女士连衣裙', 120, 299, TRUE),
    ('MT001', '男士T恤', 50, 129, TRUE),
    ('WS001', '女士衬衫', 70, 179, TRUE),
    ('MJ001', '男士牛仔裤', 100, 259, TRUE);

-- 重新启用外键约束检查
SET FOREIGN_KEY_CHECKS = 1;
