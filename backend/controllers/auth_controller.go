package controllers

import (
	"hd_psi/backend/models"
	"hd_psi/backend/utils"
	"hd_psi/backend/utils/errors"
	"hd_psi/backend/utils/logger"
	"net/http"
	"time"

	"github.com/gin-gonic/gin"
	"gorm.io/gorm"
)

type AuthController struct {
	db *gorm.DB
}

func NewAuthController(db *gorm.DB) *AuthController {
	return &AuthController{db: db}
}

// LoginInput 定义用户登录请求的参数结构
type LoginInput struct {
	// Username 用户登录名，必填字段
	Username string `json:"username" binding:"required"`
	// Password 用户密码，必填字段
	Password string `json:"password" binding:"required"`
	// RememberMe 记住我标志，用于延长会话时间
	RememberMe bool `json:"remember_me"`
}

// RegisterInput 定义用户注册请求的参数结构
type RegisterInput struct {
	// Username 用户登录名，必填字段，必须唯一
	Username string `json:"username" binding:"required"`
	// Password 用户密码，必填字段
	Password string `json:"password" binding:"required"`
	// Name 用户真实姓名，必填字段
	Name string `json:"name" binding:"required"`
	// Email 用户电子邮箱，可选字段
	Email string `json:"email"`
	// Phone 用户手机号码，可选字段
	Phone string `json:"phone"`
	// Role 用户角色，必填字段
	Role models.Role `json:"role" binding:"required"`
	// StoreID 用户所属店铺ID，可选字段，总部人员可为空
	StoreID *uint `json:"store_id"`
}

// LoginResponse 定义登录成功后的响应数据结构
type LoginResponse struct {
	// Token JWT认证令牌，用于后续请求的身份验证
	Token string `json:"token"`
	// RefreshToken 刷新令牌，用于获取新的访问令牌
	RefreshToken string `json:"refresh_token"`
	// User 登录用户的基本信息，不包含敏感数据如密码
	User models.User `json:"user"`
	// ExpiresAt 令牌过期时间
	ExpiresAt time.Time `json:"expires_at"`
	// RefreshTokenExpiresAt 刷新令牌过期时间
	RefreshTokenExpiresAt time.Time `json:"refresh_token_expires_at"`
}

// Login 处理用户登录请求
// 验证用户凭证并生成JWT令牌
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) Login(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("处理用户登录请求")

	// 解析请求参数
	var input LoginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("登录请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的用户名和密码").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 查找用户
	var user models.User
	if err := ac.db.Where("username = ?", input.Username).First(&user).Error; err != nil {
		log.Warn("用户名不存在", logger.F("username", input.Username))
		appErr := errors.New(errors.ErrInvalidCredentials).
			WithDetails("请检查您的用户名是否正确").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查用户状态
	if !user.Status {
		log.Warn("用户已被禁用", logger.F("user_id", user.ID), logger.F("username", user.Username))
		appErr := errors.New(errors.ErrUserDisabled).
			WithDetails("请联系管理员解除账户限制").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查账户是否被锁定
	locked, duration := user.IsLocked()
	if locked {
		log.Warn("账户已被锁定", 
			logger.F("user_id", user.ID), 
			logger.F("username", user.Username),
			logger.F("locked_until", user.LockedUntil),
			logger.F("wait_minutes", int(duration.Minutes())))
		
		appErr := errors.New(errors.ErrUserLocked).
			WithDetails("由于多次登录失败，账户已被锁定").
			WithRequestID(c.GetString("request_id"))
		
		// 添加锁定信息到响应
		c.JSON(appErr.HTTPStatus(), gin.H{
			"error":        appErr.Message,
			"details":      appErr.Details,
			"request_id":   appErr.RequestID,
			"locked_until": time.Now().Add(duration),
			"wait_minutes": int(duration.Minutes()),
		})
		return
	}

	// 验证密码
	if !user.CheckPassword(input.Password) {
		// 增加登录尝试次数
		const maxAttempts = 5
		const lockDuration = 15 * time.Minute

		locked := user.IncrementLoginAttempts(maxAttempts, lockDuration)
		ac.db.Save(&user)

		if locked {
			log.Warn("账户因多次登录失败被锁定", 
				logger.F("user_id", user.ID), 
				logger.F("username", user.Username),
				logger.F("locked_until", user.LockedUntil),
				logger.F("lock_duration", lockDuration))
			
			appErr := errors.New(errors.ErrUserLocked).
				WithDetails("由于多次登录失败，账户已被锁定15分钟").
				WithRequestID(c.GetString("request_id"))
			
			// 添加锁定信息到响应
			c.JSON(appErr.HTTPStatus(), gin.H{
				"error":        appErr.Message,
				"details":      appErr.Details,
				"request_id":   appErr.RequestID,
				"locked_until": time.Now().Add(lockDuration),
				"wait_minutes": int(lockDuration.Minutes()),
			})
		} else {
			remainingAttempts := maxAttempts - user.LoginAttempts
			log.Warn("密码错误", 
				logger.F("user_id", user.ID), 
				logger.F("username", user.Username),
				logger.F("login_attempts", user.LoginAttempts),
				logger.F("remaining_attempts", remainingAttempts))
			
			appErr := errors.New(errors.ErrInvalidCredentials).
				WithDetails("请检查您的密码是否正确").
				WithRequestID(c.GetString("request_id"))
			
			// 添加剩余尝试次数到响应
			c.JSON(appErr.HTTPStatus(), gin.H{
				"error":              appErr.Message,
				"details":            appErr.Details,
				"request_id":         appErr.RequestID,
				"remaining_attempts": remainingAttempts,
			})
		}
		return
	}

	// 重置登录尝试次数
	user.ResetLoginAttempts()

	// 生成JWT令牌
	token, expiresAt, err := utils.GenerateToken(user.ID, user.Username, string(user.Role), input.RememberMe)
	if err != nil {
		log.Error("生成令牌失败", 
			logger.F("user_id", user.ID), 
			logger.F("username", user.Username),
			logger.F("error", err.Error()))
		
		appErr := errors.New(errors.ErrInternal).
			WithDetails("生成令牌失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 生成刷新令牌
	refreshToken := user.GenerateRefreshToken(utils.RefreshTokenExpiration)

	// 更新用户信息
	now := time.Now()
	user.LastLogin = &now
	user.RememberMe = input.RememberMe
	if err := ac.db.Save(&user).Error; err != nil {
		log.Error("更新用户登录信息失败", 
			logger.F("user_id", user.ID), 
			logger.F("username", user.Username),
			logger.F("error", err.Error()))
		
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("更新用户登录信息失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 清除密码
	user.Password = ""

	log.Info("用户登录成功", 
		logger.F("user_id", user.ID), 
		logger.F("username", user.Username),
		logger.F("role", user.Role),
		logger.F("remember_me", input.RememberMe))

	// 返回令牌和用户信息
	c.JSON(http.StatusOK, LoginResponse{
		Token:                 token,
		RefreshToken:          refreshToken,
		User:                  user,
		ExpiresAt:             expiresAt,
		RefreshTokenExpiresAt: *user.RefreshTokenExpiresAt,
	})
}

// Register 处理用户注册请求
// 创建新用户并将其保存到数据库
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) Register(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("处理用户注册请求")

	// 解析请求参数
	var input RegisterInput
	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("注册请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的注册信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查用户名是否已存在
	var existingUser models.User
	if err := ac.db.Where("username = ?", input.Username).First(&existingUser).Error; err == nil {
		log.Warn("用户名已存在", logger.F("username", input.Username))
		appErr := errors.New(errors.ErrUserAlreadyExists).
			WithDetails("该用户名已被使用，请选择其他用户名").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 创建新用户
	user := models.User{
		Username: input.Username,
		Password: input.Password, // 密码会在BeforeSave钩子中自动加密
		Name:     input.Name,
		Email:    input.Email,
		Phone:    input.Phone,
		Role:     input.Role,
		StoreID:  input.StoreID,
		Status:   true,
	}

	if err := ac.db.Create(&user).Error; err != nil {
		log.Error("创建用户失败", 
			logger.F("username", input.Username),
			logger.F("error", err.Error()))
		
		appErr := errors.New(errors.ErrDatabaseInsert).
			WithDetails("创建用户失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 清除密码
	user.Password = ""

	log.Info("用户注册成功", 
		logger.F("user_id", user.ID), 
		logger.F("username", user.Username),
		logger.F("role", user.Role))

	// 返回创建成功的用户信息
	c.JSON(http.StatusCreated, user)
}

// GetProfile 获取当前登录用户的个人信息
// 从请求上下文中获取用户ID并返回用户详细信息
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) GetProfile(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("获取用户个人信息")

	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		log.Warn("未授权的个人信息请求")
		appErr := errors.New(errors.ErrUnauthorized).
			WithDetails("请先登录").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 查询用户信息
	var user models.User
	if err := ac.db.First(&user, userID).Error; err != nil {
		log.Warn("用户不存在", logger.F("user_id", userID))
		appErr := errors.New(errors.ErrUserNotFound).
			WithDetails("用户不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 清除密码
	user.Password = ""

	log.Info("获取用户个人信息成功", logger.F("user_id", user.ID))

	// 返回用户信息
	c.JSON(http.StatusOK, user)
}

// UpdateProfile 更新当前登录用户的个人信息
// 允许用户修改姓名、邮箱和电话等基本信息
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) UpdateProfile(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("更新用户个人信息")

	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		log.Warn("未授权的个人信息更新请求")
		appErr := errors.New(errors.ErrUnauthorized).
			WithDetails("请先登录").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 查询用户信息
	var user models.User
	if err := ac.db.First(&user, userID).Error; err != nil {
		log.Warn("用户不存在", logger.F("user_id", userID))
		appErr := errors.New(errors.ErrUserNotFound).
			WithDetails("用户不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 绑定请求数据
	var input struct {
		// Name 用户姓名
		Name string `json:"name"`
		// Email 电子邮箱
		Email string `json:"email"`
		// Phone 手机号码
		Phone string `json:"phone"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("更新个人信息请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的个人信息").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 更新用户信息
	user.Name = input.Name
	user.Email = input.Email
	user.Phone = input.Phone

	if err := ac.db.Save(&user).Error; err != nil {
		log.Error("更新用户信息失败", 
			logger.F("user_id", user.ID),
			logger.F("error", err.Error()))
		
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("更新用户信息失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 清除密码
	user.Password = ""

	log.Info("更新用户个人信息成功", logger.F("user_id", user.ID))

	// 返回更新后的用户信息
	c.JSON(http.StatusOK, user)
}

// ChangePassword 处理用户修改密码请求
// 验证旧密码并更新为新密码
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) ChangePassword(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("处理用户修改密码请求")

	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		log.Warn("未授权的密码修改请求")
		appErr := errors.New(errors.ErrUnauthorized).
			WithDetails("请先登录").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 查询用户信息
	var user models.User
	if err := ac.db.First(&user, userID).Error; err != nil {
		log.Warn("用户不存在", logger.F("user_id", userID))
		appErr := errors.New(errors.ErrUserNotFound).
			WithDetails("用户不存在或已被删除").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 绑定请求数据
	var input struct {
		// OldPassword 用户当前密码，必填字段
		OldPassword string `json:"old_password" binding:"required"`
		// NewPassword 用户新密码，必填字段
		NewPassword string `json:"new_password" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("密码修改请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供旧密码和新密码").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 验证旧密码
	if !user.CheckPassword(input.OldPassword) {
		log.Warn("旧密码错误", logger.F("user_id", user.ID))
		appErr := errors.New(errors.ErrInvalidCredentials).
			WithDetails("请输入正确的当前密码").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 检查新密码长度
	if len(input.NewPassword) < 6 {
		log.Warn("新密码太短", logger.F("user_id", user.ID))
		appErr := errors.New(errors.ErrPasswordTooShort).
			WithDetails("新密码长度不能少于6个字符").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 手动对密码进行哈希处理
	hashedPassword, err := utils.HashPassword(input.NewPassword)
	if err != nil {
		log.Error("密码加密失败", 
			logger.F("user_id", user.ID),
			logger.F("error", err.Error()))
		
		appErr := errors.New(errors.ErrInternal).
			WithDetails("密码加密失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 直接更新已哈希的密码
	if err := ac.db.Model(&user).Update("password", hashedPassword).Error; err != nil {
		log.Error("更新密码失败", 
			logger.F("user_id", user.ID),
			logger.F("error", err.Error()))
		
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("更新密码失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	log.Info("用户密码修改成功", logger.F("user_id", user.ID))

	// 返回成功消息
	c.JSON(http.StatusOK, gin.H{"message": "密码修改成功"})
}

// RefreshToken 刷新访问令牌
// 使用刷新令牌获取新的访问令牌
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) RefreshToken(c *gin.Context) {
	// 创建请求日志
	log := logger.WithContext(c)
	log.Info("处理刷新令牌请求")

	// 绑定请求数据
	var input struct {
		// RefreshToken 刷新令牌，必填字段
		RefreshToken string `json:"refresh_token" binding:"required"`
		// RememberMe 记住我标志，用于延长会话时间
		RememberMe bool `json:"remember_me"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		log.Warn("刷新令牌请求参数无效", logger.F("error", err.Error()))
		appErr := errors.New(errors.ErrInvalidInput).
			WithDetails("请提供有效的刷新令牌").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 查找具有指定刷新令牌的用户
	var user models.User
	if err := ac.db.Where("refresh_token = ?", input.RefreshToken).First(&user).Error; err != nil {
		log.Warn("无效的刷新令牌", logger.F("refresh_token", input.RefreshToken))
		appErr := errors.New(errors.ErrInvalidToken).
			WithDetails("刷新令牌不存在或已过期").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 验证刷新令牌
	if !user.VerifyRefreshToken(input.RefreshToken) {
		log.Warn("刷新令牌已过期", 
			logger.F("user_id", user.ID),
			logger.F("refresh_token", input.RefreshToken))
		
		appErr := errors.New(errors.ErrTokenExpired).
			WithDetails("刷新令牌已过期，请重新登录").
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 生成新的JWT令牌
	token, expiresAt, err := utils.GenerateToken(user.ID, user.Username, string(user.Role), input.RememberMe)
	if err != nil {
		log.Error("生成令牌失败", 
			logger.F("user_id", user.ID),
			logger.F("error", err.Error()))
		
		appErr := errors.New(errors.ErrInternal).
			WithDetails("生成令牌失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 生成新的刷新令牌
	refreshToken := user.GenerateRefreshToken(utils.RefreshTokenExpiration)

	// 更新用户信息
	now := time.Now()
	user.LastLogin = &now
	user.RememberMe = input.RememberMe
	if err := ac.db.Save(&user).Error; err != nil {
		log.Error("更新用户信息失败", 
			logger.F("user_id", user.ID),
			logger.F("error", err.Error()))
		
		appErr := errors.New(errors.ErrDatabaseUpdate).
			WithDetails("更新用户信息失败").
			WithError(err).
			WithRequestID(c.GetString("request_id"))
		c.Error(appErr)
		return
	}

	// 清除密码
	user.Password = ""

	log.Info("刷新令牌成功", logger.F("user_id", user.ID))

	// 返回新的令牌和用户信息
	c.JSON(http.StatusOK, LoginResponse{
		Token:                 token,
		RefreshToken:          refreshToken,
		User:                  user,
		ExpiresAt:             expiresAt,
		RefreshTokenExpiresAt: *user.RefreshTokenExpiresAt,
	})
}
