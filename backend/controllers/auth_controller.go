package controllers

import (
	"hd_psi/backend/models"
	"hd_psi/backend/utils"
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
	// 解析请求参数
	var input LoginInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "details": "请提供有效的用户名和密码"})
		return
	}

	// 查找用户
	var user models.User
	if err := ac.db.Where("username = ?", input.Username).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "用户名或密码错误", "details": "请检查您的用户名是否正确"})
		return
	}

	// 检查用户状态
	if !user.Status {
		c.JSON(http.StatusForbidden, gin.H{"error": "用户已被禁用", "details": "请联系管理员解除账户限制"})
		return
	}

	// 检查账户是否被锁定
	locked, duration := user.IsLocked()
	if locked {
		c.JSON(http.StatusTooManyRequests, gin.H{
			"error":        "账户暂时被锁定",
			"details":      "由于多次登录失败，账户已被锁定",
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
			c.JSON(http.StatusTooManyRequests, gin.H{
				"error":        "账户已被锁定",
				"details":      "由于多次登录失败，账户已被锁定15分钟",
				"locked_until": time.Now().Add(lockDuration),
				"wait_minutes": int(lockDuration.Minutes()),
			})
		} else {
			remainingAttempts := maxAttempts - user.LoginAttempts
			c.JSON(http.StatusUnauthorized, gin.H{
				"error":              "用户名或密码错误",
				"details":            "请检查您的密码是否正确",
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成令牌失败"})
		return
	}

	// 生成刷新令牌
	refreshToken := user.GenerateRefreshToken(utils.RefreshTokenExpiration)

	// 更新用户信息
	now := time.Now()
	user.LastLogin = &now
	user.RememberMe = input.RememberMe
	ac.db.Save(&user)

	// 清除密码
	user.Password = ""

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
	// 解析请求参数
	var input RegisterInput
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 检查用户名是否已存在
	var existingUser models.User
	if err := ac.db.Where("username = ?", input.Username).First(&existingUser).Error; err == nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "用户名已存在"})
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
		c.JSON(http.StatusInternalServerError, gin.H{"error": "创建用户失败"})
		return
	}

	// 清除密码
	user.Password = ""

	// 返回创建成功的用户信息
	c.JSON(http.StatusCreated, user)
}

// GetProfile 获取当前登录用户的个人信息
// 从请求上下文中获取用户ID并返回用户详细信息
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) GetProfile(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 查询用户信息
	var user models.User
	if err := ac.db.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
		return
	}

	// 清除密码
	user.Password = ""

	// 返回用户信息
	c.JSON(http.StatusOK, user)
}

// UpdateProfile 更新当前登录用户的个人信息
// 允许用户修改姓名、邮箱和电话等基本信息
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) UpdateProfile(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 查询用户信息
	var user models.User
	if err := ac.db.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
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
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	// 更新用户信息
	user.Name = input.Name
	user.Email = input.Email
	user.Phone = input.Phone

	if err := ac.db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新用户信息失败"})
		return
	}

	// 清除密码
	user.Password = ""

	// 返回更新后的用户信息
	c.JSON(http.StatusOK, user)
}

// ChangePassword 处理用户修改密码请求
// 验证旧密码并更新为新密码
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) ChangePassword(c *gin.Context) {
	// 从上下文中获取用户ID
	userID, exists := c.Get("userID")
	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "未授权"})
		return
	}

	// 查询用户信息
	var user models.User
	if err := ac.db.First(&user, userID).Error; err != nil {
		c.JSON(http.StatusNotFound, gin.H{"error": "用户不存在"})
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
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "details": "请提供旧密码和新密码"})
		return
	}

	// 验证旧密码
	if !user.CheckPassword(input.OldPassword) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "旧密码错误", "details": "请输入正确的当前密码"})
		return
	}

	// 检查新密码长度
	if len(input.NewPassword) < 6 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "密码太短", "details": "新密码长度不能少于6个字符"})
		return
	}

	// 手动对密码进行哈希处理
	hashedPassword, err := utils.HashPassword(input.NewPassword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "密码加密失败", "details": "系统错误，请稍后再试"})
		return
	}

	// 直接更新已哈希的密码
	if err := ac.db.Model(&user).Update("password", hashedPassword).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "更新密码失败", "details": "系统错误，请稍后再试"})
		return
	}

	// 返回成功消息
	c.JSON(http.StatusOK, gin.H{"message": "密码修改成功"})
}

// RefreshToken 刷新访问令牌
// 使用刷新令牌获取新的访问令牌
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) RefreshToken(c *gin.Context) {
	// 绑定请求数据
	var input struct {
		// RefreshToken 刷新令牌，必填字段
		RefreshToken string `json:"refresh_token" binding:"required"`
		// RememberMe 记住我标志，用于延长会话时间
		RememberMe bool `json:"remember_me"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "details": "请提供有效的刷新令牌"})
		return
	}

	// 查找具有指定刷新令牌的用户
	var user models.User
	if err := ac.db.Where("refresh_token = ?", input.RefreshToken).First(&user).Error; err != nil {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的刷新令牌", "details": "刷新令牌不存在或已过期"})
		return
	}

	// 验证刷新令牌
	if !user.VerifyRefreshToken(input.RefreshToken) {
		c.JSON(http.StatusUnauthorized, gin.H{"error": "无效的刷新令牌", "details": "刷新令牌不存在或已过期"})
		return
	}

	// 生成新的JWT令牌
	token, expiresAt, err := utils.GenerateToken(user.ID, user.Username, string(user.Role), input.RememberMe)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成令牌失败", "details": "系统错误，请稍后再试"})
		return
	}

	// 生成新的刷新令牌
	refreshToken := user.GenerateRefreshToken(utils.RefreshTokenExpiration)

	// 更新用户信息
	now := time.Now()
	user.LastLogin = &now
	user.RememberMe = input.RememberMe
	ac.db.Save(&user)

	// 清除密码
	user.Password = ""

	// 返回新的令牌和用户信息
	c.JSON(http.StatusOK, LoginResponse{
		Token:                 token,
		RefreshToken:          refreshToken,
		User:                  user,
		ExpiresAt:             expiresAt,
		RefreshTokenExpiresAt: *user.RefreshTokenExpiresAt,
	})
}

// ForgotPassword 处理忘记密码请求
// 发送密码重置令牌到用户邮箱
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) ForgotPassword(c *gin.Context) {
	// 绑定请求数据
	var input struct {
		// Email 用户邮箱，必填字段
		Email string `json:"email" binding:"required,email"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "details": "请提供有效的邮箱地址"})
		return
	}

	// 查找用户
	var user models.User
	if err := ac.db.Where("email = ?", input.Email).First(&user).Error; err != nil {
		// 为了安全考虑，不透露用户是否存在
		c.JSON(http.StatusOK, gin.H{"message": "如果邮箱存在，密码重置链接将发送到您的邮箱"})
		return
	}

	// 生成密码重置令牌
	resetToken := user.GeneratePasswordResetToken(utils.PasswordResetTokenExpiration)

	// 保存用户信息
	if err := ac.db.Save(&user).Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "生成重置令牌失败", "details": "系统错误，请稍后再试"})
		return
	}

	// TODO: 发送密码重置邮件
	// 在实际应用中，这里应该调用邮件发送服务
	// 例如：
	// resetURL := fmt.Sprintf("%s/reset-password?token=%s", config.FrontendURL, resetToken)
	// emailService.SendPasswordResetEmail(user.Email, user.Name, resetURL)

	// 返回成功消息
	c.JSON(http.StatusOK, gin.H{
		"message":     "密码重置链接已发送到您的邮箱",
		"reset_token": resetToken, // 在实际应用中应移除这一行，这里只是为了测试方便
	})
}

// ResetPassword 处理密码重置请求
// 验证密码重置令牌并更新密码
// 参数：
//   - c: Gin上下文对象，包含请求和响应信息
func (ac *AuthController) ResetPassword(c *gin.Context) {
	// 绑定请求数据
	var input struct {
		// Token 密码重置令牌，必填字段
		Token string `json:"token" binding:"required"`
		// NewPassword 新密码，必填字段
		NewPassword string `json:"new_password" binding:"required,min=6"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error(), "details": "请提供有效的重置令牌和新密码"})
		return
	}

	// 查找具有指定重置令牌的用户
	var user models.User
	if err := ac.db.Where("reset_password_token = ?", input.Token).First(&user).Error; err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的重置令牌", "details": "重置令牌不存在或已过期"})
		return
	}

	// 验证重置令牌
	if !user.VerifyPasswordResetToken(input.Token) {
		c.JSON(http.StatusBadRequest, gin.H{"error": "无效的重置令牌", "details": "重置令牌不存在或已过期"})
		return
	}

	// 清除重置令牌
	user.ClearPasswordResetToken()

	// 手动对密码进行哈希处理
	hashedPassword, err := utils.HashPassword(input.NewPassword)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "密码加密失败", "details": "系统错误，请稍后再试"})
		return
	}

	// 开始事务
	tx := ac.db.Begin()

	// 直接更新已哈希的密码
	if err := tx.Model(&user).Update("password", hashedPassword).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "重置密码失败", "details": "系统错误，请稍后再试"})
		return
	}

	// 更新重置令牌字段
	if err := tx.Model(&user).Updates(map[string]any{
		"reset_password_token":   "",
		"reset_password_expires": nil,
	}).Error; err != nil {
		tx.Rollback()
		c.JSON(http.StatusInternalServerError, gin.H{"error": "重置密码失败", "details": "系统错误，请稍后再试"})
		return
	}

	// 提交事务
	if err := tx.Commit().Error; err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": "重置密码失败", "details": "系统错误，请稍后再试"})
		return
	}

	// 返回成功消息
	c.JSON(http.StatusOK, gin.H{"message": "密码重置成功，请使用新密码登录"})
}
