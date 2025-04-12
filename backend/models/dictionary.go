package models

import "time"

// Dictionary 字典类型表
type Dictionary struct {
	ID          uint      `gorm:"primaryKey"`
	Code        string    `gorm:"size:50;uniqueIndex;not null"` // 字典类型编码
	Name        string    `gorm:"size:100;not null"`            // 字典类型名称
	Description string    `gorm:"size:255"`                     // 描述
	Sort        int       `gorm:"default:0"`                    // 排序
	Status      bool      `gorm:"default:true"`                 // 状态：启用/禁用
	CreatedAt   time.Time
	UpdatedAt   time.Time

	// 关联
	Items []DictionaryItem `gorm:"foreignKey:DictionaryCode;references:Code"` // 字典项
}

// DictionaryItem 字典项表
type DictionaryItem struct {
	ID             uint      `gorm:"primaryKey"`
	DictionaryCode string    `gorm:"size:50;not null;index"` // 关联的字典类型编码
	Code           string    `gorm:"size:50;not null"`       // 字典项编码
	Name           string    `gorm:"size:100;not null"`      // 字典项名称
	Value          string    `gorm:"size:255"`               // 字典项值
	Color          string    `gorm:"size:20"`                // 颜色值（用于前端展示）
	Sort           int       `gorm:"default:0"`              // 排序
	Status         bool      `gorm:"default:true"`           // 状态：启用/禁用
	Description    string    `gorm:"size:255"`               // 描述
	CreatedAt      time.Time
	UpdatedAt      time.Time

	// 关联
	Dictionary Dictionary `gorm:"foreignKey:DictionaryCode;references:Code"` // 所属字典类型
}

// 定义常用的字典类型编码常量
const (
	DictCategory = "category" // 商品类别
	DictColor    = "color"    // 颜色
	DictSize     = "size"     // 尺码
	DictSeason   = "season"   // 季节
	DictBrand    = "brand"    // 品牌
	DictFabric   = "fabric"   // 面料
)
