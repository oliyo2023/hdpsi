package models

import "time"

// TransactionType 定义库存交易类型
type TransactionType string

const (
	// 入库类型
	PurchaseIn TransactionType = "purchase_in" // 采购入库
	ReturnIn   TransactionType = "return_in"   // 退货入库
	TransferIn TransactionType = "transfer_in" // 调拨入库

	// 出库类型
	SaleOut     TransactionType = "sale_out"     // 销售出库
	ExchangeOut TransactionType = "exchange_out" // 换货出库
	DamageOut   TransactionType = "damage_out"   // 报损出库
	TransferOut TransactionType = "transfer_out" // 调拨出库
)

// InventoryTransaction 库存交易记录
type InventoryTransaction struct {
	ID               uint            `gorm:"primaryKey"`
	TransactionType  TransactionType `gorm:"size:20;not null"`
	ProductVariantID uint            `gorm:"not null"`
	StoreID          uint            `gorm:"not null"`
	Quantity         int             `gorm:"not null"` // 正数表示入库，负数表示出库
	BatchNumber      string          `gorm:"size:50"`  // 批次号
	SourceStoreID    *uint           // 调拨来源店铺ID，仅调拨入库时有值
	ReferenceID      *uint           // 关联单据ID（采购单/销售单/调拨单）
	ReferenceType    string          `gorm:"size:20"` // 关联单据类型
	OperatorID       uint            // 操作人ID
	Note             string          `gorm:"size:255"` // 备注
	CreatedAt        time.Time
	UpdatedAt        time.Time
}
