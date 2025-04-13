-- 禁用外键约束检查
SET FOREIGN_KEY_CHECKS = 0;

-- 删除现有的系统设置表
DROP TABLE IF EXISTS system_settings;

-- 重新创建系统设置表
CREATE TABLE system_settings (
    id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    `key` VARCHAR(100) NOT NULL,
    value TEXT,
    `group` VARCHAR(50),
    user_id BIGINT UNSIGNED DEFAULT NULL,
    created_at DATETIME(3),
    updated_at DATETIME(3),
    INDEX idx_group (`group`),
    UNIQUE INDEX idx_key_group_user (`key`, `group`, user_id)
);

-- 重新启用外键约束检查
SET FOREIGN_KEY_CHECKS = 1;
