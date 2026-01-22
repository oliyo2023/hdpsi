package models

import (
	"time"

	"gorm.io/gorm"
)

// ReturnType 定义退换货类型
const (
	ReturnTypeReturn   = "RETURN"   // 退货
	ReturnTypeExchange = "EXCHANGE" // 换货
)

// ReturnStatus 定义退换货状态
const (
	ReturnStatusPendingApproval     = "PENDING_APPROVAL"      // 待审批
	ReturnStatusApproved            = "APPROVED"              // 已审批 (待处理)
	ReturnStatusRejected            = "REJECTED"              // 已拒绝
	ReturnStatusProcessing          = "PROCESSING"            // 处理中 (例如，已收到退货，待退款或发货)
	ReturnStatusPendingGoodsReceipt = "PENDING_GOODS_RECEIPT" // 待收货 (退货场景，审批通过后等待买家发货或仓库收货)
	ReturnStatusPendingShipment     = "PENDING_SHIPMENT"      // 待发货 (换货场景，审批通过后等待卖家发货)
	ReturnStatusGoodsReceived       = "GOODS_RECEIVED"        // 已收到退货商品 (退货场景)
	ReturnStatusExchangeShipped     = "EXCHANGE_SHIPPED"      // 已发出换货商品 (换货场景)
	ReturnStatusRefunded            = "REFUNDED"              // 已退款 (退货场景)
	ReturnStatusRefundProcessed     = "REFUND_PROCESSED"      // 退款已处理 (退货场景)
	ReturnStatusCompleted           = "COMPLETED"             // 已完成
	ReturnStatusCancelled           = "CANCELLED"             // 已取消
)

// ReturnOrder 表示一个退换货申请
type ReturnOrder struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	ReturnNo      string    `gorm:"type:varchar(50);uniqueIndex;not null" json:"returnNo"` // 退换货单号
	OrderNo       string    `gorm:"type:varchar(50);index;not null" json:"orderNo"`        // 原始订单号
	Type          string    `gorm:"type:varchar(20);not null" json:"type"`                 // 类型: RETURN, EXCHANGE
	Status        string    `gorm:"type:varchar(30);not null;index" json:"status"`         // 状态
	CustomerName  string    `gorm:"type:varchar(100)" json:"customerName"`
	CustomerPhone string    `gorm:"type:varchar(50)" json:"customerPhone"`
	ApplyDate     time.Time `gorm:"not null" json:"applyDate"` // 申请日期
	Remarks       string    `gorm:"type:text" json:"remarks"`  // 备注
	Images        string    `gorm:"type:text" json:"images"`   // 图片凭证 (JSON 字符串数组 of URLs)

	// 退货相关
	RefundAmount        *float64   `json:"refundAmount,omitempty"`                                 // 期望退款金额 (退货时)
	ActualRefundAmount  *float64   `json:"actualRefundAmount,omitempty"`                           // 实际退款金额
	RefundMethod        *string    `gorm:"type:varchar(50)" json:"refundMethod,omitempty"`         // 退款方式
	RefundTransactionID *string    `gorm:"type:varchar(100)" json:"refundTransactionId,omitempty"` // 退款交易ID
	RefundDate          *time.Time `json:"refundDate,omitempty"`                                   // 退款日期

	// 换货相关
	ExchangeShippingAddress string     `gorm:"type:varchar(255)" json:"exchangeShippingAddress,omitempty"` // 换货收货地址
	ExchangeShippingContact string     `gorm:"type:varchar(100)" json:"exchangeShippingContact,omitempty"` // 换货联系人
	ExchangeShippingPhone   string     `gorm:"type:varchar(50)" json:"exchangeShippingPhone,omitempty"`    // 换货联系电话
	ExchangeShippingCarrier string     `gorm:"type:varchar(100)" json:"exchangeShippingCarrier,omitempty"` // 换货物流公司
	ExchangeTrackingNumber  string     `gorm:"type:varchar(100)" json:"exchangeTrackingNumber,omitempty"`  // 换货追踪号码
	ExchangeShippedDate     *time.Time `json:"exchangeShippedDate,omitempty"`                              // 换货发货日期
	ExchangeShippingNo      string     `gorm:"type:varchar(100)" json:"exchangeShippingNo,omitempty"`      // 换货物流单号

	// 审批信息
	ApprovedBy      *uint      `json:"approvedBy,omitempty"`
	Approver        *User      `gorm:"foreignKey:ApprovedBy" json:"approver,omitempty"`
	ApprovalDate    *time.Time `json:"approvalDate,omitempty"`
	RejectionReason string     `gorm:"type:text" json:"rejectionReason,omitempty"` // 拒绝原因

	// 处理信息
	ProcessedBy   *uint      `json:"processedBy,omitempty"`
	Processor     *User      `gorm:"foreignKey:ProcessedBy" json:"processor,omitempty"`
	ProcessDate   *time.Time `json:"processDate,omitempty"`   // 开始处理日期
	CompletedDate *time.Time `json:"completedDate,omitempty"` // 完成日期

	ReturnOrderItems   []ReturnOrderItem   `gorm:"foreignKey:ReturnOrderID" json:"returnOrderItems"`   // 退货商品项
	ExchangeOrderItems []ExchangeOrderItem `gorm:"foreignKey:ReturnOrderID" json:"exchangeOrderItems"` // 换货商品项 (换出的新商品)
	ReturnOrderLogs    []ReturnOrderLog    `gorm:"foreignKey:ReturnOrderID" json:"returnOrderLogs"`    // 操作日志

	CreatedAt time.Time      `json:"createdAt"`
	UpdatedAt time.Time      `json:"updatedAt"`
	DeletedAt gorm.DeletedAt `gorm:"index" json:"-"`
}

// ReturnOrderItem 表示退货的商品项
type ReturnOrderItem struct {
	ID               uint    `gorm:"primaryKey" json:"id"`
	ReturnOrderID    uint    `gorm:"index;not null" json:"returnOrderId"`
	ProductID        uint    `gorm:"not null" json:"productId"`
	Product          Product `gorm:"foreignKey:ProductID" json:"product"`           // 关联商品信息
	ProductName      string  `gorm:"type:varchar(255);not null" json:"productName"` // 商品名称 (冗余)
	ProductSKU       string  `gorm:"type:varchar(100)" json:"productSku"`           // 商品SKU (冗余)
	Quantity         int     `gorm:"not null" json:"quantity"`
	Reason           string  `gorm:"type:varchar(255)" json:"reason"` // 退货原因 (如: QUALITY, SIZE, STYLE, OTHER)
	Remarks          string  `gorm:"type:text" json:"remarks"`        // 备注
	ReceivedQuantity int     `json:"receivedQuantity"`                // 已收到数量 (用于分批收货等场景)
}

// ExchangeOrderItem 表示换货的目标商品项 (换出的新商品)
type ExchangeOrderItem struct {
	ID              uint    `gorm:"primaryKey" json:"id"`
	ReturnOrderID   uint    `gorm:"index;not null" json:"returnOrderId"`
	ProductID       uint    `gorm:"not null" json:"productId"`
	Product         Product `gorm:"foreignKey:ProductID" json:"product"`           // 关联商品信息
	ProductName     string  `gorm:"type:varchar(255);not null" json:"productName"` // 商品名称 (冗余)
	ProductSKU      string  `gorm:"type:varchar(100)" json:"productSku"`           // 商品SKU (冗余)
	Quantity        int     `gorm:"not null" json:"quantity"`
	ShippedQuantity int     `json:"shippedQuantity"` // 已发货数量
}

// ReturnOrderLog 表示退换货订单的操作日志
type ReturnOrderLog struct {
	ID            uint      `gorm:"primaryKey" json:"id"`
	ReturnOrderID uint      `gorm:"index;not null" json:"returnOrderId"`
	OperatorID    *uint     `json:"operatorId,omitempty"`                     // 操作员ID, 系统操作可为null
	OperatorName  string    `gorm:"type:varchar(100)" json:"operatorName"`    // 操作员名称
	Action        string    `gorm:"type:varchar(255);not null" json:"action"` // 操作描述，例如 "创建申请", "审批通过", "更新状态为: 已发货"
	Details       string    `gorm:"type:text" json:"details"`                 // 详细信息/备注
	LogTime       time.Time `gorm:"not null" json:"logTime"`
}

// TableName specifies the table name for ReturnOrder
func (ReturnOrder) TableName() string {
	return "psi_return_orders"
}

// TableName specifies the table name for ReturnOrderItem
func (ReturnOrderItem) TableName() string {
	return "psi_return_order_items"
}

// TableName specifies the table name for ExchangeOrderItem
func (ExchangeOrderItem) TableName() string {
	return "psi_exchange_order_items"
}

// TableName specifies the table name for ReturnOrderLog
func (ReturnOrderLog) TableName() string {
	return "psi_return_order_logs"
}

// TODO: Add GORM hooks if needed (e.g., BeforeCreate to generate ReturnNo)
