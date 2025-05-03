package controllers

import (
	"hd_psi/backend/models"
	"hd_psi/backend/utils/errors"
	"hd_psi/backend/utils/logger"
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
	// 创建请求日志
	log := logger.WithContext(c)

	// 获取查询参数
	group := c.Query("group")
	userID := c.Query("user_id")

	log.Info("获取系统设置",
		logger.F("group", group),
		logger.F("user_id", userID))

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
		log.Error("获取系统设置失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseQuery).
			WithDetails("获取系统设置失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 将设置转换为键值对格式
	settingsMap := make(map[string]string)
	for _, setting := range settings {
		settingsMap[setting.Key] = setting.Value
	}

	log.Info("获取系统设置成功", logger.F("settings_count", len(settings)))
	c.JSON(http.StatusOK, settingsMap)
}

// UpdateSettings 更新系统设置
// 参数：
//   - c: Gin上下文对象
func (ssc *SystemSettingController) UpdateSettings(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("更新系统设置")

	// 获取请求参数
	var input struct {
		Group    string            `json:"group" binding:"required"`
		UserID   *uint             `json:"user_id"`
		Settings map[string]string `json:"settings" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("更新系统设置请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的系统设置信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithFields(
		logger.F("group", input.Group),
		logger.F("user_id", input.UserID),
		logger.F("settings_count", len(input.Settings)),
	)

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
				log.Error("创建设置失败",
					logger.F("key", key),
					logger.F("error", err.Error()))
				appErr := errors.New(errors.ErrDatabaseInsert).
					WithDetails("创建设置失败").
					WithError(err).
					WithRequestID(c.GetString("request_id"))
				c.Error(appErr)
				return
			}
			log.Info("创建设置", logger.F("key", key), logger.F("value", value))
		} else {
			// 如果设置存在，更新设置值
			oldValue := setting.Value
			setting.Value = value
			if err := tx.Save(&setting).Error; err != nil {
				tx.Rollback()
				log.Error("更新设置失败",
					logger.F("key", key),
					logger.F("error", err.Error()))
				appErr := errors.New(errors.ErrDatabaseUpdate).
					WithDetails("更新设置失败").
					WithError(err).
					WithRequestID(c.GetString("request_id"))
				c.Error(appErr)
				return
			}
			log.Info("更新设置",
				logger.F("key", key),
				logger.F("old_value", oldValue),
				logger.F("new_value", value))
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		log.Error("提交事务失败", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("保存设置失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("更新系统设置成功")
	c.JSON(http.StatusOK, gin.H{"message": "设置已更新"})
}

// InitDefaultSettings 初始化默认系统设置
func (ssc *SystemSettingController) InitDefaultSettings() error {
	// 创建一个新的日志记录器
	log := &logger.Logger{
		Fields: make(map[string]interface{}),
	}
	log = log.WithField("component", "SystemSettingController")
	log.Info("初始化默认系统设置")

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

	log.Info("准备初始化默认设置", logger.F("settings_count", len(defaultSettings)))

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
				log.Error("创建默认设置失败",
					logger.F("key", setting.Key),
					logger.F("error", err.Error()))
				return errors.Wrap(err, errors.ErrDatabaseInsert).
					WithDetails("创建默认设置失败")
			}
			log.Info("创建默认设置",
				logger.F("key", setting.Key),
				logger.F("value", setting.Value))
		} else {
			log.Info("默认设置已存在，跳过",
				logger.F("key", setting.Key),
				logger.F("value", existingSetting.Value))
		}
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		log.Error("提交事务失败", logger.F("error", err.Error()))
		return errors.Wrap(err, errors.ErrDatabaseUpdate).
			WithDetails("保存默认设置失败")
	}

	log.Info("初始化默认系统设置成功")
	return nil
}

// GetUserTheme 获取用户主题设置
// 参数：
//   - c: Gin上下文对象
func (ssc *SystemSettingController) GetUserTheme(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取用户主题设置")

	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")

	// 查询用户主题设置
	var themeSetting models.SystemSetting
	var result *gorm.DB

	// 如果用户已登录，尝试获取用户特定设置
	if exists {
		log = log.WithField("user_id", userID)
		result = ssc.db.Where("`key` = ? AND `group` = ? AND `user_id` = ?",
			models.SettingTheme, models.SettingGroupTheme, userID).First(&themeSetting)
	} else {
		log.Info("用户未登录，获取全局设置")
		// 直接获取全局设置
		result = ssc.db.Where("`key` = ? AND `group` = ? AND `user_id` IS NULL",
			models.SettingTheme, models.SettingGroupTheme).First(&themeSetting)
	}

	// 如果设置不存在，则返回默认主题
	if result.Error != nil {
		log.Info("主题设置不存在，使用默认主题")
		c.JSON(http.StatusOK, gin.H{"theme": "light"})
		return
	}

	log.Info("获取用户主题设置成功", logger.F("theme", themeSetting.Value))
	c.JSON(http.StatusOK, gin.H{"theme": themeSetting.Value})
}

// UpdateUserTheme 更新用户主题设置
// 参数：
//   - c: Gin上下文对象
func (ssc *SystemSettingController) UpdateUserTheme(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("更新用户主题设置")

	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		log.Warn("未授权的主题设置更新请求")
		appErr := errors.New(errors.ErrUnauthorized).
			WithDetails("请先登录").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithField("user_id", userID)

	// 获取请求参数
	var input struct {
		Theme string `json:"theme" binding:"required"`
	}

	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("更新主题设置请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的主题设置").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log = log.WithField("theme", input.Theme)

	// 验证主题值
	if input.Theme != "light" && input.Theme != "dark" {
		log.Warn("无效的主题值", logger.F("theme", input.Theme))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("无效的主题值，必须是 'light' 或 'dark'").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 查找现有设置
	var themeSetting models.SystemSetting
	result := ssc.db.Where("`key` = ? AND `group` = ? AND `user_id` = ?",
		models.SettingTheme, models.SettingGroupTheme, userID).First(&themeSetting)

	// 如果设置不存在，创建新设置
	if result.Error != nil {
		log.Info("用户主题设置不存在，创建新设置")
		themeSetting = models.SystemSetting{
			Key:    models.SettingTheme,
			Value:  input.Theme,
			Group:  models.SettingGroupTheme,
			UserID: &[]uint{userID.(uint)}[0], // 转换为指针
		}
		if err := ssc.db.Create(&themeSetting).Error; err != nil {
			log.Error("创建主题设置失败", logger.F("error", err.Error()))
			appErr := errors.New(errors.ErrDatabaseInsert).
				WithDetails("创建主题设置失败").
				WithError(err).
				WithRequestID(c.GetString("request_id"))
			c.Error(appErr)
			return
		}
	} else {
		// 如果设置存在，更新设置值
		oldTheme := themeSetting.Value
		themeSetting.Value = input.Theme
		if err := ssc.db.Save(&themeSetting).Error; err != nil {
			log.Error("更新主题设置失败", logger.F("error", err.Error()))
			appErr := errors.New(errors.ErrDatabaseUpdate).
				WithDetails("更新主题设置失败").
				WithError(err).
				WithRequestID(c.GetString("request_id"))
			c.Error(appErr)
			return
		}
		log.Info("更新用户主题设置",
			logger.F("old_theme", oldTheme),
			logger.F("new_theme", input.Theme))
	}

	log.Info("更新用户主题设置成功")
	c.JSON(http.StatusOK, gin.H{"message": "主题设置已更新", "theme": input.Theme})
}
