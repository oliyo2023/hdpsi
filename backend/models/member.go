package models

import "time"

// MemberLevel 会员等级
type MemberLevel string

const (
	Regular  MemberLevel = "regular"  // 普通会员
	Silver   MemberLevel = "silver"   // 白银会员
	Gold     MemberLevel = "gold"     // 黄金会员
	Platinum MemberLevel = "platinum" // 铂金会员
	Diamond  MemberLevel = "diamond"  // 钻石会员
)

// StylePreference 风格偏好
type StylePreference string

const (
	Casual     StylePreference = "casual"     // 休闲
	Formal     StylePreference = "formal"     // 正式
	Sportswear StylePreference = "sportswear" // 运动
	Vintage    StylePreference = "vintage"    // 复古
	Minimalist StylePreference = "minimalist" // 极简
	Romantic   StylePreference = "romantic"   // 浪漫
	Bohemian   StylePreference = "bohemian"   // 波西米亚
	Street     StylePreference = "street"     // 街头
)

// ConsumptionLevel 消费能力
type ConsumptionLevel string

const (
	Low    ConsumptionLevel = "low"    // 低
	Medium ConsumptionLevel = "medium" // 中
	High   ConsumptionLevel = "high"   // 高
	Luxury ConsumptionLevel = "luxury" // 奢侈
)

type Member struct {
	ID               uint   `gorm:"primaryKey"`
	OpenID           string `gorm:"size:50;uniqueIndex"` // 微信 OpenID
	Name             string `gorm:"size:50;not null"`
	Phone            string `gorm:"size:20;uniqueIndex"`
	Gender           string `gorm:"size:10"`
	Birthday         *time.Time
	Email            string      `gorm:"size:100"`
	Address          string      `gorm:"size:255"`
	Level            MemberLevel `gorm:"size:20;default:'regular'"`
	Points           int         `gorm:"default:0"` // 积分
	TotalSpent       float64     `gorm:"default:0"` // 累计消费金额
	LastPurchaseDate *time.Time

	// 体型数据
	BodyHeight    int // 身高(cm)
	BodyWeight    int // 体重(kg)
	ShoulderWidth int // 肩宽(cm)
	BustSize      int // 胸围(cm)
	WaistSize     int // 腰围(cm)
	HipSize       int // 臀围(cm)
	Inseam        int // 内缝长度(cm)

	// 偏好数据
	StylePreference    StylePreference  `gorm:"size:20"`  // 风格偏好
	FavoriteColors     string           `gorm:"size:100"` // 喜欢的颜色，逗号分隔
	FavoriteCategories string           `gorm:"size:100"` // 喜欢的品类，逗号分隔
	ConsumptionLevel   ConsumptionLevel `gorm:"size:20"`  // 消费能力

	Note      string `gorm:"size:255"` // 备注
	CreatedAt time.Time
	UpdatedAt time.Time
}
