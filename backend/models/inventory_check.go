package models

import "time"

// CheckStatus 盘点状态
type CheckStatus string

const (
	Planned   CheckStatus = "planned"    // 计划中
	InProcess CheckStatus = "in_process" // 进行中
	Completed CheckStatus = "completed"  // 已完成
	Cancelled CheckStatus = "cancelled"  // 已取消
)

// CheckType 盘点类型
type CheckType string

const (
	FullCheck CheckType = "full_check" // 全盘
	SpotCheck CheckType = "spot_check" // 抽盘
)

// InventoryCheck 库存盘点主表
type InventoryCheck struct {
	ID          uint        `gorm:"primaryKey"`
	StoreID     uint        `gorm:"not null"`                           // 盘点店铺
	CheckCode   string      `gorm:"size:50;uniqueIndex"`                // 盘点单号
	CheckType   CheckType   `gorm:"size:20;not null"`                   // 盘点类型：全盘/抽盘
	Status      CheckStatus `gorm:"size:20;not null;default:'planned'"` // 盘点状态
	PlanDate    time.Time   // 计划盘点日期
	StartTime   *time.Time  // 实际开始时间
	EndTime     *time.Time  // 实际结束时间
	OperatorID  uint        // 操作人ID
	Description string      `gorm:"size:255"` // 盘点说明
	CreatedAt   time.Time
	UpdatedAt   time.Time
}

// InventoryCheckItem 库存盘点明细
type InventoryCheckItem struct {
	ID               uint   `gorm:"primaryKey"`
	CheckID          uint   `gorm:"not null"` // 关联盘点主表ID
	ProductVariantID uint   `gorm:"not null"` // 商品变体ID
	SystemQuantity   int    `gorm:"not null"` // 系统库存数量
	ActualQuantity   int    // 实际盘点数量
	DifferenceQty    int    // 差异数量（实际-系统）
	Status           string `gorm:"size:20;default:'pending'"` // 状态：待盘点/已盘点
	Note             string `gorm:"size:255"`                  // 备注
	CreatedAt        time.Time
	UpdatedAt        time.Time
}

// InventoryCheckAdjustment 库存盘点调整记录
type InventoryCheckAdjustment struct {
	ID               uint       `gorm:"primaryKey"`
	CheckID          uint       `gorm:"not null"` // 关联盘点主表ID
	CheckItemID      uint       `gorm:"not null"` // 关联盘点明细ID
	ProductVariantID uint       `gorm:"not null"` // 商品变体ID
	AdjustQuantity   int        `gorm:"not null"` // 调整数量（正数增加，负数减少）
	Reason           string     `gorm:"size:100"` // 调整原因
	ApproverID       uint       // 审批人ID
	ApprovalStatus   string     `gorm:"size:20;default:'pending'"` // 审批状态：待审批/已审批/已拒绝
	ApprovalTime     *time.Time // 审批时间
	ApprovalNote     string     `gorm:"size:255"` // 审批备注
	CreatedAt        time.Time
	UpdatedAt        time.Time
}
