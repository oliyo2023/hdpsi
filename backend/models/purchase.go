package models

import "time"

// PurchaseOrderStatus 采购单状态
type PurchaseOrderStatus string

const (
	PurchaseDraft       PurchaseOrderStatus = "draft"     // 草稿
	PurchasePending     PurchaseOrderStatus = "pending"   // 待审核
	PurchaseApproved    PurchaseOrderStatus = "approved"  // 已审核
	PurchaseRejected    PurchaseOrderStatus = "rejected"  // 已拒绝
	PurchaseOrdered     PurchaseOrderStatus = "ordered"   // 已下单
	PurchaseInReceiving PurchaseOrderStatus = "receiving" // 待入库
	PurchaseCompleted   PurchaseOrderStatus = "completed" // 已完成
	PurchaseCancelled   PurchaseOrderStatus = "cancelled" // 已取消
)

// PurchaseOrder 采购单主表
type PurchaseOrder struct {
	ID           uint                `gorm:"primaryKey"`
	OrderNumber  string              `gorm:"size:50;uniqueIndex"`              // 采购单号
	SupplierID   uint                `gorm:"not null"`                         // 供应商ID
	StoreID      uint                `gorm:"not null"`                         // 采购店铺ID
	Status       PurchaseOrderStatus `gorm:"size:20;not null;default:'draft'"` // 采购单状态
	TotalAmount  float64             `gorm:"not null"`                         // 采购总金额
	ExpectedDate *time.Time          // 预计到货日期
	ActualDate   *time.Time          // 实际到货日期
	CreatorID    uint                `gorm:"not null"` // 创建人ID
	ApproverID   *uint               // 审核人ID
	ApprovalTime *time.Time          // 审核时间
	ApprovalNote string              `gorm:"size:255"` // 审核备注
	Note         string              `gorm:"size:255"` // 采购单备注
	CreatedAt    time.Time
	UpdatedAt    time.Time

	// 关联
	Items    []PurchaseOrderItem // 采购单明细
	Supplier Supplier            `gorm:"foreignKey:SupplierID"`
	Store    Store               `gorm:"foreignKey:StoreID"`
}

// PurchaseOrderItem 采购单明细
type PurchaseOrderItem struct {
	ID              uint    `gorm:"primaryKey"`
	PurchaseOrderID uint    `gorm:"not null"` // 采购单ID
	ProductID       uint    `gorm:"not null"` // 商品ID
	Quantity        int     `gorm:"not null"` // 采购数量
	UnitPrice       float64 `gorm:"not null"` // 采购单价
	TotalPrice      float64 `gorm:"not null"` // 采购总价
	ReceivedQty     int     // 已入库数量
	Note            string  `gorm:"size:255"` // 备注
	CreatedAt       time.Time
	UpdatedAt       time.Time

	// 关联
	Product Product `gorm:"foreignKey:ProductID"`
}

// PurchaseReceiving 采购入库记录
type PurchaseReceiving struct {
	ID              uint      `gorm:"primaryKey"`
	PurchaseOrderID uint      `gorm:"not null"`            // 采购单ID
	ReceivingNumber string    `gorm:"size:50;uniqueIndex"` // 入库单号
	StoreID         uint      `gorm:"not null"`            // 入库店铺ID
	OperatorID      uint      `gorm:"not null"`            // 操作人ID
	ReceivingDate   time.Time `gorm:"not null"`            // 入库日期
	Note            string    `gorm:"size:255"`            // 备注
	CreatedAt       time.Time
	UpdatedAt       time.Time

	// 关联
	Items         []PurchaseReceivingItem // 入库明细
	PurchaseOrder PurchaseOrder           `gorm:"foreignKey:PurchaseOrderID"`
	Store         Store                   `gorm:"foreignKey:StoreID"`
}

// PurchaseReceivingItem 采购入库明细
type PurchaseReceivingItem struct {
	ID                  uint   `gorm:"primaryKey"`
	PurchaseReceivingID uint   `gorm:"not null"`               // 入库单ID
	PurchaseOrderItemID uint   `gorm:"not null"`               // 采购单明细ID
	ProductID           uint   `gorm:"not null"`               // 商品ID
	ProductVariantID    uint   `gorm:"not null"`               // 商品变体ID
	ExpectedQuantity    int    `gorm:"not null"`               // 预期数量
	ActualQuantity      int    `gorm:"not null"`               // 实际入库数量
	BatchNumber         string `gorm:"size:50"`                // 批次号
	QualityStatus       string `gorm:"size:20;default:'good'"` // 质量状态：good/defective
	Note                string `gorm:"size:255"`               // 备注
	CreatedAt           time.Time
	UpdatedAt           time.Time

	// 关联
	Product        Product        `gorm:"foreignKey:ProductID"`
	ProductVariant ProductVariant `gorm:"foreignKey:ProductVariantID"`
}

// SupplierRating 供应商评级
type SupplierRating string

const (
	SupplierS SupplierRating = "S" // 优秀
	SupplierA SupplierRating = "A" // 良好
	SupplierB SupplierRating = "B" // 一般
	SupplierC SupplierRating = "C" // 较差
	SupplierD SupplierRating = "D" // 不合格
)

// SupplierType 供应商类型
type SupplierType string

const (
	SupplierManufacturer SupplierType = "manufacturer" // 生产厂商
	SupplierWholesaler   SupplierType = "wholesaler"   // 批发商
	SupplierAgent        SupplierType = "agent"        // 代理商
	SupplierOther        SupplierType = "other"        // 其他
)

// Supplier 供应商信息
type Supplier struct {
	ID            uint           `gorm:"primaryKey"`
	Name          string         `gorm:"size:100;not null"`   // 供应商名称
	Code          string         `gorm:"size:50;uniqueIndex"` // 供应商编码
	Type          SupplierType   `gorm:"size:20;not null"`    // 供应商类型
	ContactPerson string         `gorm:"size:50"`             // 联系人
	ContactPhone  string         `gorm:"size:20"`             // 联系电话
	Email         string         `gorm:"size:100"`            // 电子邮箱
	Address       string         `gorm:"size:255"`            // 地址
	City          string         `gorm:"size:50"`             // 城市
	Rating        SupplierRating `gorm:"size:10;default:'B'"` // 供应商评级
	Qualification string         `gorm:"size:255"`            // 资质证明
	PaymentTerms  string         `gorm:"size:100"`            // 付款条件
	DeliveryTerms string         `gorm:"size:100"`            // 交货条件
	Status        bool           `gorm:"default:true"`        // 状态：true-启用，false-禁用
	Note          string         `gorm:"size:255"`            // 备注
	CreatedAt     time.Time
	UpdatedAt     time.Time
}
