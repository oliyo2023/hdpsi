package models

import "time"

// Inventory 库存记录
type Inventory struct {
	ID               uint       `gorm:"primaryKey"`
	StoreID          uint       `gorm:"not null;index:idx_store_variant"` // 店铺ID
	ProductVariantID uint       `gorm:"not null;index:idx_store_variant"` // 商品变体ID
	Quantity         int        `gorm:"not null;default:0"`               // 库存数量
	AlertQuantity    int        `gorm:"default:0"`                        // 预警数量
	LastCheckTime    *time.Time // 最后盘点时间
	CreatedAt        time.Time
	UpdatedAt        time.Time

	// 关联
	Store          Store          `gorm:"foreignKey:StoreID"`          // 店铺
	ProductVariant ProductVariant `gorm:"foreignKey:ProductVariantID"` // 商品变体
}
