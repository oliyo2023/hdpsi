package models

import (
	"time"

	"gorm.io/gorm"
)

// SalesOrderStatus 销售订单状态
type SalesOrderStatus string

const (
	SalesDraft      SalesOrderStatus = "draft"      // 草稿
	SalesPending    SalesOrderStatus = "pending"    // 待确认
	SalesConfirmed  SalesOrderStatus = "confirmed"  // 已确认
	SalesPaid       SalesOrderStatus = "paid"       // 已付款
	SalesShipped    SalesOrderStatus = "shipped"    // 已发货
	SalesDelivered  SalesOrderStatus = "delivered"  // 已送达
	SalesCompleted  SalesOrderStatus = "completed"  // 已完成
	SalesCancelled  SalesOrderStatus = "cancelled"  // 已取消
	SalesReturned   SalesOrderStatus = "returned"   // 已退货
)

// SalesOrderType 销售订单类型
type SalesOrderType string

const (
	SalesTypeOnline  SalesOrderType = "online"  // 线上订单
	SalesTypeOffline SalesOrderType = "offline" // 线下订单
	SalesTypeMobile  SalesOrderType = "mobile"  // 移动端订单
)

// PaymentMethod 支付方式
type PaymentMethod string

const (
	PaymentCash    PaymentMethod = "cash"    // 现金
	PaymentCard    PaymentMethod = "card"    // 银行卡
	PaymentWechat  PaymentMethod = "wechat"  // 微信支付
	PaymentAlipay  PaymentMethod = "alipay"  // 支付宝
	PaymentPoints  PaymentMethod = "points"  // 积分抵扣
	PaymentMixed   PaymentMethod = "mixed"   // 混合支付
)

// SalesOrder 销售订单主表
type SalesOrder struct {
	ID              uint             `gorm:"primaryKey" json:"id"`
	OrderNumber     string           `gorm:"size:50;uniqueIndex" json:"orderNumber"`              // 订单号
	StoreID         uint             `gorm:"not null" json:"storeId"`                             // 销售店铺ID
	MemberID        *uint            `json:"memberId"`                                            // 会员ID（可选）
	CustomerName    string           `gorm:"size:100" json:"customerName"`                       // 客户姓名
	CustomerPhone   string           `gorm:"size:20" json:"customerPhone"`                       // 客户电话
	CustomerAddress string           `gorm:"size:255" json:"customerAddress"`                    // 客户地址
	OrderType       SalesOrderType   `gorm:"size:20;not null;default:'offline'" json:"orderType"` // 订单类型
	Status          SalesOrderStatus `gorm:"size:20;not null;default:'draft'" json:"status"`     // 订单状态
	
	// 金额相关
	SubtotalAmount  float64 `gorm:"not null" json:"subtotalAmount"`  // 商品小计
	DiscountAmount  float64 `gorm:"default:0" json:"discountAmount"` // 折扣金额
	PointsDiscount  float64 `gorm:"default:0" json:"pointsDiscount"` // 积分抵扣金额
	TotalAmount     float64 `gorm:"not null" json:"totalAmount"`     // 订单总金额
	PaidAmount      float64 `gorm:"default:0" json:"paidAmount"`     // 已付金额
	
	// 支付相关
	PaymentMethod   PaymentMethod `gorm:"size:20" json:"paymentMethod"`   // 支付方式
	PaymentStatus   string        `gorm:"size:20;default:'unpaid'" json:"paymentStatus"` // 支付状态：unpaid/partial/paid/refunded
	PaymentTime     *time.Time    `json:"paymentTime"`                    // 支付时间
	TransactionID   string        `gorm:"size:100" json:"transactionId"`  // 交易流水号
	
	// 试衣相关
	FittingRoomID   *uint   `json:"fittingRoomId"`   // 试衣间ID
	FittingDuration *int    `json:"fittingDuration"` // 试衣时长（分钟）
	FittingNote     string  `gorm:"size:255" json:"fittingNote"` // 试衣备注
	
	// 议价相关
	OriginalAmount  float64 `gorm:"default:0" json:"originalAmount"`  // 原始金额
	NegotiationCount int    `gorm:"default:0" json:"negotiationCount"` // 议价次数
	
	// 操作人员
	SalespersonID   uint       `gorm:"not null" json:"salespersonId"`   // 销售员ID
	CashierID       *uint      `json:"cashierId"`                       // 收银员ID
	CreatorID       uint       `gorm:"not null" json:"creatorId"`       // 创建人ID
	
	// 时间相关
	OrderDate       time.Time  `gorm:"not null" json:"orderDate"`       // 下单时间
	DeliveryDate    *time.Time `json:"deliveryDate"`                    // 交货时间
	CompletedAt     *time.Time `json:"completedAt"`                     // 完成时间
	
	Note            string     `gorm:"size:500" json:"note"`             // 订单备注
	CreatedAt       time.Time  `json:"createdAt"`
	UpdatedAt       time.Time  `json:"updatedAt"`
	DeletedAt       gorm.DeletedAt `gorm:"index" json:"-"`

	// 关联
	Items       []SalesOrderItem    `gorm:"foreignKey:SalesOrderID" json:"items"`       // 订单明细
	Store       Store               `gorm:"foreignKey:StoreID" json:"store"`            // 店铺信息
	Member      *Member             `gorm:"foreignKey:MemberID" json:"member"`          // 会员信息
	Salesperson User                `gorm:"foreignKey:SalespersonID" json:"salesperson"` // 销售员
	Cashier     *User               `gorm:"foreignKey:CashierID" json:"cashier"`        // 收银员
	Creator     User                `gorm:"foreignKey:CreatorID" json:"creator"`        // 创建人
	Payments    []SalesOrderPayment `gorm:"foreignKey:SalesOrderID" json:"payments"`    // 支付记录
	Logs        []SalesOrderLog     `gorm:"foreignKey:SalesOrderID" json:"logs"`        // 操作日志
}

// SalesOrderItem 销售订单明细
type SalesOrderItem struct {
	ID               uint    `gorm:"primaryKey" json:"id"`
	SalesOrderID     uint    `gorm:"not null" json:"salesOrderId"`     // 销售订单ID
	ProductID        uint    `gorm:"not null" json:"productId"`        // 商品ID
	ProductVariantID *uint   `json:"productVariantId"`                 // 商品变体ID
	ProductName      string  `gorm:"size:255;not null" json:"productName"` // 商品名称（冗余）
	ProductSKU       string  `gorm:"size:100" json:"productSku"`       // 商品SKU（冗余）
	ProductImage     string  `gorm:"size:255" json:"productImage"`     // 商品图片（冗余）
	
	Quantity         int     `gorm:"not null" json:"quantity"`         // 销售数量
	UnitPrice        float64 `gorm:"not null" json:"unitPrice"`        // 销售单价
	OriginalPrice    float64 `gorm:"not null" json:"originalPrice"`    // 原价
	DiscountAmount   float64 `gorm:"default:0" json:"discountAmount"`  // 单项折扣金额
	TotalPrice       float64 `gorm:"not null" json:"totalPrice"`       // 小计金额
	
	// 二维码相关
	QRCode           string  `gorm:"size:255" json:"qrCode"`           // 商品二维码
	BatchNumber      string  `gorm:"size:50" json:"batchNumber"`       // 批次号
	
	// 试衣相关
	IsTried          bool    `gorm:"default:false" json:"isTried"`     // 是否试穿
	TriedSize        string  `gorm:"size:20" json:"triedSize"`         // 试穿尺码
	FitRating        *int    `json:"fitRating"`                        // 合身度评分（1-5）
	
	Note             string  `gorm:"size:255" json:"note"`             // 备注
	CreatedAt        time.Time `json:"createdAt"`
	UpdatedAt        time.Time `json:"updatedAt"`

	// 关联
	Product        Product        `gorm:"foreignKey:ProductID" json:"product"`
	ProductVariant *ProductVariant `gorm:"foreignKey:ProductVariantID" json:"productVariant"`
}

// SalesOrderPayment 销售订单支付记录
type SalesOrderPayment struct {
	ID            uint          `gorm:"primaryKey" json:"id"`
	SalesOrderID  uint          `gorm:"not null" json:"salesOrderId"`  // 销售订单ID
	PaymentMethod PaymentMethod `gorm:"size:20;not null" json:"paymentMethod"` // 支付方式
	Amount        float64       `gorm:"not null" json:"amount"`        // 支付金额
	TransactionID string        `gorm:"size:100" json:"transactionId"` // 交易流水号
	PaymentTime   time.Time     `gorm:"not null" json:"paymentTime"`   // 支付时间
	Status        string        `gorm:"size:20;default:'success'" json:"status"` // 支付状态
	Note          string        `gorm:"size:255" json:"note"`          // 备注
	CreatedAt     time.Time     `json:"createdAt"`
	UpdatedAt     time.Time     `json:"updatedAt"`
}

// SalesOrderLog 销售订单操作日志
type SalesOrderLog struct {
	ID           uint      `gorm:"primaryKey" json:"id"`
	SalesOrderID uint      `gorm:"not null" json:"salesOrderId"` // 销售订单ID
	OperatorID   uint      `gorm:"not null" json:"operatorId"`   // 操作人ID
	Action       string    `gorm:"size:50;not null" json:"action"` // 操作类型
	Description  string    `gorm:"size:500" json:"description"`   // 操作描述
	OldValue     string    `gorm:"type:text" json:"oldValue"`     // 原值
	NewValue     string    `gorm:"type:text" json:"newValue"`     // 新值
	CreatedAt    time.Time `json:"createdAt"`

	// 关联
	Operator User `gorm:"foreignKey:OperatorID" json:"operator"` // 操作人
}

// NegotiationLog 议价记录
type NegotiationLog struct {
	ID           uint      `gorm:"primaryKey" json:"id"`
	SalesOrderID uint      `gorm:"not null" json:"salesOrderId"` // 销售订单ID
	OperatorID   uint      `gorm:"not null" json:"operatorId"`   // 操作人ID
	OriginalPrice float64  `gorm:"not null" json:"originalPrice"` // 原价
	ProposedPrice float64  `gorm:"not null" json:"proposedPrice"` // 议价
	FinalPrice    float64  `gorm:"not null" json:"finalPrice"`    // 最终价格
	Reason        string   `gorm:"size:255" json:"reason"`        // 议价原因
	CreatedAt     time.Time `json:"createdAt"`

	// 关联
	Operator User `gorm:"foreignKey:OperatorID" json:"operator"` // 操作人
}
