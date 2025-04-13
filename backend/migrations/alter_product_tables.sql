-- 修改products表的外键字段，使其可以接受NULL值
ALTER TABLE products MODIFY COLUMN category_id INT UNSIGNED NULL;
ALTER TABLE products MODIFY COLUMN brand_id INT UNSIGNED NULL;

-- 修改product_variants表的外键字段，使其可以接受NULL值
ALTER TABLE product_variants MODIFY COLUMN color_id INT UNSIGNED NULL;
ALTER TABLE product_variants MODIFY COLUMN size_id INT UNSIGNED NULL;
ALTER TABLE product_variants MODIFY COLUMN season_id INT UNSIGNED NULL;
ALTER TABLE product_variants MODIFY COLUMN fabric_id INT UNSIGNED NULL;
