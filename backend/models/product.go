package models

import "time"

// Product 商品基础信息
type Product struct {
	ID          uint    `gorm:"primaryKey"`
	SKU         string  `gorm:"size:255;uniqueIndex"`
	Name        string  `gorm:"size:255;not null"`
	CategoryID  *uint   `gorm:"default:null"` // 商品类别ID
	BrandID     *uint   `gorm:"default:null"` // 品牌ID
	Image       string  `gorm:"size:255"`     // 主图
	Images      string  `gorm:"type:text"`    // 多张图片，JSON格式
	Description string  `gorm:"type:text"`    // 商品描述
	CostPrice   float64 // 成本价
	RetailPrice float64 // 零售价
	Status      bool    `gorm:"default:true"` // 状态：上架/下架
	CreatedAt   time.Time
	UpdatedAt   time.Time

	// 关联
	Category DictionaryItem   // 商品类别
	Brand    DictionaryItem   // 品牌
	Variants []ProductVariant // 商品变体（不同颜色、尺码等）
}

// ProductVariant 商品变体（SKU级别）
type ProductVariant struct {
	ID          uint    `gorm:"primaryKey"`
	ProductID   uint    `gorm:"not null;index"`       // 关联的商品ID
	SKU         string  `gorm:"size:255;uniqueIndex"` // 变体SKU
	ColorID     *uint   `gorm:"default:null"`         // 颜色ID
	SizeID      *uint   `gorm:"default:null"`         // 尺码ID
	SeasonID    *uint   `gorm:"default:null"`         // 季节ID
	FabricID    *uint   `gorm:"default:null"`         // 面料ID
	Barcode     string  `gorm:"size:100"`             // 条形码
	QRCode      string  `gorm:"size:255"`             // 二维码数据
	CostPrice   float64 // 成本价（可能与主商品不同）
	RetailPrice float64 // 零售价（可能与主商品不同）
	Status      bool    `gorm:"default:true"` // 状态：启用/禁用
	CreatedAt   time.Time
	UpdatedAt   time.Time

	// 关联
	Product Product        // 商品
	Color   DictionaryItem // 颜色
	Size    DictionaryItem // 尺码
	Season  DictionaryItem // 季节
	Fabric  DictionaryItem // 面料
}
