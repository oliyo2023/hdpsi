package controllers

import (
	"hd_psi/backend/models"
	"net/http"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

// SystemSettingController 系统设置控制器
type SystemSettingController struct {
	db *gorm.DB
}

// NewSystemSettingController 创建系统设置控制器实例
func NewSystemSettingController(db *gorm.DB) *SystemSettingController {
	return &SystemSettingController{db: db}
}

// GetSettings 获取系统设置
// 参数：
//   - c: Gin上下文对象
func (ssc *SystemSettingController) GetSettings(c *gin.Context) {
	// 获取查询参数
	group := c.Query("group")
	userID := c.Query("user_id")

	// 构建查询
	query := ssc.db.Model(&models.SystemSetting{})

	// 如果指定了分组，则按分组筛选
	if group != "" {
		query = query.Where("`group` = ?", group)
	}

	// 如果指定了用户ID，则获取用户特定设置，否则获取全局设置
	if userID != "" {
		query = query.Where("`user_id` = ?", userID)
	} else {
		query = query.Where("`user_id` IS NULL")
	}

	// 执行查询
	var settings []models.SystemSetting
	if err := query.Find(&settings).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "获取系统设置失败", "details": err.Error()})
		return
	}

	// 将设置转换为键值对格式
	settingsMap := make(map[string]string)
	for _, setting := range settings {
		settingsMap[setting.Key] = setting.Value
	}

	c.JSON(http.StatusOK, settingsMap)
}

// UpdateSettings 更新系统设置
// 参数：
//   - c: Gin上下文对象
func (ssc *SystemSettingController) UpdateSettings(c *gin.Context) {
	// 获取请求参数
	var input struct {
		Group    string            `json:"group" binding:"required"`
		UserID   *uint             `json:"user_id"`
		Settings map[string]string `json:"settings" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的请求参数", "details": err.Error()})
		return
	}

	// 开始事务
	tx := ssc.db.Begin()

	// 更新或创建设置
	for key, value := range input.Settings {
		var setting models.SystemSetting

		// 查找现有设置
		result := tx.Where("`key` = ? AND `group` = ? AND (`user_id` = ? OR (`user_id` IS NULL AND ? IS NULL))",
			key, input.Group, input.UserID, input.UserID).First(&setting)

		if result.Error != nil {
			// 如果设置不存在，创建新设置
			setting = models.SystemSetting{
				Key:    key,
				Value:  value,
				Group:  input.Group,
				UserID: input.UserID,
			}
			if err := tx.Create(&setting).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "创建设置失败", "details": err.Error()})
				return
			}
		} else {
			// 如果设置存在，更新设置值
			setting.Value = value
			if err := tx.Save(&setting).Error; err != nil {
				tx.Rollback()
				c.JSON(http.StatusInternalServerError, gin.H{"error": "更新设置失败", "details": err.Error()})
				return
			}
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "保存设置失败", "details": err.Error()})
		return
	}

	c.JSON(http.StatusOK, gin.H{"message": "设置已更新"})
}

// InitDefaultSettings 初始化默认系统设置
func (ssc *SystemSettingController) InitDefaultSettings() error {
	// 默认设置
	defaultSettings := []models.SystemSetting{
		// 基本设置
		{Key: models.SettingSystemName, Value: "服装进销存系统", Group: models.SettingGroupBasic, UserID: nil},
		{Key: models.SettingCompanyName, Value: "海达服饰有限公司", Group: models.SettingGroupBasic, UserID: nil},
		{Key: models.SettingLanguage, Value: "zh-CN", Group: models.SettingGroupBasic, UserID: nil},

		// 主题设置
		{Key: models.SettingTheme, Value: "light", Group: models.SettingGroupTheme, UserID: nil},

		// 通知设置
		{Key: models.SettingInventoryAlert, Value: "true", Group: models.SettingGroupNotification, UserID: nil},
		{Key: models.SettingOrderNotification, Value: "true", Group: models.SettingGroupNotification, UserID: nil},
		{Key: models.SettingSystemMessage, Value: "true", Group: models.SettingGroupNotification, UserID: nil},
		{Key: models.SettingEmailNotification, Value: "false", Group: models.SettingGroupNotification, UserID: nil},

		// 打印设置
		{Key: models.SettingDefaultPrinter, Value: "default", Group: models.SettingGroupPrinting, UserID: nil},
		{Key: models.SettingPaperSize, Value: "a4", Group: models.SettingGroupPrinting, UserID: nil},
		{Key: models.SettingPrintHeader, Value: "海达服饰有限公司", Group: models.SettingGroupPrinting, UserID: nil},
		{Key: models.SettingPrintFooter, Value: "感谢您的惠顾", Group: models.SettingGroupPrinting, UserID: nil},
	}

	// 开始事务
	tx := ssc.db.Begin()

	// 逐个插入设置，如果已存在则跳过
	for _, setting := range defaultSettings {
		var existingSetting models.SystemSetting
		result := tx.Where("`key` = ? AND `group` = ? AND (`user_id` IS NULL OR `user_id` = ?)",
			setting.Key, setting.Group, setting.UserID).First(&existingSetting)

		// 如果设置不存在，创建新设置
		if result.Error != nil {
			if err := tx.Create(&setting).Error; err != nil {
				tx.Rollback()
				return err
			}
		}
	}

	// 提交事务
	return tx.Commit().Error
}

// GetUserTheme 获取用户主题设置
// 参数：
//   - c: Gin上下文对象
func (ssc *SystemSettingController) GetUserTheme(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 查询用户主题设置
	var themeSetting models.SystemSetting
	result := ssc.db.Where("`key` = ? AND `group` = ? AND `user_id` = ?",
		models.SettingTheme, models.SettingGroupTheme, userID).First(&themeSetting)

	// 如果用户没有特定设置，则获取全局设置
	if result.Error != nil {
		result = ssc.db.Where("`key` = ? AND `group` = ? AND `user_id` IS NULL",
			models.SettingTheme, models.SettingGroupTheme).First(&themeSetting)

		// 如果全局设置也不存在，则返回默认主题
		if result.Error != nil {
			c.JSON(http.StatusOK, gin.H{"theme": "light"})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"theme": themeSetting.Value})
}

// UpdateUserTheme 更新用户主题设置
// 参数：
//   - c: Gin上下文对象
func (ssc *SystemSettingController) UpdateUserTheme(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 获取请求参数
	var input struct {
		Theme string `json:"theme" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的请求参数", "details": err.Error()})
		return
	}

	// 验证主题值
	if input.Theme != "light" && input.Theme != "dark" {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的主题值，必须是 'light' 或 'dark'"})
		return
	}

	// 查找现有设置
	var themeSetting models.SystemSetting
	result := ssc.db.Where("`key` = ? AND `group` = ? AND `user_id` = ?",
		models.SettingTheme, models.SettingGroupTheme, userID).First(&themeSetting)

	// 如果设置不存在，创建新设置
	if result.Error != nil {
		themeSetting = models.SystemSetting{
			Key:    models.SettingTheme,
			Value:  input.Theme,
			Group:  models.SettingGroupTheme,
			UserID: &[]uint{userID.(uint)}[0], // 转换为指针
		}
		if err := ssc.db.Create(&themeSetting).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "创建主题设置失败", "details": err.Error()})
			return
		}
	} else {
		// 如果设置存在，更新设置值
		themeSetting.Value = input.Theme
		if err := ssc.db.Save(&themeSetting).Error; err != nil {
			c.JSON(http.StatusInternalServerError, gin.H{"error": "更新主题设置失败", "details": err.Error()})
			return
		}
	}

	c.JSON(http.StatusOK, gin.H{"message": "主题设置已更新", "theme": input.Theme})
}
