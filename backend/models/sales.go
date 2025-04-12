package models

import "time"

// OrderSource 订单来源
type OrderSource string

const (
	InStore OrderSource = "in_store" // 店内销售
	Online  OrderSource = "online"   // 线上销售
	WeChat  OrderSource = "wechat"   // 微信小程序
)

// OrderStatus 订单状态
type OrderStatus string

const (
	Created        OrderStatus = "created"   // 已创建
	Paid           OrderStatus = "paid"      // 已支付
	Shipped        OrderStatus = "shipped"   // 已发货
	OrderCompleted OrderStatus = "completed" // 已完成
	OrderCancelled OrderStatus = "cancelled" // 已取消
	Returned       OrderStatus = "returned"  // 已退货
)

// PaymentMethod 支付方式
type PaymentMethod string

const (
	Cash      PaymentMethod = "cash"       // 现金
	WeChatPay PaymentMethod = "wechat_pay" // 微信支付
	AliPay    PaymentMethod = "alipay"     // 支付宝
	BankCard  PaymentMethod = "bank_card"  // 银行卡
	Points    PaymentMethod = "points"     // 积分抵扣
)

// SalesOrder 销售订单
type SalesOrder struct {
	ID             uint          `gorm:"primaryKey"`
	OrderNumber    string        `gorm:"size:50;uniqueIndex"` // 订单编号
	StoreID        uint          `gorm:"not null"`            // 销售店铺ID
	MemberID       *uint         // 会员ID，非会员为空
	Source         OrderSource   `gorm:"size:20;not null"`                   // 订单来源
	Status         OrderStatus   `gorm:"size:20;not null;default:'created'"` // 订单状态
	TotalAmount    float64       `gorm:"not null"`                           // 订单总金额
	DiscountAmount float64       // 折扣金额
	ActualAmount   float64       `gorm:"not null"` // 实付金额
	PaymentMethod  PaymentMethod `gorm:"size:20"`  // 支付方式
	PointsUsed     int           // 使用的积分
	PointsEarned   int           // 获得的积分
	SalesPersonID  uint          // 销售人员ID
	FittingRoomID  *uint         // 试衣间ID
	Note           string        `gorm:"size:255"` // 订单备注
	CreatedAt      time.Time
	UpdatedAt      time.Time
}

// SalesOrderItem 销售订单明细
type SalesOrderItem struct {
	ID               uint    `gorm:"primaryKey"`
	OrderID          uint    `gorm:"not null"` // 订单ID
	ProductID        uint    `gorm:"not null"` // 商品ID
	ProductVariantID uint    `gorm:"not null"` // 商品变体ID
	Quantity         int     `gorm:"not null"` // 数量
	RetailPrice      float64 `gorm:"not null"` // 零售价
	ActualPrice      float64 `gorm:"not null"` // 实际售价
	DiscountAmount   float64 // 折扣金额
	QRCodeData       string  `gorm:"size:255"` // 商品二维码数据
	CreatedAt        time.Time
	UpdatedAt        time.Time

	// 关联
	Product        Product        `gorm:"foreignKey:ProductID"`
	ProductVariant ProductVariant `gorm:"foreignKey:ProductVariantID"`
}

// NegotiationRecord 议价记录
type NegotiationRecord struct {
	ID               uint    `gorm:"primaryKey"`
	OrderID          uint    `gorm:"not null"` // 订单ID
	OrderItemID      uint    `gorm:"not null"` // 订单明细ID
	InitialPrice     float64 `gorm:"not null"` // 初始报价
	FinalPrice       float64 `gorm:"not null"` // 最终成交价
	NegotiationCount int     `gorm:"not null"` // 议价次数
	SalesPersonID    uint    `gorm:"not null"` // 销售人员ID
	Note             string  `gorm:"size:255"` // 备注
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

// FittingRecord 试衣记录
type FittingRecord struct {
	ID                uint   `gorm:"primaryKey"`
	MemberID          uint   `gorm:"not null"` // 会员ID
	ProductID         uint   `gorm:"not null"` // 商品ID
	ProductVariantID  uint   `gorm:"not null"` // 商品变体ID
	FittingRoomID     uint   `gorm:"not null"` // 试衣间ID
	StoreID           uint   `gorm:"not null"` // 店铺ID
	SatisfactionLevel int    // 满意度评分(1-5)
	BodyHeight        int    // 身高(cm)
	BodyWeight        int    // 体重(kg)
	ShoulderWidth     int    // 肩宽(cm)
	BustSize          int    // 胸围(cm)
	WaistSize         int    // 腰围(cm)
	HipSize           int    // 臀围(cm)
	Comments          string `gorm:"size:255"` // 试穿评价
	CreatedAt         time.Time
	UpdatedAt         time.Time

	// 关联
	Product        Product        `gorm:"foreignKey:ProductID"`
	ProductVariant ProductVariant `gorm:"foreignKey:ProductVariantID"`
}

// ReturnOrder 退换货单
type ReturnOrder struct {
	ID           uint    `gorm:"primaryKey"`
	OrderID      uint    `gorm:"not null"`            // 原订单ID
	ReturnNumber string  `gorm:"size:50;uniqueIndex"` // 退货单号
	StoreID      uint    `gorm:"not null"`            // 店铺ID
	MemberID     *uint   // 会员ID
	ReturnType   string  `gorm:"size:20;not null"` // 退货类型：退货/换货
	ReturnReason string  `gorm:"size:100"`         // 退货原因
	ReturnAmount float64 // 退款金额
	Status       string  `gorm:"size:20;not null;default:'pending'"` // 状态：待处理/已批准/已拒绝/已完成
	ProcessorID  uint    // 处理人ID
	Note         string  `gorm:"size:255"` // 备注
	CreatedAt    time.Time
	UpdatedAt    time.Time
}

// ReturnOrderItem 退换货单明细
type ReturnOrderItem struct {
	ID                uint    `gorm:"primaryKey"`
	ReturnOrderID     uint    `gorm:"not null"` // 退货单ID
	OrderItemID       uint    `gorm:"not null"` // 原订单明细ID
	ProductID         uint    `gorm:"not null"` // 商品ID
	ProductVariantID  uint    `gorm:"not null"` // 商品变体ID
	Quantity          int     `gorm:"not null"` // 数量
	ReturnPrice       float64 `gorm:"not null"` // 退货单价
	QRCodeData        string  `gorm:"size:255"` // 商品二维码数据
	ExchangeProductID *uint   // 换货商品ID，仅换货时有值
	ExchangeQuantity  *int    // 换货数量，仅换货时有值
	CreatedAt         time.Time
	UpdatedAt         time.Time

	// 关联
	Product        Product        `gorm:"foreignKey:ProductID"`
	ProductVariant ProductVariant `gorm:"foreignKey:ProductVariantID"`
}

// FittingRoom 试衣间
type FittingRoom struct {
	ID         uint   `gorm:"primaryKey"`
	StoreID    uint   `gorm:"not null"`                             // 店铺ID
	RoomNumber string `gorm:"size:20;not null"`                     // 试衣间编号
	Status     string `gorm:"size:20;not null;default:'available'"` // 状态：可用/占用/维修
	CreatedAt  time.Time
	UpdatedAt  time.Time
}
