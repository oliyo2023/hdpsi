package models

import "time"

// SystemSetting 系统设置模型
type SystemSetting struct {
	ID        uint   `gorm:"primaryKey"`
	Key       string `gorm:"size:100;not null"` // 设置键名
	Value     string `gorm:"type:text"`         // 设置值
	Group     string `gorm:"size:50;index"`     // 设置分组
	UserID    *uint  `gorm:"default:null"`      // 用户ID，为null表示全局设置
	CreatedAt time.Time
	UpdatedAt time.Time

	// 设置组合唯一索引：键名+分组+用户ID
	// 这样可以确保同一用户在同一分组下的同一键名只有一个值
	// 但不同用户或不同分组可以有相同的键名
	_ struct{} `gorm:"uniqueIndex:idx_key_group_user"`
}

// 系统设置分组常量
const (
	SettingGroupBasic        = "basic"        // 基本设置
	SettingGroupNotification = "notification" // 通知设置
	SettingGroupPrinting     = "printing"     // 打印设置
	SettingGroupTheme        = "theme"        // 主题设置
)

// 系统设置键名常量
const (
	// 基本设置
	SettingSystemName  = "system_name"  // 系统名称
	SettingCompanyName = "company_name" // 公司名称
	SettingLanguage    = "language"     // 默认语言

	// 主题设置
	SettingTheme = "theme" // 系统主题

	// 通知设置
	SettingInventoryAlert    = "inventory_alert"    // 库存预警通知
	SettingOrderNotification = "order_notification" // 订单通知
	SettingSystemMessage     = "system_message"     // 系统消息
	SettingEmailNotification = "email_notification" // 邮件通知

	// 打印设置
	SettingDefaultPrinter = "default_printer" // 默认打印机
	SettingPaperSize      = "paper_size"      // 纸张大小
	SettingPrintHeader    = "print_header"    // 打印页眉
	SettingPrintFooter    = "print_footer"    // 打印页脚
)
