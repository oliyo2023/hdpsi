package models

import (
	"time"

	"gorm.io/gorm"
)

// Product 商品基础信息
type Product struct {
	ID          uint           `json:"ID" gorm:"primaryKey"`
	SKU         string         `json:"SKU" gorm:"size:255;uniqueIndex"`
	Name        string         `json:"Name" gorm:"size:255;not null"`
	CategoryID  *uint          `json:"CategoryID" gorm:"default:null"`   // 商品类别ID
	BrandID     *uint          `json:"BrandID" gorm:"default:null"`      // 品牌ID
	Image       string         `json:"Image" gorm:"size:255"`            // 主图
	Images      []string       `json:"Images" gorm:"-"`                  // 多张图片，不存储在数据库中，使用ProductImage关联
	ImagesJSON  string         `json:"-" gorm:"column:images;type:text"` // 兼容旧版本，存储JSON格式的图片列表
	Description string         `json:"Description" gorm:"type:text"`     // 商品描述
	CostPrice   float64        `json:"CostPrice"`                        // 成本价
	RetailPrice float64        `json:"RetailPrice"`                      // 零售价
	Status      bool           `json:"Status" gorm:"default:true"`       // 状态：上架/下架
	CreatedAt   time.Time      `json:"CreatedAt"`
	UpdatedAt   time.Time      `json:"UpdatedAt"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联
	Category      *DictionaryItem  `json:"Category,omitempty" gorm:"foreignKey:CategoryID"` // 商品类别
	Brand         *DictionaryItem  `json:"Brand,omitempty" gorm:"foreignKey:BrandID"`       // 品牌
	ProductImages []ProductImage   `json:"-" gorm:"foreignKey:ProductID"`                   // 商品图片
	Variants      []ProductVariant `json:"Variants,omitempty" gorm:"foreignKey:ProductID"`  // 商品变体
}

// ProductImage 商品图片模型
type ProductImage struct {
	ID        uint           `json:"ID" gorm:"primaryKey"`
	ProductID uint           `json:"ProductID" gorm:"index;not null"`
	URL       string         `json:"URL" gorm:"size:255;not null"`
	Sort      int            `json:"Sort" gorm:"default:0"` // 排序顺序
	CreatedAt time.Time      `json:"CreatedAt"`
	UpdatedAt time.Time      `json:"UpdatedAt"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

// ProductVariant 商品变体（SKU级别）
type ProductVariant struct {
	ID          uint           `json:"ID" gorm:"primaryKey"`
	ProductID   uint           `json:"ProductID" gorm:"not null;index"` // 关联的商品ID
	SKU         string         `json:"SKU" gorm:"size:255;uniqueIndex"` // 变体SKU
	ColorID     *uint          `json:"ColorID" gorm:"default:null"`     // 颜色ID
	SizeID      *uint          `json:"SizeID" gorm:"default:null"`      // 尺码ID
	SeasonID    *uint          `json:"SeasonID" gorm:"default:null"`    // 季节ID
	FabricID    *uint          `json:"FabricID" gorm:"default:null"`    // 面料ID
	Barcode     string         `json:"Barcode" gorm:"size:100"`         // 条形码
	QRCode      string         `json:"QRCode" gorm:"size:255"`          // 二维码数据
	CostPrice   float64        `json:"CostPrice"`                       // 成本价（可能与主商品不同）
	RetailPrice float64        `json:"RetailPrice"`                     // 零售价（可能与主商品不同）
	Status      bool           `json:"Status" gorm:"default:true"`      // 状态：启用/禁用
	CreatedAt   time.Time      `json:"CreatedAt"`
	UpdatedAt   time.Time      `json:"UpdatedAt"`
	DeletedAt   gorm.DeletedAt `json:"-" gorm:"index"`

	// 关联
	Product *Product        `json:"-" gorm:"foreignKey:ProductID"`               // 商品
	Color   *DictionaryItem `json:"Color,omitempty" gorm:"foreignKey:ColorID"`   // 颜色
	Size    *DictionaryItem `json:"Size,omitempty" gorm:"foreignKey:SizeID"`     // 尺码
	Season  *DictionaryItem `json:"Season,omitempty" gorm:"foreignKey:SeasonID"` // 季节
	Fabric  *DictionaryItem `json:"Fabric,omitempty" gorm:"foreignKey:FabricID"` // 面料
}
