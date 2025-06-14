-- 创建商品图片表
CREATE TABLE IF NOT EXISTS product_images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    product_id INTEGER NOT NULL,
    url VARCHAR(255) NOT NULL,
    sort INTEGER DEFAULT 0,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- 创建索引以提高查询性能
CREATE INDEX IF NOT EXISTS idx_product_images_product_id ON product_images(product_id);
CREATE INDEX IF NOT EXISTS idx_product_images_sort ON product_images(sort);
CREATE INDEX IF NOT EXISTS idx_product_images_deleted_at ON product_images(deleted_at);

-- 创建复合索引用于按商品ID和排序查询
CREATE INDEX IF NOT EXISTS idx_product_images_product_sort ON product_images(product_id, sort);