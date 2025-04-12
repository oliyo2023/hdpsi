package models

import "time"

// AlertType 定义预警类型
type AlertType string

const (
	LowStock  AlertType = "low_stock" // 库存不足
	Overstock AlertType = "overstock" // 库存过多
)

// AlertStatus 定义预警状态
type AlertStatus string

const (
	Active   AlertStatus = "active"   // 活跃状态
	Resolved AlertStatus = "resolved" // 已解决
	Ignored  AlertStatus = "ignored"  // 已忽略
)

// InventoryAlert 库存预警模型
type InventoryAlert struct {
	ID               uint        `gorm:"primaryKey"`
	StoreID          uint        `gorm:"not null"`
	ProductVariantID uint        `gorm:"not null"`
	Category         string      `gorm:"size:50"` // 商品类别
	AlertType        AlertType   `gorm:"size:20;not null"`
	Threshold        int         `gorm:"not null"` // 预警阈值
	CurrentQty       int         `gorm:"not null"` // 当前库存
	Status           AlertStatus `gorm:"size:20;not null;default:'active'"`
	ResolvedAt       *time.Time  // 解决时间
	Description      string      `gorm:"size:255"` // 预警描述
	CreatedAt        time.Time
	UpdatedAt        time.Time

	// 关联
	Store          Store          `gorm:"foreignKey:StoreID"`
	ProductVariant ProductVariant `gorm:"foreignKey:ProductVariantID"`
}
